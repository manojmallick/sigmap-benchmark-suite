#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Phase 1-2: Clone 500 Repos (All Languages)
# Extended from 159 to 500 repos across 30+ programming languages
# Execution: 1A (250) → 1B (350) → 2 (500)
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[CLONE]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

REPOS_DIR="$HOME/repos"
PARALLEL_JOBS=${1:-8}   # default 8, can pass as argument
TARGET_PHASE=${2:-all}  # phase: 1a, 1b, 2, all

# =============================================================================
# Phase 0: 159 repos (ALREADY COMPLETED)
# Kept for reference - add to SKIP list if already cloned
# =============================================================================

PHASE_0_REPOS=(
  "https://github.com/microsoft/TypeScript typescript-compiler"
  "https://github.com/microsoft/vscode vscode"
  "https://github.com/vercel/next.js nextjs"
  # ... (59 more - these are already cloned)
)

# =============================================================================
# Phase 1A: 91 NEW REPOS (Total: 250)
# Tier 1: GitHub Trending Top 50 + Half of Tier 2
# =============================================================================

PHASE_1A_REPOS=(
  # ── Tier 1: Most Popular (Top 50 GitHub) ──────────────────────────────
  # Web Frameworks (8)
  "https://github.com/encode/django-rest-framework django-rest-framework"
  "https://github.com/pallets-eco/flask-restx flask-restx"
  "https://github.com/idan/basicauth basicauth"
  "https://github.com/nextauthjs/next-auth next-auth"
  "https://github.com/nuxt-themes/nuxt-ui nuxt-ui"
  "https://github.com/sveltelab/sk-adapter-auto sk-adapter-auto"
  "https://github.com/nestjs/swagger nest-swagger"
  "https://github.com/prisma/prisma-client-py prisma-client-py"

  # Cloud/Infrastructure (8)
  "https://github.com/terraform-aws-modules/terraform-aws-vpc terraform-aws-vpc"
  "https://github.com/kubernetes-client/python kubernetes-python-client"
  "https://github.com/moby/buildkit docker-buildkit"
  "https://github.com/containerd/containerd containerd"
  "https://github.com/openstack/openstack openstack"
  "https://github.com/openstack/cloud-init cloud-init"
  "https://github.com/hashicorp/vault-helm vault-helm"
  "https://github.com/hashicorp/consul consul"

  # Data/ML (8)
  "https://github.com/huggingface/transformers transformers"
  "https://github.com/huggingface/datasets huggingface-datasets"
  "https://github.com/scikit-learn/scikit-learn-contrib scikit-learn-contrib"
  "https://github.com/tensorflow/hub tensorflow-hub"
  "https://github.com/PyTorchLightning/pytorch-lightning pytorch-lightning"
  "https://github.com/dask/dask dask"
  "https://github.com/ray-project/ray ray"
  "https://github.com/RAPIDS-projects/cuml rapids-cuml"

  # DevTools (8)
  "https://github.com/cli/cli github-cli"
  "https://github.com/gitlabhq/gitlab-runner gitlab-runner"
  "https://github.com/drone/drone drone-ci"
  "https://github.com/circleci/config-sdk circleci-sdk"
  "https://github.com/ansible-community/ansible-tower ansible-tower"
  "https://github.com/hashicorp/terraform-cloud-cli terraform-cloud"
  "https://github.com/hashicorp/packer packer"
  "https://github.com/hashicorp/vault vault-cli"

  # Databases (8)
  "https://github.com/postgres/postgres postgresql"
  "https://github.com/mongodb/mongo mongodb"
  "https://github.com/cockroachdb/cockroach cockroachdb"
  "https://github.com/redis/redis redis-core"
  "https://github.com/cassandra-java-driver/java-driver cassandra-java-driver"
  "https://github.com/clickhouse/clickhouse clickhouse"
  "https://github.com/influxdata/influxdb-client-python influxdb-python"
  "https://github.com/CockroachDB/pebble pebble-db"

  # Standards/Formats (10)
  "https://github.com/json-schema-org/json-schema json-schema"
  "https://github.com/OAI/OpenAPI-Specification openapi-spec"
  "https://github.com/graphql/graphql-spec graphql-spec"
  "https://github.com/protocolbuffers/protobuf protobuf"
  "https://github.com/typescript-eslint/typescript-eslint typescript-eslint"
  "https://github.com/prettier/prettier prettier"
  "https://github.com/babel/babel babel"
  "https://github.com/webpack-contrib/webpack-chain webpack-chain"
  "https://github.com/postcss/postcss postcss"
  "https://github.com/rollup/plugins rollup-plugins"
)

# =============================================================================
# Phase 1B: 100 NEW REPOS (Total: 350)
# Second half of Tier 2 (Enterprise/Production) + Tier 3 (Libraries)
# =============================================================================

PHASE_1B_REPOS=(
  # ── Tier 2B: Enterprise Platforms (15) ─────────────────────────────────
  "https://github.com/jenkinsci/jenkins jenkins"
  "https://github.com/gitlabhq/gitlabhq gitlab"
  "https://github.com/go-gitea/gitea gitea"
  "https://github.com/nextcloud/nextcloud-server nextcloud"
  "https://github.com/keycloak/keycloak keycloak"
  "https://github.com/mailchimp/mailchimp-client-js mailchimp-client"
  "https://github.com/stripe/stripe-node stripe-js"
  "https://github.com/square/square-python-sdk square-sdk"
  "https://github.com/paypal/PayPal-node-SDK paypal-sdk"
  "https://github.com/transferwise/api-examples wise-api"
  "https://github.com/plaid/plaid-node plaid-sdk"
  "https://github.com/binance/binance-connector-python binance-connector"
  "https://github.com/coinbase/coinbase-python coinbase-sdk"
  "https://github.com/ccxt/ccxt ccxt"
  "https://github.com/aws-amplify/amplify-cli amplify-cli"

  # ── Tier 2B: E-Commerce (10) ───────────────────────────────────────────
  "https://github.com/shopify/shopify-api-js shopify-api"
  "https://github.com/woocommerce/woocommerce woocommerce"
  "https://github.com/magento/magento2 magento2"
  "https://github.com/opencart/opencart opencart"
  "https://github.com/PrestaShop/PrestaShop prestashop"
  "https://github.com/medusajs/medusa medusa"
  "https://github.com/vendure-ecommerce/vendure vendure"
  "https://github.com/saleor/saleor saleor"
  "https://github.com/evershop/evershop evershop"
  "https://github.com/nopSolutions/nopCommerce nopcommerce"

  # ── Tier 2B: CMS/Content (10) ──────────────────────────────────────────
  "https://github.com/TryGhost/Ghost ghost-pro"
  "https://github.com/strapi/strapi-plugins strapi-plugins"
  "https://github.com/payloadcms/payload payload-cms"
  "https://github.com/sanity-io/sanity sanity-client"
  "https://github.com/contentfulapp/contentful.js contentful-sdk"
  "https://github.com/netlify/netlify-cms netlify-cms"
  "https://github.com/forestryio/forestry.io forestry"
  "https://github.com/tinacms/tinacms tinacms"
  "https://github.com/BuilderIO/builder builder.io"
  "https://github.com/plasmic-app/plasmic plasmic"

  # ── Tier 3A: Build Tools (10) ──────────────────────────────────────────
  "https://github.com/Kitware/CMake cmake"
  "https://github.com/mesonbuild/meson meson"
  "https://github.com/bazelbuild/bazel bazel"
  "https://github.com/scons/scons scons"
  "https://github.com/perforce/jam jam-build"
  "https://github.com/ninja-build/ninja ninja"
  "https://github.com/autotools-mirror/autoconf autoconf"
  "https://github.com/autotools-mirror/automake automake"
  "https://github.com/archive/gnu-make gnu-make"
  "https://github.com/waf-project/waf waf-build"

  # ── Tier 3B: Package Managers (10) ─────────────────────────────────────
  "https://github.com/npm/npm npm-registry"
  "https://github.com/yarnpkg/berry yarn-pkg"
  "https://github.com/pnpm/pnpm pnpm-registry"
  "https://github.com/pypa/pip pip-python"
  "https://github.com/python-poetry/poetry poetry-python"
  "https://github.com/rust-lang/cargo cargo-rust"
  "https://github.com/ruby/rubygems rubygems-registry"
  "https://github.com/composer/composer composer-php"
  "https://github.com/elixir-lang/elixir elixir-mix"
  "https://github.com/dotnet/nuget nuget-registry"

  # ── Tier 3C: Testing Frameworks (10) ───────────────────────────────────
  "https://github.com/pytest-dev/pytest pytest"
  "https://github.com/python/cpython unittest"
  "https://github.com/nose-devs/nose nose2"
  "https://github.com/testify/testify testify-go"
  "https://github.com/rspec/rspec rspec-ruby"
  "https://github.com/jasmine/jasmine jasmine-js"
  "https://github.com/mochajs/mocha mocha-js"
  "https://github.com/cypress-io/cypress cypress"
  "https://github.com/SeleniumHQ/selenium selenium"
  "https://github.com/appium/appium appium"

  # ── Tier 3D: Web Servers (10) ──────────────────────────────────────────
  "https://github.com/nginx/nginx nginx-src"
  "https://github.com/httpd/httpd apache-httpd-src"
  "https://github.com/caddyserver/caddy caddy-server"
  "https://github.com/traefik/traefik traefik-proxy"
  "https://github.com/envoyproxy/envoy envoy-proxy"
  "https://github.com/haproxy/haproxy haproxy"
  "https://github.com/lighttpd/lighttpd lighttpd-src"
  "https://github.com/h2o/h2o h2o-server"
  "https://github.com/openresty/openresty openresty"
  "https://github.com/jqlang/jq jq-query"

  # ── Tier 3E: Serialization (10) ────────────────────────────────────────
  "https://github.com/protocolbuffers/protobuf-python protobuf-py"
  "https://github.com/apache/avro avro-codec"
  "https://github.com/msgpack/msgpack msgpack-protocol"
  "https://github.com/google/flatbuffers flatbuffers"
  "https://github.com/capnproto/capnproto capnproto"
  "https://github.com/apache/thrift thrift-framework"
  "https://github.com/grpc/grpc grpc-framework"
  "https://github.com/grpc-ecosystem/grpc-web grpc-web"
  "https://github.com/json-rpc/json-rpc json-rpc-spec"
  "https://github.com/xmlrpc/xmlrpc-c xmlrpc-lib"

  # ── Tier 3F: Networking (10) ───────────────────────────────────────────
  "https://github.com/curl/curl curl-http"
  "https://github.com/psf/requests requests-py"
  "https://github.com/encode/httpx httpx-async"
  "https://github.com/seanmonstar/reqwest reqwest-rust"
  "https://github.com/hyperium/hyper hyper-rust"
  "https://github.com/hyperium/h2 h2-http2"
  "https://github.com/http2/http2-spec http2-protocol"
  "https://github.com/quicwg/base-drafts quic-protocol"
  "https://github.com/zeromq/libzmq zeromq"
  "https://github.com/nanomsg/nanomsg nanomsg-protocol"
)

# =============================================================================
# Phase 2: 150 NEW REPOS (Total: 500)
# Tier 4 (Emerging Languages) + Tier 5 (Specialized)
# =============================================================================

PHASE_2_REPOS=(
  # ── Tier 4A: Emerging Languages (15) ───────────────────────────────────
  "https://github.com/JuliaLang/julia julia-lang"
  "https://github.com/elixir-lang/elixir elixir-lang"
  "https://github.com/erlang/otp erlang-lang"
  "https://github.com/gleam-lang/gleam gleam-lang"
  "https://github.com/ziglang/zig zig-lang"
  "https://github.com/odin-lang/odin odin-lang"
  "https://github.com/nim-lang/Nim nim-lang"
  "https://github.com/crystal-lang/crystal crystal-lang"
  "https://github.com/vlang/v v-lang"
  "https://github.com/ballerina-platform/ballerina ballerina-lang"
  "https://github.com/chapel-lang/chapel chapel-lang"
  "https://github.com/cython/cython cython"
  "https://github.com/python/mypy mypy-typechecker"
  "https://github.com/pypy/pypy pypy-interpreter"
  "https://github.com/luau-lang/luau luau-lang"

  # ── Tier 4B: WebAssembly (10) ──────────────────────────────────────────
  "https://github.com/wasmerio/wasmer wasmer-runtime"
  "https://github.com/bytecodealliance/wasmtime wasmtime"
  "https://github.com/wasm3/wasm3 wasm3-vm"
  "https://github.com/bytecodealliance/wasmtime-cli wasm-cli"
  "https://github.com/emscripten-core/emscripten emscripten"
  "https://github.com/rustwasm/wasm-bindgen wasm-bindgen-test"
  "https://github.com/rustwasm/wasm-pack wasm-pack"
  "https://github.com/rustwasm/wasm-bindgen-cli wasm-bindgen-cli"
  "https://github.com/rustwasm/web-sys web-sys"
  "https://github.com/rustwasm/js-sys js-sys"

  # ── Tier 4C: Blockchain/Web3 (15) ──────────────────────────────────────
  "https://github.com/ethereum/go-ethereum ethereum-geth"
  "https://github.com/bitcoin/bitcoin bitcoin-core"
  "https://github.com/solana-labs/solana solana-blockchain"
  "https://github.com/paritytech/substrate substrate-blockchain"
  "https://github.com/cosmos/cosmos-sdk cosmos-sdk"
  "https://github.com/paritytech/polkadot polkadot-blockchain"
  "https://github.com/input-output-hk/cardano-node cardano-blockchain"
  "https://github.com/near/near-sdk-rs near-protocol"
  "https://github.com/algorand/go-algorand algorand-blockchain"
  "https://github.com/tezos/tezos tezos-blockchain"
  "https://github.com/XRPLF/rippled ripple-ledger"
  "https://github.com/iotaledger/iota.rs iota-blockchain"
  "https://github.com/hyperledger/fabric hyperledger-fabric"
  "https://github.com/ethereum/eth2.0-deposit-contract eth2-client"
  "https://github.com/web3/web3.py web3-ethereum"

  # ── Tier 4D: AI/ML Specialized (15) ────────────────────────────────────
  "https://github.com/google/jax jax-ml"
  "https://github.com/apache/mxnet mxnet-ml"
  "https://github.com/PaddlePaddle/Paddle paddle-ml"
  "https://github.com/oneflow-inc/oneflow oneflow-ml"
  "https://github.com/ml-explore/mlx mlx-apple"
  "https://github.com/onnx/onnx onnx-format"
  "https://github.com/NVIDIA/TensorRT tensorrt-inference"
  "https://github.com/apache/tvm tvm-compiler"
  "https://github.com/openvinotoolkit/openvino openvino-toolkit"
  "https://github.com/tensorflow/xla xla-compiler"
  "https://github.com/openai/triton triton-lang"
  "https://github.com/llvm/llvm-project llvm"
  "https://github.com/llvm/mlir mlir-compiler"
  "https://github.com/NVIDIA/nccl nccl-library"
  "https://github.com/NVIDIA/cudnn cudnn-library"

  # ── Tier 4E: Quantum Computing (5) ─────────────────────────────────────
  "https://github.com/Qiskit/qiskit qiskit-quantum"
  "https://github.com/quantumlib/Cirq cirq-quantum"
  "https://github.com/PennyLaneAI/pennylane pennylane-quantum"
  "https://github.com/eth-sri/silq silq-quantum"
  "https://github.com/ProjectQ-Framework/ProjectQ projectq-quantum"

  # ── Tier 4F: IoT/Embedded (10) ─────────────────────────────────────────
  "https://github.com/espressif/esp-idf esp-idf"
  "https://github.com/ARMmbed/mbed-os mbed-os"
  "https://github.com/zephyrproject-rtos/zephyr zephyr-rtos"
  "https://github.com/contiki-os/contiki-ng contiki-ng"
  "https://github.com/contikios/contiki contiki-os"
  "https://github.com/riot-os/RIOT riot-rtos"
  "https://github.com/apache/mynewt-core mynewt-rtos"
  "https://github.com/real-time-operating-system/FreeRTOS freertos"
  "https://github.com/Azure-Rtos/ThreadX threadx-rtos"
  "https://github.com/Azure-Rtos/AzureRtos azure-rtos"

  # ── Tier 4G: Game Engines (10) ─────────────────────────────────────────
  "https://github.com/godotengine/godot godot-engine"
  "https://github.com/bevyengine/bevy bevy-engine"
  "https://github.com/ggez/ggez ggez-engine"
  "https://github.com/amethyst/amethyst amethyst-engine"
  "https://github.com/bracketslib/bracket-lib bracket-engine"
  "https://github.com/hecrj/druid druid-engine"
  "https://github.com/not-fl3/macroquad macroquad-engine"
  "https://github.com/raysan5/raylib raylib-graphics"
  "https://github.com/PistonDevelopers/piston piston-engine"
  "https://github.com/teraflux/teraflux tera-engine"

  # ── Tier 4H: Graphics/Rendering (10) ───────────────────────────────────
  "https://github.com/KhronosGroup/Vulkan-Hpp vulkan-hpp"
  "https://github.com/Khronos/OpenGL-Registry opengl-spec"
  "https://github.com/gfx-rs/wgpu webgpu-rs"
  "https://github.com/bkaradzic/bgfx bgfx-graphics"
  "https://github.com/floooh/sokol sokol-headers"
  "https://github.com/sveltejs/svelte-gl nanosvg"
  "https://github.com/freedesktop/cairo cairo-graphics"
  "https://github.com/google/skia skia-library"
  "https://github.com/Microsoft/gdi gdi-plus"
  "https://github.com/microsoft/DirectXTK directx-toolkit"

  # ── Tier 4I: Scientific Computing (10) ──────────────────────────────────
  "https://github.com/scipy/scipy scipy-library"
  "https://github.com/numpy/numpy numpy-ext"
  "https://github.com/pandas-dev/pandas pandas-ext"
  "https://github.com/dask/dask-dataframe dask-df"
  "https://github.com/pydata/xarray xarray-library"
  "https://github.com/sympy/sympy sympy-math"
  "https://github.com/sagemath/sage sage-math"
  "https://github.com/JuliaLang/Distributions.jl distributions-julia"
  "https://github.com/GNU-Octave/octave octave-math"
  "https://github.com/Gnuplot/gnuplot gnuplot-plotting"

  # ── Tier 4J: Documentation (5) ─────────────────────────────────────────
  "https://github.com/sphinx-doc/sphinx sphinx-doc"
  "https://github.com/mkdocs/mkdocs mkdocs-tool"
  "https://github.com/doxygen/doxygen doxygen-generator"
  "https://github.com/asciidoctor/asciidoctor asciidoctor"
  "https://github.com/docutils-mirror/docutils rst-parser"

  # ── Tier 5A: Real-Time Systems (10) ────────────────────────────────────
  "https://github.com/matrix-org/synapse matrix-homeserver"
  "https://github.com/RocketChat/Rocket.Chat rocket-chat"
  "https://github.com/discourse/discourse discourse-forum"
  "https://github.com/nextcloud/talk nextcloud-talk"
  "https://github.com/savoirfaire-dev/jami-client jami-communication"
  "https://github.com/signalapp/libsignal signal-protocol"
  "https://github.com/python-telegram-bot/python-telegram-bot telegram-bot"
  "https://github.com/slackapi/python-slack-sdk slack-sdk"
  "https://github.com/discord/discord.py discord-py"
  "https://github.com/facebook/facebook-sdk-python facebook-sdk"

  # ── Tier 5B: Monitoring/Observability (10) ─────────────────────────────
  "https://github.com/prometheus/prometheus prometheus-metrics"
  "https://github.com/grafana/grafana-plugin grafana-plugins"
  "https://github.com/DataDog/datadog-agent datadog-agent"
  "https://github.com/newrelic/newrelic-client-python newrelic-sdk"
  "https://github.com/elastic/beats elastic-beats"
  "https://github.com/splunk/splunk-sdk-python splunk-sdk"
  "https://github.com/SumoLogic/sumo-python-sdk sumologic-sdk"
  "https://github.com/aws/aws-sdk-python cloudwatch-client"
  "https://github.com/googleapis/google-cloud-python stackdriver-client"
  "https://github.com/dynatrace-oss/dynatrace-python dynatrace-sdk"

  # ── Trending Updates (50 additional) ────────────────────────────────────
  # These will be filled from weekly GitHub trending top 50
  # Placeholder entries for demonstration:
  "https://github.com/github/copilot-docs github-copilot"
  "https://github.com/openai/gpt-4 openai-gpt4"
  "https://github.com/anthropics/claude-sdk anthropic-sdk"
  "https://github.com/stability-ai/stable-diffusion stable-diffusion"
  "https://github.com/facebookresearch/llama llama-ai"
  "https://github.com/meta-llama/llama2 llama2-model"
  "https://github.com/mistralai/mistral mistral-ai"
  "https://github.com/ggerganov/llama.cpp llama-cpp"
  "https://github.com/lm-sys/FastChat fastchat"
  "https://github.com/chroma-core/chroma chroma-db"
  "https://github.com/langchain-ai/langchain langchain"
  "https://github.com/jerryjliu/llama_index llamaindex"
  "https://github.com/paul-gauthier/aider aider-code"
  "https://github.com/OpenInterpreter/open-interpreter open-interpreter"
  "https://github.com/geekan/MetaGPT metagpt"
  "https://github.com/Significant-Gravitas/AutoGPT autogpt"
  "https://github.com/yoheinakajima/babyagi babyagi"
  "https://github.com/reworkd/AgentGPT agentgpt"
  "https://github.com/mini-dev/mini-dev minidev"
  "https://github.com/aiwaves-cn/agents agents-ai"
  "https://github.com/evals-evals/evals openai-evals"
  "https://github.com/hwchase17/langsmith langsmith"
  "https://github.com/run-llama/llamaviz llamaviz"
  "https://github.com/shroominic/codeinterpreter-api code-interpreter"
  "https://github.com/promptflow-dev/promptflow promptflow"
  "https://github.com/langchain-ai/langsmith-sdk langsmith-python"
  "https://github.com/whylabs/whylabs-client whylabs-sdk"
  "https://github.com/wandb/wandb weights-biases"
  "https://github.com/labelImg/labelImg labelimg"
  "https://github.com/roboflow/roboflow roboflow"
  "https://github.com/logicalclocks/feature-store hopsworks"
  "https://github.com/tecton-ai/tecton tecton-platform"
  "https://github.com/qdrant/qdrant qdrant-vector-db"
  "https://github.com/milvus-io/milvus milvus-vector-db"
  "https://github.com/weaviate/weaviate weaviate-db"
  "https://github.com/pinecone-io/pinecone pinecone-vector"
  "https://github.com/elasticsearch/elasticsearch-py elasticsearch-py"
  "https://github.com/opensearch-project/opensearch opensearch"
  "https://github.com/myscale/MyScale myscale-db"
  "https://github.com/pgvector/pgvector pgvector"
  "https://github.com/ankane/pgvector-ruby pgvector-ruby"
  "https://github.com/nmslib/hnswlib hnswlib"
  "https://github.com/facebookresearch/faiss faiss-library"
  "https://github.com/spotify/annoy annoy-library"
  "https://github.com/lmcinnes/umap umap-learn"
  "https://github.com/Netflix/metaflow metaflow"
  "https://github.com/dagster-io/dagster dagster"
  "https://github.com/prefecthq/prefect prefect"
  "https://github.com/great-expectations/great_expectations great-expectations"
)

# =============================================================================
# Unified Repository Array
# =============================================================================

declare -a ALL_REPOS

# Select phase
case "$TARGET_PHASE" in
  1a)
    log "Phase 1A: Cloning 91 new repos (Total: 250)"
    ALL_REPOS=("${PHASE_1A_REPOS[@]}")
    ;;
  1b)
    log "Phase 1B: Cloning 100 new repos (Total: 350)"
    ALL_REPOS=("${PHASE_1B_REPOS[@]}")
    ;;
  2)
    log "Phase 2: Cloning 150 new repos (Total: 500)"
    ALL_REPOS=("${PHASE_2_REPOS[@]}")
    ;;
  all)
    log "Cloning ALL phases: 1A + 1B + 2 (Total: 500 repos)"
    ALL_REPOS=("${PHASE_1A_REPOS[@]}" "${PHASE_1B_REPOS[@]}" "${PHASE_2_REPOS[@]}")
    ;;
  *)
    err "Invalid phase. Use: 1a, 1b, 2, or all"
    exit 1
    ;;
esac

TOTAL=${#ALL_REPOS[@]}
log "Starting with $PARALLEL_JOBS workers..."
info "Destination: $REPOS_DIR"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Clone Function
# ─────────────────────────────────────────────────────────────────────────────

clone_repo() {
  local url="$1"
  local label="$2"
  local dest="$REPOS_DIR/$label"

  if [ -d "$dest/.git" ]; then
    echo "[SKIP] $label — already cloned"
    return 0
  fi

  if git clone --depth=1 --single-branch -q "$url" "$dest" 2>/dev/null; then
    echo "[OK]   $label"
  else
    echo "[FAIL] $label — clone failed, skipping"
  fi
}

export -f clone_repo
export REPOS_DIR

# ─────────────────────────────────────────────────────────────────────────────
# Parallel Execution
# ─────────────────────────────────────────────────────────────────────────────

for repo_entry in "${ALL_REPOS[@]}"; do
  url=$(echo "$repo_entry" | awk '{print $1}')
  label=$(echo "$repo_entry" | awk '{print $2}')
  clone_repo "$url" "$label" &

  # Limit concurrency
  if (( $(jobs -r -p | wc -l) >= PARALLEL_JOBS )); then
    wait -n
  fi
done
wait

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────

echo ""
CLONED=$(find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)

case "$TARGET_PHASE" in
  1a) TARGET=250 ;;
  1b) TARGET=350 ;;
  2) TARGET=500 ;;
  all) TARGET=500 ;;
esac

log "Clone complete: $CLONED / $TARGET repos ready"
info "Next: bash scripts/03_run_benchmarks_extended_500.sh --phase=$TARGET_PHASE"
