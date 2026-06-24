#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — RUN ALL (Steps 1–5 in sequence)
# Copy this entire folder to your GCP VM and run:
#   chmod +x *.sh && ./run_all.sh 2>&1 | tee benchmark.log
# =============================================================================

set -e
BOLD='\033[1m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

header() {
  echo ""
  echo -e "${BOLD}${CYAN}════════════════════════════════════════${NC}"
  echo -e "${BOLD}${GREEN}  $1${NC}"
  echo -e "${BOLD}${CYAN}════════════════════════════════════════${NC}"
  echo ""
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

header "STEP 1/4 — Setup (deps + SigMap engine + dirs)"
bash "$SCRIPT_DIR/01_setup.sh"

header "STEP 2/4 — Clone repos"
bash "$SCRIPT_DIR/02_clone_repos.sh"

header "STEP 3/4 — Run benchmarks (per repo → ~/results/raw)"
bash "$SCRIPT_DIR/03_run_benchmarks.sh"

header "STEP 4/4 — Aggregate (exports + reports)"
node "$SCRIPT_DIR/aggregate.mjs"

echo ""
echo -e "${BOLD}${GREEN}🎉 Full benchmark suite complete!${NC}"
echo "   Exports: ~/results/exports/results.{csv,json,jsonl}"
echo "   Report : ~/results/reports/report.md"
echo "   Table  : ~/results/reports/academic_table.md"
echo ""
echo "   (Optional GCS upload: bash $SCRIPT_DIR/05_upload_results.sh)"
