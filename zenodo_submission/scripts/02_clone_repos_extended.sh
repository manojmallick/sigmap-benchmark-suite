#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Step 2: Clone 200+ Repos (all 21+ languages)
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
# 200+ repos — expanded for comprehensive language coverage
# Format: "URL  LABEL  LANGUAGE"
# =============================================================================
declare -a REPOS=(

  # ── TypeScript (12) ────────────────────────────────────────────────────────
  "https://github.com/microsoft/TypeScript           typescript-compiler     TypeScript"
  "https://github.com/microsoft/vscode               vscode                  TypeScript"
  "https://github.com/vercel/next.js                 nextjs                  TypeScript"
  "https://github.com/nestjs/nest                    nestjs                  TypeScript"
  "https://github.com/prisma/prisma                  prisma                  TypeScript"
  "https://github.com/microsoft/azure-sdk-for-js    azure-sdk-js            TypeScript"
  "https://github.com/aws/aws-cdk                    aws-cdk                 TypeScript"
  "https://github.com/vercel/turborepo               turborepo               TypeScript"
  "https://github.com/graphql/graphql-js             graphql-js              TypeScript"
  "https://github.com/storybookjs/storybook          storybook               TypeScript"
  "https://github.com/angular/angular                angular                 TypeScript"
  "https://github.com/DefinitelyTyped/DefinitelyTyped  definitelytyped      TypeScript"

  # ── JavaScript (12) ────────────────────────────────────────────────────────
  "https://github.com/expressjs/express              express                 JavaScript"
  "https://github.com/facebook/react                 react                   JavaScript"
  "https://github.com/webpack/webpack                webpack                 JavaScript"
  "https://github.com/jestjs/jest                    jest                    JavaScript"
  "https://github.com/lodash/lodash                  lodash                  JavaScript"
  "https://github.com/nodejs/node                    nodejs                  JavaScript"
  "https://github.com/TryGhost/Ghost                 ghost                   JavaScript"
  "https://github.com/strapi/strapi                  strapi                  JavaScript"
  "https://github.com/mrdoob/three.js                threejs                 JavaScript"
  "https://github.com/moment/moment                  moment                  JavaScript"
  "https://github.com/rollup/rollup                  rollup                  JavaScript"
  "https://github.com/evanw/esbuild                  esbuild                 JavaScript"

  # ── Python (15) ────────────────────────────────────────────────────────────
  "https://github.com/django/django                  django                  Python"
  "https://github.com/pallets/flask                  flask                   Python"
  "https://github.com/tiangolo/fastapi               fastapi                 Python"
  "https://github.com/scikit-learn/scikit-learn      scikit-learn            Python"
  "https://github.com/psf/requests                   requests                Python"
  "https://github.com/pandas-dev/pandas              pandas                  Python"
  "https://github.com/numpy/numpy                    numpy                   Python"
  "https://github.com/torvalds/linux                 linux-kernel            Python"
  "https://github.com/pytorch/pytorch                pytorch                 Python"
  "https://github.com/tensorflow/tensorflow          tensorflow              Python"
  "https://github.com/public-apis/public-apis        publicapis              Python"
  "https://github.com/sqlalchemy/sqlalchemy          sqlalchemy              Python"
  "https://github.com/celery/celery                  celery                  Python"
  "https://github.com/encode/httpx                   httpx                   Python"
  "https://github.com/aio-libs/aiohttp               aiohttp                 Python"

  # ── Java (15) ──────────────────────────────────────────────────────────────
  "https://github.com/spring-projects/spring-boot    spring-boot             Java"
  "https://github.com/elastic/elasticsearch          elasticsearch           Java"
  "https://github.com/apache/kafka                   kafka                   Java"
  "https://github.com/square/retrofit                retrofit                Java"
  "https://github.com/ReactiveX/RxJava               rxjava                  Java"
  "https://github.com/netty/netty                    netty                   Java"
  "https://github.com/grpc/grpc-java                 grpc-java               Java"
  "https://github.com/spring-projects/spring-framework  spring-framework      Java"
  "https://github.com/mybatis/mybatis-3              mybatis                 Java"
  "https://github.com/alibaba/druid                  druid                   Java"
  "https://github.com/google/guava                   guava                   Java"
  "https://github.com/apache/commons-lang            commons-lang            Java"
  "https://github.com/junit-team/junit4              junit4                  Java"
  "https://github.com/mockito/mockito                mockito                 Java"
  "https://github.com/google/dagger                  dagger                  Java"

  # ── Kotlin (8) ─────────────────────────────────────────────────────────────
  "https://github.com/ktorio/ktor                    ktor                    Kotlin"
  "https://github.com/JetBrains/kotlin              kotlin-lang             Kotlin"
  "https://github.com/android/architecture-samples   android-arch            Kotlin"
  "https://github.com/square/okhttp                  okhttp                  Kotlin"
  "https://github.com/square/moshi                   moshi                   Kotlin"
  "https://github.com/Kotlin/kotlinx.serialization   kotlinx-serialization   Kotlin"
  "https://github.com/JetBrains/compose-multiplatform  compose-multiplatform Kotlin"
  "https://github.com/square/leakcanary              leakcanary              Kotlin"

  # ── Go (12) ────────────────────────────────────────────────────────────────
  "https://github.com/gin-gonic/gin                  gin                     Go"
  "https://github.com/gofiber/fiber                  fiber                   Go"
  "https://github.com/kubernetes/kubernetes          kubernetes              Go"
  "https://github.com/hashicorp/terraform            terraform               Go"
  "https://github.com/docker/moby                    moby                    Go"
  "https://github.com/golang/go                      golang-core             Go"
  "https://github.com/grpc/grpc-go                   grpc-go                 Go"
  "https://github.com/prometheus/prometheus          prometheus              Go"
  "https://github.com/etcd-io/etcd                   etcd                    Go"
  "https://github.com/syncthing/syncthing            syncthing               Go"
  "https://github.com/gravitational/teleport         teleport                Go"
  "https://github.com/urfave/cli                     cli                     Go"

  # ── Rust (12) ──────────────────────────────────────────────────────────────
  "https://github.com/tokio-rs/tokio                 tokio                   Rust"
  "https://github.com/actix/actix-web                actix-web               Rust"
  "https://github.com/serde-rs/serde                 serde                   Rust"
  "https://github.com/rust-lang/rustfmt              rustfmt                 Rust"
  "https://github.com/rust-lang/clippy               clippy                  Rust"
  "https://github.com/tauri-apps/tauri               tauri                   Rust"
  "https://github.com/starship/starship              starship                Rust"
  "https://github.com/sharkdp/fd                     fd                      Rust"
  "https://github.com/BurntSushi/ripgrep             ripgrep                 Rust"
  "https://github.com/diesel-rs/diesel               diesel                  Rust"
  "https://github.com/rustwasm/wasm-bindgen          wasm-bindgen            Rust"
  "https://github.com/rayon-rs/rayon                 rayon                   Rust"

  # ── C# (8) ─────────────────────────────────────────────────────────────────
  "https://github.com/dotnet/aspnetcore              aspnetcore              CSharp"
  "https://github.com/dotnet/efcore                  efcore                  CSharp"
  "https://github.com/dotnet/runtime                 dotnet-runtime          CSharp"
  "https://github.com/dotnet/roslyn                  roslyn                  CSharp"
  "https://github.com/microsoft/msbuild              msbuild                 CSharp"
  "https://github.com/NUnit/nunit                    nunit                   CSharp"
  "https://github.com/App-vNext/Polly                polly                   CSharp"
  "https://github.com/JasperFx/marten                marten                  CSharp"

  # ── Ruby (8) ───────────────────────────────────────────────────────────────
  "https://github.com/rails/rails                    rails                   Ruby"
  "https://github.com/mperham/sidekiq                sidekiq                 Ruby"
  "https://github.com/heartcombo/devise              devise                  Ruby"
  "https://github.com/rspec/rspec                    rspec                   Ruby"
  "https://github.com/ruby/ruby                      ruby-core               Ruby"
  "https://github.com/wpscanteam/wpscan              wpscan                  Ruby"
  "https://github.com/chef/chef                      chef                    Ruby"
  "https://github.com/puppetlabs/puppet              puppet                  Ruby"

  # ── PHP (10) ───────────────────────────────────────────────────────────────
  "https://github.com/laravel/laravel                laravel                 PHP"
  "https://github.com/symfony/symfony                symfony                 PHP"
  "https://github.com/composer/composer              composer                PHP"
  "https://github.com/php/php-src                    php-core                PHP"
  "https://github.com/WordPress/WordPress            wordpress               PHP"
  "https://github.com/guzzle/guzzle                  guzzle                  PHP"
  "https://github.com/fzaninotto/Faker               faker-php               PHP"
  "https://github.com/phpstan/phpstan                phpstan                 PHP"
  "https://github.com/slimphp/slim                   slim                    PHP"
  "https://github.com/PHPMailer/PHPMailer            phpmailer               PHP"

  # ── Swift (8) ──────────────────────────────────────────────────────────────
  "https://github.com/Alamofire/Alamofire            alamofire               Swift"
  "https://github.com/vapor/vapor                    vapor                   Swift"
  "https://github.com/nicklockwood/SwiftFormat       swiftformat             Swift"
  "https://github.com/apple/swift                    swift-core              Swift"
  "https://github.com/realm/realm-swift              realm-swift             Swift"
  "https://github.com/Alamofire/AlamofireImage       alamofireimage          Swift"
  "https://github.com/SwiftyJSON/SwiftyJSON          swiftyjson              Swift"
  "https://github.com/danielgindi/Charts             charts-swift            Swift"

  # ── Dart / Flutter (8) ─────────────────────────────────────────────────────
  "https://github.com/flutter/flutter                flutter                 Dart"
  "https://github.com/rrousselGit/riverpod           riverpod                Dart"
  "https://github.com/flutterfire/flutterfire        flutterfire             Dart"
  "https://github.com/dart-lang/sdk                  dart-sdk                Dart"
  "https://github.com/google/get                     getx                    Dart"
  "https://github.com/isar/isar                      isar                    Dart"
  "https://github.com/felangel/bloc                  bloc                    Dart"
  "https://github.com/gskinner/flutter_animate       flutter-animate         Dart"

  # ── Scala (5) ──────────────────────────────────────────────────────────────
  "https://github.com/apache/spark                   spark                   Scala"
  "https://github.com/akka/akka                      akka                    Scala"
  "https://github.com/playframework/playframework    play-framework          Scala"
  "https://github.com/lampepfl/dotty                 dotty                   Scala"
  "https://github.com/lightbend/config               lightbend-config        Scala"

  # ── Vue (6) ────────────────────────────────────────────────────────────────
  "https://github.com/vuejs/core                     vue-core                Vue"
  "https://github.com/vuetifyjs/vuetify              vuetify                 Vue"
  "https://github.com/nuxt/nuxt                      nuxt                    Vue"
  "https://github.com/vueuse/vueuse                  vueuse                  Vue"
  "https://github.com/vue-masonry/vue-masonry-css   vue-masonry             Vue"
  "https://github.com/vitest-dev/vitest              vitest                  Vue"

  # ── Svelte (4) ────────────────────────────────────────────────────────────
  "https://github.com/sveltejs/svelte                svelte                  Svelte"
  "https://github.com/sveltejs/kit                   sveltekit               Svelte"
  "https://github.com/sveltepress/sveltepress        sveltepress             Svelte"
  "https://github.com/sveltejs/language-tools        svelte-language-tools   Svelte"

  # ── HTML / CSS / SCSS (5) ──────────────────────────────────────────────────
  "https://github.com/twbs/bootstrap                 bootstrap               HTML_CSS"
  "https://github.com/tailwindlabs/tailwindcss       tailwindcss             CSS"
  "https://github.com/foundation/foundation-sites    foundation              SCSS"
  "https://github.com/h5bp/html5-boilerplate        html5-boilerplate       HTML"
  "https://github.com/getbootstrap/bootstrap-css     bootstrap-css           CSS"

  # ── YAML-heavy (4) ────────────────────────────────────────────────────────
  "https://github.com/grafana/grafana                grafana                 YAML_Mixed"
  "https://github.com/ansible/ansible                ansible                 YAML_Mixed"
  "https://github.com/kubernetes/kubernetes         k8s-manifests           YAML_Mixed"
  "https://github.com/prometheus-community/helm-charts  helm-charts          YAML_Mixed"

  # ── Shell (4) ──────────────────────────────────────────────────────────────
  "https://github.com/nvm-sh/nvm                     nvm                     Shell"
  "https://github.com/ohmyzsh/ohmyzsh                ohmyzsh                 Shell"
  "https://github.com/bats-core/bats-core            bats                    Shell"
  "https://github.com/sharkdp/bat                    bat                     Shell"

  # ── Dockerfile-heavy (4) ───────────────────────────────────────────────────
  "https://github.com/docker-library/official-images  docker-official        Dockerfile"
  "https://github.com/bitnami/containers             bitnami-containers      Dockerfile"
  "https://github.com/docker/awesome-compose        docker-compose-examples Dockerfile"
  "https://github.com/good-docker/docker-compose    docker-best-practices   Dockerfile"

  # ── C/C++ (5) ──────────────────────────────────────────────────────────────
  "https://github.com/torvalds/linux                 linux                   C"
  "https://github.com/vim/vim                        vim                     C"
  "https://github.com/git/git                        git                     C"
  "https://github.com/curl/curl                      curl                    C"
  "https://github.com/protocolbuffers/protobuf       protobuf                C++"

  # ── Objective-C / Swift (2) ────────────────────────────────────────────────
  "https://github.com/AFNetworking/AFNetworking      afnetworking            Objective-C"
  "https://github.com/SDWebImage/SDWebImage          sdwebimage              Objective-C"

  # ── Clojure / Lisp (2) ────────────────────────────────────────────────────
  "https://github.com/clojure/clojure                clojure-core            Clojure"
  "https://github.com/cognitect/transit-clj          transit-clj             Clojure"

  # ── Haskell (2) ───────────────────────────────────────────────────────────
  "https://github.com/ghc/ghc                        ghc                     Haskell"
  "https://github.com/haskell/cabal                  cabal                   Haskell"

  # ── Lua (2) ────────────────────────────────────────────────────────────────
  "https://github.com/neovim/neovim                  neovim                  Lua"
  "https://github.com/lua/lua                        lua-core                Lua"

  # ── Groovy / Gradle (2) ────────────────────────────────────────────────────
  "https://github.com/gradle/gradle                  gradle                  Groovy"
  "https://github.com/jenkinsci/jenkins              jenkins                 Groovy"

  # ── Additional popular frameworks/libs ──────────────────────────────────────
  "https://github.com/apache/httpd                   apache-httpd            C"
  "https://github.com/nginx/nginx                    nginx                   C"
  "https://github.com/redis/redis                    redis                   C"
  "https://github.com/mongodb/mongo                  mongodb                 C++"
  "https://github.com/arangodb/arangodb              arangodb                C++"
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
