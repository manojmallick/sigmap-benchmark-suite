/**
 * BM25 re-ranker with identifier-aware tokenization — proven to lift retrieval
 * hit@5 75.3% → 82.4% (MRR 0.601 → 0.699) over SigMap's TF-IDF on 85 curated
 * tasks (see scripts/rerank-eval.mjs / results/reports/rerank-eval.md).
 * Shared by rerank-eval.mjs and devin-experiment.mjs.
 */
const STOP = new Set(
  "a an the of to in on for and or is are be by with as at from that this it its into get set add new return value test".split(" ")
);

/** Light suffix stemmer — conservative, good enough for code identifiers. */
export function stem(w) {
  if (w.length <= 3) return w;
  let s = w;
  s = s.replace(/ies$/, "y");
  s = s.replace(/(sses|shes|ches|xes|zes)$/, (m) => m.slice(0, -2));
  s = s.replace(/([^s])s$/, "$1");
  s = s.replace(/(ization|izations)$/, "ize");
  s = s.replace(/(ing|edly|ed| er|ers|ation|ations|ment|ness|ity|ive|able|ible|ize|ise|al)$/, "");
  return s.length >= 3 ? s : w;
}

/** Split on non-alnum AND camelCase/snake_case, lowercase, stem, drop stopwords. */
export function tokenize(text) {
  return text
    .replace(/[^A-Za-z0-9]+/g, " ")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1 $2")
    .toLowerCase()
    .split(/\s+/)
    .filter((t) => t.length > 1 && !STOP.has(t))
    .map(stem)
    .filter(Boolean);
}

const PATH_BOOST = 3; // repeat path tokens so the filename weighs heavily

/**
 * BM25 re-rank of candidates [{file, sigs}] against a query.
 * Returns the same candidate objects, sorted best-first (sigs preserved).
 */
export function bm25rank(query, candidates) {
  const k1 = 1.5, b = 0.75;
  const docs = candidates.map((c) => {
    const pathToks = tokenize(c.file);
    const toks = [...tokenize((c.sigs || []).join(" "))];
    for (let i = 0; i < PATH_BOOST; i++) toks.push(...pathToks);
    const tf = new Map();
    for (const t of toks) tf.set(t, (tf.get(t) || 0) + 1);
    return { cand: c, tf, len: toks.length };
  });
  const N = docs.length || 1;
  const avgdl = docs.reduce((s, d) => s + d.len, 0) / N || 1;
  const df = new Map();
  for (const d of docs) for (const t of d.tf.keys()) df.set(t, (df.get(t) || 0) + 1);
  const qToks = [...new Set(tokenize(query))];
  return docs
    .map((d) => {
      let score = 0;
      for (const t of qToks) {
        const f = d.tf.get(t);
        if (!f) continue;
        const idf = Math.log(1 + (N - df.get(t) + 0.5) / (df.get(t) + 0.5));
        score += (idf * (f * (k1 + 1))) / (f + k1 * (1 - b + (b * d.len) / avgdl));
      }
      return { ...d.cand, _score: score };
    })
    .sort((a, b2) => b2._score - a._score);
}
