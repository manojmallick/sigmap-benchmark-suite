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

mkdir -p "$RAW_DIR"

# Metadata: language map (label → language)
declare -A LANG_MAP=(
  [typescript-compiler]=TypeScript [vscode]=TypeScript [nextjs]=TypeScript
  [nestjs]=TypeScript [prisma]=TypeScript [azure-sdk-js]=TypeScript
  [aws-cdk]=TypeScript [turborepo]=TypeScript
  [express]=JavaScript [react]=JavaScript [webpack]=JavaScript
  [jest]=JavaScript [lodash]=JavaScript
  [django]=Python [flask]=Python [fastapi]=Python
  [scikit-learn]=Python [requests]=Python
  [spring-boot]=Java [elasticsearch]=Java [kafka]=Java [retrofit]=Java
  [ktor]=Kotlin [kotlin-lang]=Kotlin [android-arch]=Kotlin
  [gin]=Go [fiber]=Go [kubernetes]=Go [terraform]=Go
  [tokio]=Rust [actix-web]=Rust [serde]=Rust [rustfmt]=Rust
  [aspnetcore]=CSharp [efcore]=CSharp [orleans]=CSharp
  [rails]=Ruby [sidekiq]=Ruby [devise]=Ruby
  [laravel]=PHP [symfony]=PHP [composer]=PHP
  [alamofire]=Swift [vapor]=Swift [swiftformat]=Swift
  [flutter]=Dart [flutterfire]=Dart [riverpod]=Dart
  [spark]=Scala [akka]=Scala
  [vue-core]=Vue [vuetify]=Vue [nuxt]=Vue
  [svelte]=Svelte [sveltekit]=Svelte
  [bootstrap]=HTML_CSS [tailwindcss]=CSS [foundation]=SCSS
  [grafana]=YAML_Mixed [ansible]=YAML_Mixed
  [nvm]=Shell [ohmyzsh]=Shell
  [docker-official]=Dockerfile [bitnami-containers]=Dockerfile
)

# ── Benchmark one repo ───────────────────────────────────────────────────────
benchmark_repo() {
  local label="$1"
  local repo_path="$REPOS_DIR/$label"
  local out_dir="$RAW_DIR/$label"
  local lang="${LANG_MAP[$label]:-Unknown}"

  [ -d "$repo_path" ] || { echo "[SKIP] $label — not cloned"; return; }

  mkdir -p "$out_dir"

  echo "[START] $label ($lang)"

  # ── Run each sigmap command, capture JSON + timing ──────────────────────
  run_cmd() {
    local mode="$1"; shift
    local out_file="$out_dir/${mode}.json"
    local time_file="$out_dir/${mode}.time"

    local start=$(date +%s%3N)

    timeout "$TIMEOUT_SECS" node "$SIGMAP" "$@" \
      > "$out_file" 2>"$out_dir/${mode}.stderr" || true

    local end=$(date +%s%3N)
    echo "$((end - start))" > "$time_file"

    # validate JSON — replace with error envelope if broken
    if ! jq empty "$out_file" 2>/dev/null; then
      echo '{"error":"invalid_json","stderr_preview":"'$(head -c 200 "$out_dir/${mode}.stderr" | tr '"' "'")'"}' > "$out_file"
    fi
  }

  cd "$repo_path"

  # ── Create language-specific config for sigmap ──────────────────────────
  case "$lang" in
    Java)
      cat > gen-context.config.json <<'CONFIG'
{"srcDirs": ["src/main/java", "src/main/kotlin", "src/test/java", "src"]}
CONFIG
      ;;
    Kotlin)
      cat > gen-context.config.json <<'CONFIG'
{"srcDirs": ["src/main/kotlin", "src/main/java", "app/src/main/kotlin", "app/src/main", "src"]}
CONFIG
      ;;
    Go)
      cat > gen-context.config.json <<'CONFIG'
{"srcDirs": ["cmd", "internal", "pkg", "api", "handler", "middleware", "src"]}
CONFIG
      ;;
    Scala)
      cat > gen-context.config.json <<'CONFIG'
{"srcDirs": ["src/main/scala", "src", "app"]}
CONFIG
      ;;
  esac

  # ── Core benchmark modes ────────────────────────────────────────────────
  run_cmd "benchmark"     --benchmark    --json
  run_cmd "analyze"       --analyze      --json
  run_cmd "analyze_slow"  --analyze      --slow --json
  run_cmd "report"        --report       --json
  run_cmd "health"        --health       --json

  # ── Generate context once (capture raw token count) ─────────────────────
  local ctx_out="$out_dir/context_gen.json"
  local ctx_start=$(date +%s%3N)
  timeout "$TIMEOUT_SECS" node "$SIGMAP" 2>/dev/null || true
  local ctx_end=$(date +%s%3N)
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

export -f benchmark_repo
export SIGMAP REPOS_DIR RAW_DIR TIMEOUT_SECS
export -A LANG_MAP 2>/dev/null || true   # bash 4.4+ only

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
info "Next step: run  04_aggregate_results.js"
