#!/usr/bin/env node
/**
 * Streaming benchmark — clone → benchmark → DELETE, one repo at a time, so the
 * full ~405-repo dataset fits in limited disk (peak ≈ existing + 1 clone).
 * Resumable: skips repos already in ~/results/raw. Aggregates at the end.
 *
 * Usage: node scripts/run_streaming.mjs [target=405] [repoListFile]
 *   repo list lines: "<git-url> <label>"
 */
import { execFileSync } from "node:child_process";
import { readFileSync, readdirSync, existsSync, writeFileSync, rmSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HOME = process.env.HOME;
const HERE = dirname(fileURLToPath(import.meta.url));
const SIGMAP = join(HOME, "sigmap", "gen-context.js");
const TASKS_DIR = join(HOME, "sigmap", "benchmarks", "tasks");
const REPOS = join(HOME, "repos");
const RAW = join(HOME, "results", "raw");
const [targetArg, listArg] = process.argv.slice(2);
const TARGET = Number(targetArg || 405);
const LIST = listArg || join(HERE, "repo-list.txt");
mkdirSync(RAW, { recursive: true });

const CONFIG = JSON.stringify({
  srcDirs: ["."], maxDepth: 12, autoMaxTokens: false, maxTokens: 200000, coverageTarget: 0.9,
  exclude: ["node_modules", ".git", "dist", "build", "out", "target", "vendor", ".gradle",
    "test", "tests", "__tests__", "spec", "e2e", "docs", "doc", "website", "i18n",
    "docusaurus", "locales", "examples", "example", "samples", "benchmarks", "fixtures", "scripts"],
});
const SUP = { ts:"TypeScript",tsx:"TypeScript",js:"JavaScript",jsx:"JavaScript",mjs:"JavaScript",cjs:"JavaScript",py:"Python",java:"Java",kt:"Kotlin",kts:"Kotlin",go:"Go",rs:"Rust",cs:"CSharp",rb:"Ruby",php:"PHP",swift:"Swift",dart:"Dart",scala:"Scala",vue:"Vue",svelte:"Svelte" };
const UNSUP = new Set(["hs","clj","cljc","cljs","lua","c","h","cpp","cc","hpp","ex","exs","erl","ml","jl","r","pl"]);
const SKIP = /(^|\/)(node_modules|\.git|dist|build|out|target|vendor)(\/|$)/;

function detectLang(dir) {
  const c = {};
  const walk = (d, rel = "") => {
    let es; try { es = readdirSync(d, { withFileTypes: true }); } catch { return; }
    for (const e of es) {
      const r = rel ? `${rel}/${e.name}` : e.name;
      if (SKIP.test(`/${r}`)) continue;
      if (e.isDirectory()) walk(join(d, e.name), r);
      else { const m = e.name.toLowerCase().match(/\.([a-z0-9]+)$/); if (m && (SUP[m[1]] || UNSUP.has(m[1]))) c[m[1]] = (c[m[1]] || 0) + 1; }
    }
  };
  walk(dir);
  const top = Object.entries(c).sort((a, b) => b[1] - a[1])[0];
  return top ? (SUP[top[0]] || "Unknown") : "Unknown";
}

function sigmap(dir, args) {
  return execFileSync(process.execPath, [SIGMAP, ...args], { cwd: dir, encoding: "utf8", timeout: 180000, maxBuffer: 64 * 1024 * 1024, stdio: ["ignore", "pipe", "ignore"] });
}

const done = new Set(existsSync(RAW) ? readdirSync(RAW).filter((d) => existsSync(join(RAW, d, "report.json"))) : []);
const list = readFileSync(LIST, "utf8").trim().split("\n").map((l) => l.trim().split(/\s+/)).filter((p) => p.length >= 2);
console.error(`[stream] ${done.size} already done · target ${TARGET} · ${list.length} in list`);

let count = done.size, cloned = 0;
for (const [url, label] of list) {
  if (count >= TARGET) break;
  if (done.has(label)) continue;
  const dir = join(REPOS, label);
  try {
    if (!existsSync(dir)) execFileSync("git", ["clone", "--depth", "1", "-q", url, dir], { timeout: 240000, stdio: "ignore" });
    writeFileSync(join(dir, "gen-context.config.json"), CONFIG);
    const tf = join(TASKS_DIR, `${label}.jsonl`);
    if (existsSync(tf)) { mkdirSync(join(dir, "benchmarks", "tasks"), { recursive: true }); writeFileSync(join(dir, "benchmarks", "tasks", "retrieval.jsonl"), readFileSync(tf)); }
    sigmap(dir, []); // generate
    const out = join(RAW, label); mkdirSync(out, { recursive: true });
    for (const [mode, args] of [["report", ["--report", "--json"]], ["health", ["--health", "--json"]], ["benchmark", ["--benchmark", "--json"]]]) {
      let j = "{}"; try { j = sigmap(dir, args); JSON.parse(j); } catch { j = '{"error":"failed"}'; }
      writeFileSync(join(out, `${mode}.json`), j);
    }
    const lang = detectLang(dir);
    let fc = 0; try { fc = JSON.parse(readFileSync(join(out, "report.json"))).fileCount || 0; } catch {}
    writeFileSync(join(out, "meta.json"), JSON.stringify({ repo: label, language: lang, file_count: fc }));
    const red = (() => { try { return JSON.parse(readFileSync(join(out, "report.json"))).reductionPct; } catch { return "?"; } })();
    count++; cloned++;
    console.error(`  [${count}/${TARGET}] ${label} (${lang}) ${red}%`);
  } catch (e) {
    console.error(`  ✗ ${label}: ${String(e.message).slice(0, 80)}`);
  } finally {
    try { rmSync(dir, { recursive: true, force: true }); } catch {} // free disk
  }
}

console.error(`[stream] processed ${cloned} new · ${count} total · aggregating…`);
execFileSync(process.execPath, [join(HERE, "aggregate.mjs"), RAW, join(HOME, "results")], { stdio: "inherit" });
