#!/bin/bash
# =============================================================================
# SigMap Phase 1 Validation — Re-clone + Pending Benchmarks + JVM Validation
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[PHASE1]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

REPOS_DIR="$HOME/repos"
RAW_DIR="$HOME/results/raw"
TIMEOUT_SECS=180          # increased from 120s for large repos
PARALLEL_JOBS=4

mkdir -p "$RAW_DIR"

# =============================================================================
# STEP 1: Check current clone status
# =============================================================================
log "STEP 1: Analyzing current clone status..."

TOTAL_EXPECTED=180
CLONED=$(find "$REPOS_DIR" -maxdepth 1 -type d -not -name "$REPOS_DIR" | wc -l)
log "Currently cloned: $CLONED / $TOTAL_EXPECTED"

if [ "$CLONED" -lt 180 ]; then
  MISSING=$((TOTAL_EXPECTED - CLONED))
  warn "$MISSING repos still missing — re-clone recommended"
else
  log "✅ All 180 repos present"
fi

# =============================================================================
# STEP 2: Check benchmark coverage
# =============================================================================
log ""
log "STEP 2: Analyzing benchmark coverage..."

BENCHMARKED=$(find "$RAW_DIR" -name "meta.json" | wc -l)
PENDING=$((CLONED - BENCHMARKED))

log "Benchmarked: $BENCHMARKED / $CLONED"
if [ "$PENDING" -gt 0 ]; then
  warn "$PENDING repos cloned but not yet benchmarked"
  log "These will be processed in Step 3"
fi

# =============================================================================
# STEP 3: Validate JVM monorepo fixes
# =============================================================================
log ""
log "STEP 3: Validating JVM monorepo fixes..."

check_repo_tokens() {
  local repo=$1
  if [ -f "$RAW_DIR/$repo/analyze.json" ]; then
    local tokens=$(jq '.summary.tokenCount // 0' "$RAW_DIR/$repo/analyze.json" 2>/dev/null || echo "ERROR")
    if [ "$tokens" -eq 0 ]; then
      err "  $repo: 0 tokens (BROKEN)"
      return 1
    elif [ "$tokens" -lt 0 ]; then
      err "  $repo: $tokens tokens (INVALID)"
      return 1
    else
      log "  $repo: $tokens tokens ✅"
      return 0
    fi
  else
    warn "  $repo: not benchmarked yet"
    return 0
  fi
}

CRITICAL_REPOS=("spring-boot" "ktor" "android-arch" "elasticsearch" "spring-framework" "kafka")
JVM_PASS=0
JVM_FAIL=0

for repo in "${CRITICAL_REPOS[@]}"; do
  if check_repo_tokens "$repo"; then
    ((JVM_PASS++))
  else
    ((JVM_FAIL++))
  fi
done

log ""
log "JVM validation: $JVM_PASS passed, $JVM_FAIL failed"

# =============================================================================
# STEP 4: Summary & recommendations
# =============================================================================
log ""
log "=== PHASE 1 STATUS REPORT ==="
log "Clone completion: $CLONED / $TOTAL_EXPECTED ($(( CLONED * 100 / TOTAL_EXPECTED ))%)"
log "Benchmark completion: $BENCHMARKED / $CLONED ($(( BENCHMARKED * 100 / CLONED ))%)"
log "JVM monorepo validation: $JVM_PASS / ${#CRITICAL_REPOS[@]} passed"

if [ "$JVM_FAIL" -gt 0 ]; then
  err "⚠️  JVM validation FAILED — some repos still showing 0 tokens"
  info "Run: DEBUG=sigmap:* node $HOME/sigmap/gen-context.js --analyze --json < $HOME/repos/REPO_NAME/ 2>&1 | head -50"
  exit 1
fi

if [ "$PENDING" -eq 0 ] && [ "$CLONED" -eq "$TOTAL_EXPECTED" ] && [ "$JVM_FAIL" -eq 0 ]; then
  log ""
  log "✅ PHASE 1 COMPLETE"
  log "  • All repos cloned"
  log "  • All repos benchmarked"
  log "  • JVM fixes validated"
  log ""
  info "Next: Proceed to Phase 2 (Analysis Deepening)"
  info "Execute: bash 04_aggregate_results.js"
  exit 0
else
  log ""
  warn "⚠️  PHASE 1 INCOMPLETE"
  [ "$PENDING" -gt 0 ] && info "  → $PENDING repos need benchmarking"
  [ "$CLONED" -lt "$TOTAL_EXPECTED" ] && info "  → $MISSING repos need cloning"
  [ "$JVM_FAIL" -gt 0 ] && info "  → $JVM_FAIL JVM repos need debugging"
  exit 1
fi
