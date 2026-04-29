#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 3: Run All Benchmarks (180 repos)
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

# Metadata: language map (label → language) — 180 repos
declare -A LANG_MAP=(
  # TypeScript (12)
  [typescript-compiler]=TypeScript [vscode]=TypeScript [nextjs]=TypeScript
  [nestjs]=TypeScript [prisma]=TypeScript [azure-sdk-js]=TypeScript
  [aws-cdk]=TypeScript [turborepo]=TypeScript [graphql-js]=TypeScript
  [storybook]=TypeScript [angular]=TypeScript [definitelytyped]=TypeScript

  # JavaScript (12)
  [express]=JavaScript [react]=JavaScript [webpack]=JavaScript
  [jest]=JavaScript [lodash]=JavaScript [nodejs]=JavaScript
  [ghost]=JavaScript [strapi]=JavaScript [threejs]=JavaScript
  [moment]=JavaScript [rollup]=JavaScript [esbuild]=JavaScript

  # Python (15)
  [django]=Python [flask]=Python [fastapi]=Python
  [scikit-learn]=Python [requests]=Python [pandas]=Python
  [numpy]=Python [linux-kernel]=Python [pytorch]=Python
  [tensorflow]=Python [publicapis]=Python [sqlalchemy]=Python
  [celery]=Python [httpx]=Python [aiohttp]=Python

  # Java (15)
  [spring-boot]=Java [elasticsearch]=Java [kafka]=Java [retrofit]=Java
  [rxjava]=Java [netty]=Java [grpc-java]=Java [spring-framework]=Java
  [mybatis]=Java [druid]=Java [guava]=Java [commons-lang]=Java
  [junit4]=Java [mockito]=Java [dagger]=Java

  # Kotlin (8)
  [ktor]=Kotlin [kotlin-lang]=Kotlin [android-arch]=Kotlin [okhttp]=Kotlin
  [moshi]=Kotlin [kotlinx-serialization]=Kotlin [compose-multiplatform]=Kotlin
  [leakcanary]=Kotlin

  # Go (12)
  [gin]=Go [fiber]=Go [kubernetes]=Go [terraform]=Go
  [moby]=Go [golang-core]=Go [grpc-go]=Go [prometheus]=Go
  [etcd]=Go [syncthing]=Go [teleport]=Go [cli]=Go

  # Rust (12)
  [tokio]=Rust [actix-web]=Rust [serde]=Rust [rustfmt]=Rust
  [clippy]=Rust [tauri]=Rust [starship]=Rust [fd]=Rust
  [ripgrep]=Rust [diesel]=Rust [wasm-bindgen]=Rust [rayon]=Rust

  # C# (8)
  [aspnetcore]=CSharp [efcore]=CSharp [dotnet-runtime]=CSharp
  [roslyn]=CSharp [msbuild]=CSharp [nunit]=CSharp [polly]=CSharp
  [marten]=CSharp

  # Ruby (8)
  [rails]=Ruby [sidekiq]=Ruby [devise]=Ruby [rspec]=Ruby
  [ruby-core]=Ruby [wpscan]=Ruby [chef]=Ruby [puppet]=Ruby

  # PHP (10)
  [laravel]=PHP [symfony]=PHP [composer]=PHP [php-core]=PHP
  [wordpress]=PHP [guzzle]=PHP [faker-php]=PHP [phpstan]=PHP
  [slim]=PHP [phpmailer]=PHP

  # Swift (8)
  [alamofire]=Swift [vapor]=Swift [swiftformat]=Swift [swift-core]=Swift
  [realm-swift]=Swift [alamofireimage]=Swift [swiftyjson]=Swift
  [charts-swift]=Swift

  # Dart (8)
  [flutter]=Dart [riverpod]=Dart [flutterfire]=Dart [dart-sdk]=Dart
  [getx]=Dart [isar]=Dart [bloc]=Dart [flutter-animate]=Dart

  # Scala (5)
  [spark]=Scala [akka]=Scala [play-framework]=Scala [dotty]=Scala
  [lightbend-config]=Scala

  # Vue (6)
  [vue-core]=Vue [vuetify]=Vue [nuxt]=Vue [vueuse]=Vue
  [vue-masonry]=Vue [vitest]=Vue

  # Svelte (4)
  [svelte]=Svelte [sveltekit]=Svelte [sveltepress]=Svelte
  [svelte-language-tools]=Svelte

  # HTML/CSS (5)
  [bootstrap]=HTML_CSS [tailwindcss]=CSS [foundation]=SCSS
  [html5-boilerplate]=HTML [bootstrap-css]=CSS

  # YAML (4)
  [grafana]=YAML_Mixed [ansible]=YAML_Mixed [k8s-manifests]=YAML_Mixed
  [helm-charts]=YAML_Mixed

  # Shell (4)
  [nvm]=Shell [ohmyzsh]=Shell [bats]=Shell [bat]=Shell

  # Dockerfile (4)
  [docker-official]=Dockerfile [bitnami-containers]=Dockerfile
  [docker-compose-examples]=Dockerfile [docker-best-practices]=Dockerfile

  # C (5)
  [linux]=C [vim]=C [git]=C [curl]=C [protobuf]=C++

  # Objective-C (2)
  [afnetworking]=Objective-C [sdwebimage]=Objective-C

  # Clojure (2)
  [clojure-core]=Clojure [transit-clj]=Clojure

  # Haskell (2)
  [ghc]=Haskell [cabal]=Haskell

  # Lua (2)
  [neovim]=Lua [lua-core]=Lua

  # Groovy (2)
  [gradle]=Groovy [jenkins]=Groovy

  # Additional (6)
  [apache-httpd]=C [nginx]=C [redis]=C [mongodb]=C++
  [arangodb]=C++ [dotnet-runtime]=CSharp
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
    -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.lua" \
    -o -name "*.clj" -o -name "*.hs" -o -name "*.groovy" \
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
