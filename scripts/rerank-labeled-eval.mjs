#!/usr/bin/env node
/**
 * rerank-labeled-eval.mjs — scale the retrieval benchmark by adding labeled tasks.
 *
 * Scores SigMap's OLD exact-token TF-IDF vs the SHIPPED identifier-aware BM25
 * (src/retrieval/bm25.js) over a labeled task set, per repo and overall
 * (hit@1 / hit@5 / MRR). This is the only honest way to measure the ranker: on
 * human-written natural-language queries with known target files. Synthetic
 * label-free queries (symbol-copied-from-target) are biased toward exact match
 * and understate BM25 — see the project notes.
 *
 * Two modes:
 *   --reuse-dir <dir>   Score against ALREADY-generated context files under
 *                       <dir>/<repo>/.github/copilot-instructions.md (fast, no
 *                       network). Default: ~/sigmap/benchmarks/repos.
 *   --clone             Clone each repo fresh (depth 1), generate context with
 *                       SigMap, score, delete (disk-safe streaming). Needs a
 *                       repos manifest with github urls.
 *
 * Tasks: one <repo>.jsonl per repo, each line
 *   { "id": "...", "query": "natural language intent", "expected_files": ["path", ...] }
 * hit = any expected file appears in the ranked top-k.
 *
 * Usage:
 *   node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended
 *   node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended --repos dplyr,ggplot2,shiny
 *   node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended --clone --manifest scripts/repos-extended.json
 *
 * Zero external deps. Requires a local SigMap checkout for the shipped ranker
 * (SIGMAP_DIR env or ~/sigmap).
 */
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { readFileSync, existsSync, readdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { join, basename } from 'node:path';
import { homedir, tmpdir } from 'node:os';

const require = createRequire(import.meta.url);
const argv = process.argv.slice(2);
const flag = (name, def = null) => {
  const i = argv.indexOf(name);
  return i !== -1 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : (i !== -1 ? true : def);
};

const SIGMAP_DIR = process.env.SIGMAP_DIR || join(homedir(), 'sigmap');
const SIGMAP = join(SIGMAP_DIR, 'gen-context.js');
const TASKS_DIR = flag('--tasks-dir', 'tasks-extended');
const REUSE_DIR = flag('--reuse-dir', join(SIGMAP_DIR, 'benchmarks', 'repos'));
const DO_CLONE = argv.includes('--clone');
const MANIFEST = flag('--manifest', null);
const ONLY = flag('--repos', null); // comma list
const TOPK = parseInt(flag('--top', '5'), 10);

// Shipped BM25 (the thing under test) — loaded from the SigMap checkout.
const { bm25rank } = require(join(SIGMAP_DIR, 'src', 'retrieval', 'bm25.js'));

// OLD exact-token TF-IDF (verbatim from pre-#396 src/eval/runner.js) — the baseline.
const OLD_STOP = new Set('the a an in of to for and or is are that this it with from by be as on at'.split(' '));
const oldTok = (t) => (t || '').replace(/([a-z])([A-Z])/g, '$1 $2').replace(/[_\-]/g, ' ')
  .replace(/[^\w\s]/g, ' ').toLowerCase().split(/\s+/).filter((x) => x.length > 1);
function oldScore(sigs, q) {
  const set = new Set(oldTok((sigs || []).join(' ')));
  let s = 0;
  for (const qt of q) { if (OLD_STOP.has(qt)) continue; if (set.has(qt)) s += 1; for (const st of set) if (st !== qt && st.startsWith(qt) && qt.length >= 4) s += 0.3; }
  return s;
}
function oldRank(query, index) {
  const q = oldTok(query);
  return [...index.entries()].map(([f, s]) => ({ file: f, score: oldScore(s, q) }))
    .sort((a, b) => b.score - a.score || a.file.localeCompare(b.file));
}
function newRank(query, index) {
  const cands = [...index.entries()].map(([file, sigs]) => ({ file, sigs }));
  return bm25rank(query, cands);
}

function buildIndex(ctxPath) {
  const idx = new Map();
  if (!existsSync(ctxPath)) return idx;
  let cur = null, inB = false, sigs = [];
  for (const line of readFileSync(ctxPath, 'utf8').split('\n')) {
    const h = line.match(/^###\s+(\S+)\s*$/);
    if (h) { if (cur) idx.set(cur, sigs); cur = h[1]; sigs = []; inB = false; continue; }
    if (line.startsWith('```')) { inB = !inB; continue; }
    if (inB && cur && line.trim()) sigs.push(line.trim());
  }
  if (cur) idx.set(cur, sigs);
  return idx;
}
const norm = (p) => String(p).replace(/^\.\//, '').replace(/\\/g, '/');
function firstRank(ranked, expected) {
  const exp = new Set(expected.map(norm));
  for (let i = 0; i < ranked.length; i++) if (exp.has(norm(ranked[i].file))) return i + 1;
  return Infinity;
}
function loadTasks(f) {
  return readFileSync(f, 'utf8').split('\n').filter(Boolean).map((l) => JSON.parse(l))
    .filter((t) => t.query && Array.isArray(t.expected_files) && t.expected_files.length);
}

// ── select repos from tasks dir ───────────────────────────────────────────────
let repos = readdirSync(TASKS_DIR).filter((f) => f.endsWith('.jsonl')).map((f) => basename(f, '.jsonl'));
if (ONLY && ONLY !== true) { const set = new Set(ONLY.split(',')); repos = repos.filter((r) => set.has(r)); }

const manifest = MANIFEST && existsSync(MANIFEST) ? JSON.parse(readFileSync(MANIFEST, 'utf8')) : {};

const CLONE_CONFIG = JSON.stringify({
  srcDirs: ['.'], maxDepth: 12, autoMaxTokens: false, maxTokens: 200000,
  exclude: ['node_modules', '.git', 'dist', 'build', 'target', 'vendor', 'test', 'tests', 'docs', 'doc', 'examples', 'scripts'],
});
function contextFor(repo) {
  if (!DO_CLONE) return { ctx: join(REUSE_DIR, repo, '.github', 'copilot-instructions.md'), cleanup: () => {} };
  const url = manifest[repo];
  if (!url) { console.error(`  ✗ ${repo}: no url in manifest`); return null; }
  const work = mkdtempSync(join(tmpdir(), `le-${repo}-`));
  const dir = join(work, 'r');
  try {
    execFileSync('git', ['clone', '--depth', '1', '-q', url, dir], { timeout: 300000, stdio: 'ignore' });
    writeFileSync(join(dir, 'gen-context.config.json'), CLONE_CONFIG);
    execFileSync(process.execPath, [SIGMAP], { cwd: dir, stdio: 'ignore', timeout: 180000 });
    return { ctx: join(dir, '.github', 'copilot-instructions.md'), cleanup: () => rmSync(work, { recursive: true, force: true }) };
  } catch (e) { rmSync(work, { recursive: true, force: true }); console.error(`  ✗ ${repo}: ${String(e.message).slice(0, 80)}`); return null; }
}

// ── run ───────────────────────────────────────────────────────────────────────
const rows = [];
let T = 0, oH1 = 0, oH5 = 0, oMRR = 0, nH1 = 0, nH5 = 0, nMRR = 0;
for (const repo of repos) {
  const tasks = loadTasks(join(TASKS_DIR, `${repo}.jsonl`));
  if (!tasks.length) continue;
  const c = contextFor(repo);
  if (!c) continue;
  const idx = buildIndex(c.ctx);
  c.cleanup();
  if (idx.size === 0) { console.error(`  ✗ ${repo}: no context (need to clone/generate first)`); continue; }
  let n = 0, o1 = 0, o5 = 0, om = 0, x1 = 0, x5 = 0, xm = 0;
  for (const t of tasks) {
    const or = firstRank(oldRank(t.query, idx), t.expected_files);
    const nr = firstRank(newRank(t.query, idx), t.expected_files);
    n++;
    o1 += or === 1 ? 1 : 0; o5 += or <= 5 ? 1 : 0; om += or === Infinity ? 0 : 1 / or;
    x1 += nr === 1 ? 1 : 0; x5 += nr <= 5 ? 1 : 0; xm += nr === Infinity ? 0 : 1 / nr;
  }
  rows.push({ repo, n, o5, x5, om: om / n, xm: xm / n });
  T += n; oH1 += o1; oH5 += o5; oMRR += om; nH1 += x1; nH5 += x5; nMRR += xm;
}

const pct = (x, d) => (x / d * 100).toFixed(1) + '%';
console.log('\nLabeled retrieval eval — TF-IDF vs shipped BM25  (' + (DO_CLONE ? 'fresh clone' : 'reused context') + ')\n');
console.log('Repo'.padEnd(18) + 'Tasks'.padStart(6) + 'TFIDF@5'.padStart(9) + 'BM25@5'.padStart(9) + '  ΔMRR');
console.log('─'.repeat(52));
for (const r of rows) {
  const d = (r.xm - r.om >= 0 ? '+' : '') + (r.xm - r.om).toFixed(3);
  console.log(r.repo.padEnd(18) + String(r.n).padStart(6) + pct(r.o5, r.n).padStart(9) + pct(r.x5, r.n).padStart(9) + '  ' + d);
}
console.log('─'.repeat(52));
console.log('OVERALL'.padEnd(18) + String(T).padStart(6) + pct(oH5, T).padStart(9) + pct(nH5, T).padStart(9) + '  ' + ((nMRR - oMRR) / T >= 0 ? '+' : '') + ((nMRR - oMRR) / T).toFixed(3));
console.log(`\nhit@1:  TF-IDF ${pct(oH1, T)}  →  BM25 ${pct(nH1, T)}`);
console.log(`hit@5:  TF-IDF ${pct(oH5, T)}  →  BM25 ${pct(nH5, T)}`);
console.log(`MRR:    TF-IDF ${(oMRR / T).toFixed(3)}  →  BM25 ${(nMRR / T).toFixed(3)}`);
console.log(`\n${T} labeled tasks across ${rows.length} repos.`);
