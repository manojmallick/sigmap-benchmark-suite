#!/bin/bash
# =============================================================================
# Push SigMap Benchmark Reports to Google Cloud Storage
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[GCS]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

# =============================================================================
# Configuration
# =============================================================================

GCS_BUCKET="${GCS_BUCKET:-sigmap-benchmarks}"
GCS_PROJECT="${GCS_PROJECT:-sigmap-project}"
LOCAL_REPORTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%s)

# Reports to upload
REPORTS=(
  "COMPREHENSIVE_REPO_METRICS.csv"
  "FINAL_REPORT_ALL_REPOS.md"
  "BENCHMARK_ANALYSIS_EXTENDED.md"
  "PHASE_1_ACTION_PLAN.md"
  "README_EXTENDED_BENCHMARK.md"
)

# =============================================================================
# Checks
# =============================================================================

log "Checking prerequisites..."

# Check if gcloud is installed
if ! command -v gsutil &> /dev/null; then
  err "gsutil not found. Install Google Cloud SDK:"
  err "  curl https://sdk.cloud.google.com | bash"
  exit 1
fi

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &>/dev/null; then
  warn "Not authenticated with Google Cloud. Running authentication..."
  gcloud auth login
fi

# Check if bucket exists
log "Checking GCS bucket: gs://$GCS_BUCKET/"
if ! gsutil ls "gs://$GCS_BUCKET" &>/dev/null; then
  warn "Bucket $GCS_BUCKET does not exist or not accessible"
  info "Create it with: gsutil mb gs://$GCS_BUCKET"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# =============================================================================
# Verify local files
# =============================================================================

log "Verifying local report files..."
MISSING=0
for report in "${REPORTS[@]}"; do
  file="$LOCAL_REPORTS_DIR/$report"
  if [ -f "$file" ]; then
    SIZE=$(du -h "$file" | cut -f1)
    log "  ✅ $report ($SIZE)"
  else
    err "  ❌ Missing: $report"
    ((MISSING++))
  fi
done

if [ "$MISSING" -gt 0 ]; then
  err "Missing $MISSING report files. Aborting."
  exit 1
fi

# =============================================================================
# Upload to GCS
# =============================================================================

log ""
log "Uploading reports to gs://$GCS_BUCKET/benchmark-results/$DATE/"
info "Timestamp: $TIMESTAMP"
echo ""

UPLOADED=0
FAILED=0

for report in "${REPORTS[@]}"; do
  file="$LOCAL_REPORTS_DIR/$report"
  gcs_path="gs://$GCS_BUCKET/benchmark-results/$DATE/$report"

  echo -n "Uploading $report..."
  if gsutil -h "Cache-Control:public, max-age=3600" cp "$file" "$gcs_path" &>/dev/null; then
    echo -e " ${GREEN}✅${NC}"
    ((UPLOADED++))
  else
    echo -e " ${RED}❌${NC}"
    ((FAILED++))
  fi
done

# =============================================================================
# Generate manifest
# =============================================================================

log ""
log "Creating manifest file..."

MANIFEST_FILE="$LOCAL_REPORTS_DIR/manifest_${DATE}_${TIMESTAMP}.json"
cat > "$MANIFEST_FILE" <<EOF
{
  "campaign": "sigmap-extended-benchmark",
  "date": "$DATE",
  "timestamp": $TIMESTAMP,
  "gcs_bucket": "$GCS_BUCKET",
  "gcs_path": "gs://$GCS_BUCKET/benchmark-results/$DATE/",
  "uploaded_files": $UPLOADED,
  "failed_files": $FAILED,
  "reports": [
    $(for report in "${REPORTS[@]}"; do echo "\"$report\","; done | sed '$ s/,$//')
  ],
  "metadata": {
    "total_repos": 159,
    "languages": 25,
    "total_tokens": 9819432,
    "total_files": 1118587,
    "success_rate": "88.3%"
  }
}
EOF

log "Manifest created: $MANIFEST_FILE"

# Upload manifest
echo -n "Uploading manifest..."
manifest_gcs="gs://$GCS_BUCKET/benchmark-results/$DATE/manifest.json"
if gsutil -h "Cache-Control:public, max-age=3600" cp "$MANIFEST_FILE" "$manifest_gcs" &>/dev/null; then
  echo -e " ${GREEN}✅${NC}"
else
  echo -e " ${RED}❌${NC}"
fi

# =============================================================================
# Summary
# =============================================================================

log ""
log "=== UPLOAD SUMMARY ==="
log "Uploaded: $UPLOADED / ${#REPORTS[@]} files"

if [ "$FAILED" -eq 0 ]; then
  log "✅ All reports successfully uploaded to GCS"
else
  warn "⚠️  $FAILED files failed to upload"
fi

log ""
log "Access your reports at:"
info "  https://console.cloud.google.com/storage/browser/$GCS_BUCKET/benchmark-results/$DATE"
log ""
log "Or download with:"
info "  gsutil -m cp -r gs://$GCS_BUCKET/benchmark-results/$DATE ~/downloads/"
log ""
log "View manifest:"
info "  gsutil cat gs://$GCS_BUCKET/benchmark-results/$DATE/manifest.json"

# =============================================================================
# Generate public URLs (if bucket is public)
# =============================================================================

log ""
info "Checking if bucket is publicly accessible..."

PUBLIC_URL_BASE="https://storage.googleapis.com/$GCS_BUCKET/benchmark-results/$DATE"

for report in "${REPORTS[@]}"; do
  PUBLIC_URL="$PUBLIC_URL_BASE/$report"
  echo "  📄 $report:"
  echo "     $PUBLIC_URL"
done

log ""
log "✅ GCS upload complete"
