#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 1: Environment setup
# Verifies prerequisites (node, git, jq) and ensures the SigMap engine is at
# $HOME/sigmap (gen-context.js), which steps 3/4 invoke. Portable (macOS/Linux).
# =============================================================================
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[SETUP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; }

log "Checking prerequisites..."
for tool in node git; do
  command -v "$tool" >/dev/null 2>&1 || { err "missing required tool: $tool"; exit 1; }
  log "  ✓ $tool $($tool --version 2>/dev/null | head -1)"
done
command -v jq >/dev/null 2>&1 || warn "jq not found — 03_run_benchmarks.sh uses it to validate JSON. Install: brew install jq / apt-get install jq"

SIGMAP_DIR="$HOME/sigmap"
if [ -f "$SIGMAP_DIR/gen-context.js" ]; then
  VER=$(node -e "console.log(require('$SIGMAP_DIR/package.json').version)" 2>/dev/null || echo "?")
  log "  ✓ SigMap engine present at $SIGMAP_DIR (v$VER)"
else
  log "SigMap engine not found — cloning to $SIGMAP_DIR ..."
  git clone --depth 1 -q https://github.com/manojmallick/sigmap "$SIGMAP_DIR"
  log "  ✓ cloned $(node -e "console.log('v'+require('$SIGMAP_DIR/package.json').version)" 2>/dev/null)"
fi

mkdir -p "$HOME/repos" "$HOME/results/raw" "$HOME/results/exports" "$HOME/results/reports"
log "  ✓ working dirs ready ($HOME/repos, $HOME/results)"
log "Setup complete."
