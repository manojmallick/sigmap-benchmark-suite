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

header "STEP 1/5 — VM Setup"
bash "$SCRIPT_DIR/01_setup_vm.sh"

header "STEP 2/5 — Clone 60+ Repos"
bash "$SCRIPT_DIR/02_clone_repos.sh"

header "STEP 3/5 — Run Benchmarks"
bash "$SCRIPT_DIR/03_run_benchmarks.sh"

header "STEP 4/5 — Aggregate Results"
node "$SCRIPT_DIR/04_aggregate_results.js"

header "STEP 5/5 — Upload to GCS"
bash "$SCRIPT_DIR/05_upload_results.sh"

echo ""
echo -e "${BOLD}${GREEN}🎉 Full benchmark suite complete!${NC}"
echo "   Check: ~/results/reports/report.md"
echo "   Check: ~/results/reports/academic_table.md"
