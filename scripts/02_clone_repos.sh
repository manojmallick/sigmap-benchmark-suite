#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 2: Clone 60+ Repos (all 21 languages)
# Uses --depth=1 for speed. Runs in parallel (8 workers).
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[CLONE]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

REPOS_DIR="$HOME/repos"
PARALLEL_JOBS=8   # tune down if bandwidth is limited

# =============================================================================
# 60+ repos — one or more per sigmap language
# Format: "URL  LABEL  LANGUAGE"
# =============================================================================
declare -a REPOS=(

  # ── TypeScript (5) ──────────────────────────────────────────────────────────
  "https://github.com/microsoft/TypeScript           typescript-compiler     TypeScript"
  "https://github.com/microsoft/vscode               vscode                  TypeScript"
  "https://github.com/vercel/next.js                 nextjs                  TypeScript"
  "https://github.com/nestjs/nest                    nestjs                  TypeScript"
  "https://github.com/prisma/prisma                  prisma                  TypeScript"

  # ── JavaScript (5) ──────────────────────────────────────────────────────────
  "https://github.com/expressjs/express               express                 JavaScript"
  "https://github.com/facebook/react                  react                   JavaScript"
  "https://github.com/webpack/webpack                 webpack                 JavaScript"
  "https://github.com/jestjs/jest                     jest                    JavaScript"
  "https://github.com/lodash/lodash                   lodash                  JavaScript"

  # ── Python (5) ──────────────────────────────────────────────────────────────
  "https://github.com/django/django                   django                  Python"
  "https://github.com/pallets/flask                   flask                   Python"
  "https://github.com/tiangolo/fastapi                fastapi                 Python"
  "https://github.com/scikit-learn/scikit-learn       scikit-learn            Python"
  "https://github.com/psf/requests                    requests                Python"

  # ── Java (4) ────────────────────────────────────────────────────────────────
  "https://github.com/spring-projects/spring-boot     spring-boot             Java"
  "https://github.com/elastic/elasticsearch           elasticsearch           Java"
  "https://github.com/apache/kafka                    kafka                   Java"
  "https://github.com/square/retrofit                 retrofit                Java"

  # ── Kotlin (3) ──────────────────────────────────────────────────────────────
  "https://github.com/ktorio/ktor                     ktor                    Kotlin"
  "https://github.com/JetBrains/kotlin               kotlin-lang             Kotlin"
  "https://github.com/android/architecture-samples   android-arch            Kotlin"

  # ── Go (4) ──────────────────────────────────────────────────────────────────
  "https://github.com/gin-gonic/gin                   gin                     Go"
  "https://github.com/gofiber/fiber                   fiber                   Go"
  "https://github.com/kubernetes/kubernetes           kubernetes              Go"
  "https://github.com/hashicorp/terraform             terraform               Go"

  # ── Rust (4) ────────────────────────────────────────────────────────────────
  "https://github.com/tokio-rs/tokio                  tokio                   Rust"
  "https://github.com/actix/actix-web                 actix-web               Rust"
  "https://github.com/serde-rs/serde                  serde                   Rust"
  "https://github.com/rust-lang/rustfmt               rustfmt                 Rust"

  # ── C# (3) ──────────────────────────────────────────────────────────────────
  "https://github.com/dotnet/aspnetcore               aspnetcore              CSharp"
  "https://github.com/dotnet/efcore                   efcore                  CSharp"

  # ── Ruby (3) ────────────────────────────────────────────────────────────────
  "https://github.com/rails/rails                     rails                   Ruby"
  "https://github.com/mperham/sidekiq                 sidekiq                 Ruby"
  "https://github.com/heartcombo/devise               devise                  Ruby"

  # ── PHP (3) ─────────────────────────────────────────────────────────────────
  "https://github.com/laravel/laravel                 laravel                 PHP"
  "https://github.com/symfony/symfony                 symfony                 PHP"
  "https://github.com/composer/composer               composer                PHP"

  # ── Swift (3) ───────────────────────────────────────────────────────────────
  "https://github.com/Alamofire/Alamofire             alamofire               Swift"
  "https://github.com/vapor/vapor                     vapor                   Swift"
  "https://github.com/nicklockwood/SwiftFormat        swiftformat             Swift"

  # ── Dart / Flutter (3) ──────────────────────────────────────────────────────
  "https://github.com/flutter/flutter                 flutter                 Dart"
  "https://github.com/rrousselGit/riverpod            riverpod                Dart"

  # ── Scala (2) ───────────────────────────────────────────────────────────────
  "https://github.com/apache/spark                    spark                   Scala"
  "https://github.com/akka/akka                       akka                    Scala"

  # ── Vue (3) ─────────────────────────────────────────────────────────────────
  "https://github.com/vuejs/core                      vue-core                Vue"
  "https://github.com/vuetifyjs/vuetify               vuetify                 Vue"
  "https://github.com/nuxt/nuxt                       nuxt                    Vue"

  # ── Svelte (2) ──────────────────────────────────────────────────────────────
  "https://github.com/sveltejs/svelte                 svelte                  Svelte"
  "https://github.com/sveltejs/kit                    sveltekit               Svelte"

  # ── HTML / CSS / SCSS (3) ───────────────────────────────────────────────────
  "https://github.com/twbs/bootstrap                  bootstrap               HTML_CSS"
  "https://github.com/tailwindlabs/tailwindcss        tailwindcss             CSS"
  "https://github.com/foundation/foundation-sites     foundation              SCSS"

  # ── YAML-heavy (2) ──────────────────────────────────────────────────────────
  "https://github.com/grafana/grafana                 grafana                 YAML_Mixed"
  "https://github.com/ansible/ansible                 ansible                 YAML_Mixed"

  # ── Shell (2) ───────────────────────────────────────────────────────────────
  "https://github.com/nvm-sh/nvm                      nvm                     Shell"
  "https://github.com/ohmyzsh/ohmyzsh                 ohmyzsh                 Shell"

  # ── Dockerfile-heavy (2) ────────────────────────────────────────────────────
  "https://github.com/docker-library/official-images  docker-official         Dockerfile"
  "https://github.com/bitnami/containers              bitnami-containers      Dockerfile"

  # ── Mixed / Large monorepos (3) ─────────────────────────────────────────────
  "https://github.com/microsoft/azure-sdk-for-js      azure-sdk-js            TypeScript"
  "https://github.com/aws/aws-cdk                     aws-cdk                 TypeScript"
  "https://github.com/vercel/turborepo                turborepo               TypeScript"
)

TOTAL=${#REPOS[@]}
log "Cloning $TOTAL repos with $PARALLEL_JOBS parallel workers..."
info "Destination: $REPOS_DIR"
echo ""

# ── Clone function (called in parallel) ────────────────────────────────────
clone_repo() {
  local url="$1"
  local label="$2"
  local lang="$3"
  local dest="$REPOS_DIR/$label"

  if [ -d "$dest/.git" ]; then
    echo "[SKIP] $label — already cloned"
    return 0
  fi

  if git clone --depth=1 --single-branch -q "$url" "$dest" 2>/dev/null; then
    echo "[OK]   $label ($lang)"
  else
    echo "[FAIL] $label — clone failed, skipping"
  fi
}

export -f clone_repo
export REPOS_DIR

# ── Run parallel clones ────────────────────────────────────────────────────
echo "${REPOS[@]}" | tr ' ' '\n' | paste - - - | \
  xargs -P "$PARALLEL_JOBS" -n 3 bash -c 'clone_repo "$@"' _

echo ""
CLONED=$(find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)
log "✅ Clone complete: $CLONED / $TOTAL repos ready"
info "Next step: run  03_run_benchmarks.sh"
