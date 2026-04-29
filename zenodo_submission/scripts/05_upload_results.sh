#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 5: Upload to GCS + Print Summary
# =============================================================================

set -e
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'

log()  { echo -e "${GREEN}[UPLOAD]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

BUCKET="sigmap-benchmark-results"
RUN_ID="run-$(date +%Y%m%d-%H%M%S)"
GCS_PATH="gs://$BUCKET/$RUN_ID"

log "Uploading results to $GCS_PATH ..."

# Upload raw JSON results
gcloud storage cp -r "$HOME/results/raw/*" "$GCS_PATH/raw/"
gcloud storage cp -r "$HOME/results/summary/*" "$GCS_PATH/summary/"
gcloud storage cp -r "$HOME/results/reports/*" "$GCS_PATH/reports/"

log "✅ Upload complete!"
echo ""

# ── Print summary from master.json ──────────────────────────────────────────
MASTER="$HOME/results/summary/master.json"
if command -v jq &>/dev/null && [ -f "$MASTER" ]; then
  info "══════════════════════════════════════════════════"
  info "  SIGMAP BENCHMARK SUMMARY"
  info "══════════════════════════════════════════════════"
  echo ""
  echo "  Total repos:        $(jq '.total_repos' "$MASTER")"
  echo "  Avg reduction:      $(jq '.aggregate.avg_reduction_pct // "N/A"' "$MASTER")%"
  echo "  Median reduction:   $(jq '.aggregate.median_reduction_pct // "N/A"' "$MASTER")%"
  echo "  Best reduction:     $(jq '.aggregate.best_reduction // "N/A"' "$MASTER")% ($(jq -r '.aggregate.best_reduction_repo // "N/A"' "$MASTER"))"
  echo "  Avg hit@5:          $(jq '.aggregate.avg_hit_at_5 // "N/A"' "$MASTER")"
  echo "  Avg MRR:            $(jq '.aggregate.avg_mrr // "N/A"' "$MASTER")"
  echo "  Avg health score:   $(jq '.aggregate.avg_health // "N/A"' "$MASTER")"
  echo "  Avg context gen:    $(jq '.aggregate.avg_context_gen_ms // "N/A"' "$MASTER")ms"
  echo ""
  info "  Top 5 by token reduction:"
  jq -r '.records | sort_by(-.reduction_pct) | .[0:5] | .[] | "  \(.repo) (\(.language)): \(.reduction_pct // "N/A")%"' "$MASTER"
  echo ""
  info "══════════════════════════════════════════════════"
fi

echo ""
log "Results available at:"
echo "  GCS:      $GCS_PATH"
echo "  Local MD: $HOME/results/reports/report.md"
echo "  Academic: $HOME/results/reports/academic_table.md"
echo "  CSV:      $HOME/results/reports/report.csv"
echo ""
warn "💡 Download files locally with:"
echo "  gcloud storage cp -r $GCS_PATH/reports ./sigmap-bench-results"
