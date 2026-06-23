#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 3: Run All Benchmarks
# Runs: --benchmark, --analyze, --report, --health, --analyze --slow
# Output: JSON per repo per mode → $HOME/results/raw/
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[BENCH]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

SIGMAP="$HOME/sigmap/gen-context.js"
REPOS_DIR="$HOME/repos"
RAW_DIR="$HOME/results/raw"
TIMEOUT_SECS=120          # skip repo if any single command exceeds this
PARALLEL_JOBS=4           # repos to process in parallel (memory-safe on c2-standard-8)
# `timeout` is Linux-only; macOS has none (or `gtimeout` via coreutils). Fall
# back to no hard timeout so the suite runs locally on macOS too.
if command -v timeout >/dev/null 2>&1; then TIMEOUT="timeout $TIMEOUT_SECS";
elif command -v gtimeout >/dev/null 2>&1; then TIMEOUT="gtimeout $TIMEOUT_SECS";
else TIMEOUT=""; fi

# Millisecond clock. GNU `date +%s%3N` is not portable (BSD/macOS date emits a
# literal "3N"), so prefer python3, then GNU date, then second precision.
if command -v python3 >/dev/null 2>&1; then
  now_ms(){ python3 -c 'import time;print(int(time.time()*1000))'; }
elif date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
  now_ms(){ date +%s%3N; }
else
  now_ms(){ echo $(( $(date +%s) * 1000 )); }
fi

mkdir -p "$RAW_DIR"

# Metadata: label → language. A case function (not `declare -A`) so this runs
# on macOS's bash 3.2, which has no associative arrays.
lang_of() {
  case "$1" in
    typescript-compiler|vscode|nextjs|nestjs|prisma|azure-sdk-js|aws-cdk|turborepo) echo TypeScript ;;
    express|react|webpack|jest|lodash) echo JavaScript ;;
    django|flask|fastapi|scikit-learn|requests) echo Python ;;
    spring-boot|elasticsearch|kafka|retrofit) echo Java ;;
    ktor|kotlin-lang|android-arch) echo Kotlin ;;
    gin|fiber|kubernetes|terraform) echo Go ;;
    tokio|actix-web|serde|rustfmt) echo Rust ;;
    aspnetcore|efcore|orleans) echo CSharp ;;
    rails|sidekiq|devise) echo Ruby ;;
    laravel|symfony|composer) echo PHP ;;
    alamofire|vapor|swiftformat) echo Swift ;;
    flutter|flutterfire|riverpod) echo Dart ;;
    spark|akka) echo Scala ;;
    vue-core|vuetify|nuxt) echo Vue ;;
    svelte|sveltekit) echo Svelte ;;
    bootstrap) echo HTML_CSS ;;
    tailwindcss) echo CSS ;;
    foundation) echo SCSS ;;
    grafana|ansible) echo YAML_Mixed ;;
    nvm|ohmyzsh) echo Shell ;;
    docker-official|bitnami-containers) echo Dockerfile ;;
    *) echo Unknown ;;
  esac
}

# ── Benchmark one repo ───────────────────────────────────────────────────────
benchmark_repo() {
  local label="$1"
  local repo_path="$REPOS_DIR/$label"
  local out_dir="$RAW_DIR/$label"
  local lang="$(lang_of "$label")"

  [ -d "$repo_path" ] || { echo "[SKIP] $label — not cloned"; return; }

  mkdir -p "$out_dir"

  echo "[START] $label ($lang)"

  # ── Run each sigmap command, capture JSON + timing ──────────────────────
  run_cmd() {
    local mode="$1"; shift
    local out_file="$out_dir/${mode}.json"
    local time_file="$out_dir/${mode}.time"

    local start=$(now_ms)

    $TIMEOUT node "$SIGMAP" "$@" \
      > "$out_file" 2>"$out_dir/${mode}.stderr" || true

    local end=$(now_ms)
    echo "$((end - start))" > "$time_file"

    # validate JSON — replace with error envelope if broken
    if ! jq empty "$out_file" 2>/dev/null; then
      echo '{"error":"invalid_json","stderr_preview":"'$(head -c 200 "$out_dir/${mode}.stderr" | tr '"' "'")'"}' > "$out_file"
    fi
  }

  cd "$repo_path"

  # ── sigmap config: language srcDirs + a high-coverage base so retrieval
  #    expected_files are included (signatures stay tiny, so reduction holds).
  local base='"maxDepth":12,"autoMaxTokens":false,"maxTokens":200000,"coverageTarget":0.9'
  # JVM projects are typically multi-module (source in <module>/src/main/...),
  # so scan the whole tree ("."); excludes drop build output and tests.
  local jvm_excl='"exclude":["node_modules",".git","dist","build","out","target","test","tests","docs","project",".gradle"]'
  case "$lang" in
    Java|Kotlin|Scala) echo "{\"srcDirs\":[\".\"],$jvm_excl,$base}" > gen-context.config.json ;;
    Go)     echo "{\"srcDirs\":[\"cmd\",\"internal\",\"pkg\",\"api\",\"handler\",\"middleware\",\"src\",\".\"],$base}" > gen-context.config.json ;;
    *)      echo "{$base}" > gen-context.config.json ;;
  esac

  # ── Retrieval tasks (for hit@5): drop the curated task set if the engine
  #    ships one for this repo, so --benchmark can score retrieval. ──────────
  if [ -f "$HOME/sigmap/benchmarks/tasks/$label.jsonl" ]; then
    mkdir -p benchmarks/tasks
    cp "$HOME/sigmap/benchmarks/tasks/$label.jsonl" benchmarks/tasks/retrieval.jsonl
  fi

  # Generate context once up front so --benchmark scores against this config.
  $TIMEOUT node "$SIGMAP" >/dev/null 2>&1 || true

  # ── Core benchmark modes ────────────────────────────────────────────────
  run_cmd "benchmark"     --benchmark    --json
  run_cmd "analyze"       --analyze      --json
  run_cmd "analyze_slow"  --analyze      --slow --json
  run_cmd "report"        --report       --json
  run_cmd "health"        --health       --json

  # ── Generate context once (capture raw token count) ─────────────────────
  local ctx_out="$out_dir/context_gen.json"
  local ctx_start=$(now_ms)
  $TIMEOUT node "$SIGMAP" 2>/dev/null || true
  local ctx_end=$(now_ms)
  echo "{\"gen_ms\":$((ctx_end - ctx_start))}" > "$ctx_out"

  # ── Count source files ───────────────────────────────────────────────────
  local file_count=$(find "$repo_path" -type f \
    \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
    -o -name "*.py" -o -name "*.java" -o -name "*.kt" -o -name "*.go" \
    -o -name "*.rs" -o -name "*.cs" -o -name "*.rb" -o -name "*.php" \
    -o -name "*.swift" -o -name "*.dart" -o -name "*.scala" \
    -o -name "*.vue" -o -name "*.svelte" -o -name "*.html" \
    -o -name "*.css" -o -name "*.scss" -o -name "*.sh" \
    \) 2>/dev/null | wc -l)

  # ── Write metadata envelope ─────────────────────────────────────────────
  cat > "$out_dir/meta.json" <<EOF
{
  "repo":       "$label",
  "language":   "$lang",
  "file_count": $file_count,
  "benchmarked_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sigmap_version": "$(node $SIGMAP --version 2>/dev/null | tr -d '\n')"
}
EOF

  echo "[DONE]  $label — files: $file_count"
}

export -f benchmark_repo lang_of now_ms
export SIGMAP REPOS_DIR RAW_DIR TIMEOUT_SECS TIMEOUT

# ── Discover all cloned repos ────────────────────────────────────────────────
LABELS=()
while IFS= read -r d; do
  LABELS+=("$(basename "$d")")
done < <(find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

TOTAL=${#LABELS[@]}
log "Running benchmarks on $TOTAL repos ($PARALLEL_JOBS in parallel)..."
echo ""

# ── Parallel execution ───────────────────────────────────────────────────────
printf '%s\n' "${LABELS[@]}" | \
  xargs -P "$PARALLEL_JOBS" -I{} bash -c 'benchmark_repo "$@"' _ {}

echo ""
COMPLETED=$(find "$RAW_DIR" -name "meta.json" | wc -l)
log "✅ Benchmark complete: $COMPLETED / $TOTAL repos processed"
info "Raw results in: $RAW_DIR"
info "Next step: node scripts/aggregate.mjs   (or just use run_all.sh)"
