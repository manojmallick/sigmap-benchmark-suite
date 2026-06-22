#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — LOCAL runner (no GCloud, laptop-friendly)
# Clones a small, language-diverse repo set, benchmarks each with the local
# SigMap engine, and aggregates to reports — all under ./local-run/ by default.
#
#   bash scripts/run_local.sh            # default output dir ./local-run
#   bash scripts/run_local.sh /tmp/bench # custom output dir
# =============================================================================
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'
log(){ echo -e "${GREEN}[LOCAL]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGMAP="$HOME/sigmap/gen-context.js"
BASE="${1:-$SCRIPT_DIR/../local-run}"
REPOS_DIR="$BASE/repos"
RAW_DIR="$BASE/results/raw"
OUT_DIR="$BASE/results"
TIMEOUT_SECS=120

[ -f "$SIGMAP" ] || { warn "SigMap engine missing at $SIGMAP — run: bash scripts/01_setup.sh"; exit 1; }
mkdir -p "$REPOS_DIR" "$RAW_DIR"

# Small, language-diverse, fast-to-clone repos. Format: "URL label language"
REPOS=(
  "https://github.com/sindresorhus/got        got       TypeScript"
  "https://github.com/expressjs/express       express   JavaScript"
  "https://github.com/pallets/flask           flask     Python"
  "https://github.com/psf/requests            requests  Python"
  "https://github.com/google/gson             gson      Java"
  "https://github.com/gin-gonic/gin           gin       Go"
  "https://github.com/dtolnay/anyhow          anyhow    Rust"
  "https://github.com/sinatra/sinatra         sinatra   Ruby"
  "https://github.com/slimphp/Slim            slim      PHP"
  "https://github.com/Alamofire/Alamofire     alamofire Swift"
)

# language-specific srcDirs (mirrors 03_run_benchmarks.sh); nested for gson
config_for(){
  case "$1" in
    gson) echo '{"srcDirs":["gson/src/main/java","gson/src/main","extras"]}' ;;
    Java) echo '{"srcDirs":["src/main/java","src"]}' ;;
    Go)   echo '{"srcDirs":["cmd","internal","pkg","api","src","."]}' ;;
    *)    echo '' ;;
  esac
}

log "Cloning ${#REPOS[@]} repos (shallow) → $REPOS_DIR"
for entry in "${REPOS[@]}"; do
  read -r url label lang <<< "$entry"
  [ -d "$REPOS_DIR/$label" ] && { echo "  • $label (cached)"; continue; }
  git clone --depth 1 -q "$url" "$REPOS_DIR/$label" 2>/dev/null && echo "  ✓ $label" || warn "clone failed: $label"
done

# `timeout` is Linux-only; macOS ships none (or `gtimeout` via coreutils).
TIMEOUT_BIN=""
if command -v timeout >/dev/null 2>&1; then TIMEOUT_BIN="timeout $TIMEOUT_SECS";
elif command -v gtimeout >/dev/null 2>&1; then TIMEOUT_BIN="gtimeout $TIMEOUT_SECS"; fi
run_json(){ $TIMEOUT_BIN node "$SIGMAP" "$@" 2>/dev/null || true; }

log "Benchmarking..."
for entry in "${REPOS[@]}"; do
  read -r url label lang <<< "$entry"
  repo="$REPOS_DIR/$label"; [ -d "$repo" ] || continue
  out="$RAW_DIR/$label"; mkdir -p "$out"
  cd "$repo"
  cfg=$(config_for "$label"); [ -z "$cfg" ] && cfg=$(config_for "$lang")
  [ -n "$cfg" ] && echo "$cfg" > gen-context.config.json
  run_json --report --json    > "$out/report.json"
  run_json --health --json    > "$out/health.json"
  run_json --benchmark --json > "$out/benchmark.json"
  run_json --analyze --json   > "$out/analyze.json"
  fc=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" -o -name "*.php" -o -name "*.swift" \) 2>/dev/null | wc -l | tr -d ' ')
  printf '{"repo":"%s","language":"%s","file_count":%s}' "$label" "$lang" "$fc" > "$out/meta.json"
  echo "  ✓ $label ($lang)"
done

log "Aggregating..."
node "$SCRIPT_DIR/aggregate.mjs" "$RAW_DIR" "$OUT_DIR"
echo ""
log "Done. Reports:"
echo "   $OUT_DIR/reports/report.md"
echo "   $OUT_DIR/reports/academic_table.md"
echo "   $OUT_DIR/exports/results.{csv,json,jsonl}"
