#!/bin/bash
# =============================================================================
# SigMap Benchmark Suite — Phase 2 Expansion: Clone Repos 241-500
# Expanding from 240 to 500 repos (260 additional repositories)
# Focus: Emerging languages, AI/ML tools, blockchain, cloud-native
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

log()   { echo -e "${GREEN}[CLONE-EXP]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }

REPOS_DIR="$HOME/repos"
PARALLEL_JOBS=${1:-8}

log "Phase 2 Expansion: Cloning Repos 241-500 (260 additional repos)"
echo ""

# =============================================================================
# Phase 2 Expansion: 260 Additional Repos (Emerging & Specialized)
# =============================================================================

EXPANSION_REPOS=(
  # ── Emerging Languages (30) ─────────────────────────────────────────────
  "https://github.com/JuliaLang/julia julia-lang"
  "https://github.com/nim-lang/nim nim-lang"
  "https://github.com/crystal-lang/crystal crystal-lang"
  "https://github.com/vlang/v v-lang"
  "https://github.com/ziglang/zig zig-lang"
  "https://github.com/elixir-lang/elixir elixir-lang"
  "https://github.com/gleam-lang/gleam gleam-lang"
  "https://github.com/lua/lua lua-lang"
  "https://github.com/luau-lang/luau luau-lang"
  "https://github.com/apple/swift swift-lang"
  "https://github.com/kotlin-lang/kotlin kotlin-lang"
  "https://github.com/dotnet/csharp-language csharp-lang"
  "https://github.com/ruby/ruby ruby-lang"
  "https://github.com/python/cpython python-lang"
  "https://github.com/golang/go go-lang"
  "https://github.com/rust-lang/rust rust-lang"
  "https://github.com/torvalds/linux linux-kernel"
  "https://github.com/llvm/llvm-project llvm-project"
  "https://github.com/gcc-mirror/gcc gcc-compiler"
  "https://github.com/iovisor/bcc bcc-ebpf"
  "https://github.com/containers/podman podman-container"
  "https://github.com/FerretDB/FerretDB ferretdb"
  "https://github.com/caddyserver/caddy caddy-server"
  "https://github.com/smallstep/certificates smallstep-pki"
  "https://github.com/dexidp/dex dex-oauth2"
  "https://github.com/spiffe/spiffe spiffe-identity"
  "https://github.com/argoproj/argo argo-workflows"
  "https://github.com/argoproj/argo-cd argocd-deployment"
  "https://github.com/fluxcd/flux2 flux-gitops"
  "https://github.com/helm/helm helm-charts"

  # ── AI/ML Specialized (30) ──────────────────────────────────────────────
  "https://github.com/jax-ml/jax jax-ml"
  "https://github.com/apple/ml-compute mlx-apple"
  "https://github.com/ONNXRuntime/onnxruntime onnx-runtime"
  "https://github.com/OpenMMLab/mmcv mmcv-vision"
  "https://github.com/aws/sagemaker-examples sagemaker-ml"
  "https://github.com/tensorflow/text tensorflow-text"
  "https://github.com/huggingface/accelerate accelerate-lib"
  "https://github.com/pytorch/torchvision torchvision-vision"
  "https://github.com/pytorch/audio torchaudio-audio"
  "https://github.com/pytorch/text torchtext-nlp"
  "https://github.com/tensorflow/addons tensorflow-addons"
  "https://github.com/tensorflow/datasets tensorflow-datasets"
  "https://github.com/tensorflow/examples tensorflow-examples"
  "https://github.com/keras-team/keras keras-dl"
  "https://github.com/thudm/chatglm chatglm-ai"
  "https://github.com/openai/gpt-2 gpt-2-model"
  "https://github.com/openai/gpt-3 gpt-3-model"
  "https://github.com/openai/whisper openai-whisper"
  "https://github.com/openai/clip openai-clip"
  "https://github.com/openai/dall-e openai-dall-e"
  "https://github.com/replicate/cog cog-ml"
  "https://github.com/bentoml/BentoML bentoml-serving"
  "https://github.com/seldon-core/seldon-core seldon-mlops"
  "https://github.com/ray-project/ray-rllib ray-rl"
  "https://github.com/microsoft/nni nni-tuning"
  "https://github.com/optuna/optuna optuna-hpo"
  "https://github.com/hyperopt/hyperopt hyperopt-tuning"
  "https://github.com/automl/auto-sklearn autosklearn"
  "https://github.com/autogluon/autogluon autogluon-ml"
  "https://github.com/PapersWithCode/sotabench sotabench"

  # ── Blockchain & Web3 (30) ──────────────────────────────────────────────
  "https://github.com/ethereum/go-ethereum geth-ethereum"
  "https://github.com/ethereum-optimism/optimism optimism-l2"
  "https://github.com/arbitrum/arbitrum arbitrum-l2"
  "https://github.com/starkware-libs/cairo cairo-lang"
  "https://github.com/paritytech/polkadot polkadot-blockchain"
  "https://github.com/paritytech/substrate substrate-blockchain"
  "https://github.com/cosmos/cosmos-sdk cosmos-sdk"
  "https://github.com/tendermint/tendermint tendermint-consensus"
  "https://github.com/solana-labs/solana solana-blockchain"
  "https://github.com/hyperledger/fabric hyperledger-fabric"
  "https://github.com/hyperledger/sawtooth hyperledger-sawtooth"
  "https://github.com/hyperledger/indy hyperledger-indy"
  "https://github.com/diem/diem diem-blockchain"
  "https://github.com/filecoin-project/lotus filecoin-node"
  "https://github.com/libp2p/libp2p libp2p-network"
  "https://github.com/ipfs/kubo ipfs-node"
  "https://github.com/arweave/arweave arweave-storage"
  "https://github.com/dfinity/ic internet-computer"
  "https://github.com/near/nearcore near-protocol"
  "https://github.com/iotaledger/iota iota-blockchain"
  "https://github.com/cardano-foundation/cardano-node cardano-blockchain"
  "https://github.com/algorand/go-algorand algorand-blockchain"
  "https://github.com/ton-blockchain/ton ton-blockchain"
  "https://github.com/aptos-labs/aptos aptos-blockchain"
  "https://github.com/sui-foundation/sui sui-blockchain"
  "https://github.com/StarkWare-starknet/starknet starknet-l2"
  "https://github.com/scroll-tech/scroll scroll-zkvm"
  "https://github.com/zcash/zcash zcash-privacy"
  "https://github.com/monero-project/monero monero-privacy"
  "https://github.com/MobileCoin/mobilecoin mobilecoin"

  # ── Cloud-Native & DevOps (30) ──────────────────────────────────────────
  "https://github.com/open-policy-agent/opa opa-policy"
  "https://github.com/aquasecurity/trivy trivy-scanner"
  "https://github.com/aquasecurity/tracee tracee-ebpf"
  "https://github.com/falcosecurity/falco falco-runtime"
  "https://github.com/cilium/cilium cilium-networking"
  "https://github.com/flannel-io/flannel flannel-networking"
  "https://github.com/projectcalico/calico calico-networking"
  "https://github.com/weave-works/weave weave-networking"
  "https://github.com/aws/aws-cdk aws-cdk"
  "https://github.com/pulumi/pulumi pulumi-iac"
  "https://github.com/gruntwork-io/terragrunt terragrunt-iac"
  "https://github.com/spacelift-io/spacelift spacelift-iac"
  "https://github.com/env0/env0 env0-iac"
  "https://github.com/snyk/snyk snyk-security"
  "https://github.com/gitpod-io/gitpod gitpod-dev"
  "https://github.com/coder/coder coder-dev"
  "https://github.com/jetbrains/projector jetbrains-projector"
  "https://github.com/microsoft/devcontainers devcontainers"
  "https://github.com/shipyard-run/shipyard shipyard-labs"
  "https://github.com/kata-containers/kata kata-containers"
  "https://github.com/gVisor/gvisor gvisor-sandbox"
  "https://github.com/cncf/cnpg cloudnative-postgres"
  "https://github.com/zalando/postgres-operator postgres-operator"
  "https://github.com/vitessio/vitess vitess-sharding"
  "https://github.com/cockroachdb/docs cockroachdb-docs"
  "https://github.com/gravitational/teleport teleport-access"
  "https://github.com/hashicorp/boundary boundary-access"
  "https://github.com/zitadel/zitadel zitadel-iam"
  "https://github.com/keycloak/keycloak keycloak-iam"
  "https://github.com/ory/hydra hydra-oauth"

  # ── Quantum Computing (15) ──────────────────────────────────────────────
  "https://github.com/Qiskit/qiskit qiskit"
  "https://github.com/ProjectQ-Framework/ProjectQ projectq"
  "https://github.com/quantumlib/Cirq cirq-quantum"
  "https://github.com/PennyLaneAI/pennylane pennylane-quantum"
  "https://github.com/XanaduAI/strawberryfields strawberryfields"
  "https://github.com/rigetti/pyquil pyquil-quantum"
  "https://github.com/quantumlib/OpenFermion openfermion-quantum"
  "https://github.com/silq-lang/silq silq-quantum"
  "https://github.com/microsoft/qsharp qsharp-quantum"
  "https://github.com/aws/amazon-braket-sdk braket-quantum"
  "https://github.com/google/cirq-google cirq-google"
  "https://github.com/1QBit/lelantos lelantos-quantum"
  "https://github.com/Qiskit/qiskit-machine-learning qiskit-ml"
  "https://github.com/qiskit-community/qiskit-machine-learning qiskit-ml-alt"
  "https://github.com/quantumlib/ReCirq recirq-quantum"

  # ── IoT & Edge Computing (20) ───────────────────────────────────────────
  "https://github.com/eclipse-iot/mosquitto mosquitto-mqtt"
  "https://github.com/eclipse-iot/paho.mqtt.python paho-mqtt"
  "https://github.com/emqx/emqx emqx-mqtt"
  "https://github.com/rabbitmq/rabbitmq-server rabbitmq-broker"
  "https://github.com/apache/nifi nifi-dataflow"
  "https://github.com/apache/iotdb iotdb-timeseries"
  "https://github.com/influxdata/telegraf telegraf-agent"
  "https://github.com/grafana/loki loki-logging"
  "https://github.com/fluent/fluent-bit fluent-bit"
  "https://github.com/vector-dev/vector vector-telemetry"
  "https://github.com/open-telemetry/opentelemetry-js opentelemetry"
  "https://github.com/jaegertracing/jaeger jaeger-tracing"
  "https://github.com/elastic/beats elastic-beats"
  "https://github.com/open-policy-agent/gatekeeper gatekeeper-policy"
  "https://github.com/kubeedge/kubeedge kubeedge"
  "https://github.com/eclipse-fog05/fog05 fog05-fog"
  "https://github.com/opensourceiot/tinymote tinymote"
  "https://github.com/apache/camel apache-camel"
  "https://github.com/openhab/openhab-core openhab"
  "https://github.com/home-assistant/core home-assistant"

  # ── Scientific Computing (25) ───────────────────────────────────────────
  "https://github.com/scikit-image/scikit-image skimage"
  "https://github.com/scikit-optimize/scikit-optimize skopt"
  "https://github.com/scikit-learn/scikit-learn sklearn"
  "https://github.com/scikit-learn-contrib/imbalanced-learn imbalanced-learn"
  "https://github.com/plotly/plotly.py plotly-py"
  "https://github.com/matplotlib/matplotlib matplotlib"
  "https://github.com/mwaskom/seaborn seaborn-viz"
  "https://github.com/altair-viz/altair altair-viz"
  "https://github.com/pydata/xarray xarray-array"
  "https://github.com/zarr-developers/zarr zarr-array"
  "https://github.com/dask/dask-array dask-array"
  "https://github.com/sparse-dev/sparse sparse-array"
  "https://github.com/pydata/bottleneck bottleneck"
  "https://github.com/numba/numba numba-jit"
  "https://github.com/Cython/cython cython-compiler"
  "https://github.com/PyO3/pyo3 pyo3-bindings"
  "https://github.com/jorenham/optype optype-typing"
  "https://github.com/python/typing_extensions typing-extensions"
  "https://github.com/pydantic/pydantic pydantic-validation"
  "https://github.com/dataclasses-json/python-dataclasses-json dataclasses-json"
  "https://github.com/pre-commit/pre-commit pre-commit-hooks"
  "https://github.com/python-poetry/poetry poetry-packaging"
  "https://github.com/psf/requests requests-http"
  "https://github.com/httpx-dev/httpx httpx-client"
  "https://github.com/aio-libs/aiohttp aiohttp-async"

  # ── Low-Level & Systems (30) ────────────────────────────────────────────
  "https://github.com/mit-pdos/xv6-public xv6-os"
  "https://github.com/bellard/quickjs quickjs-engine"
  "https://github.com/jemalloc/jemalloc jemalloc-alloc"
  "https://github.com/google/tcmalloc tcmalloc-alloc"
  "https://github.com/gperftools/gperftools gperftools"
  "https://github.com/brendangregg/FlameGraph flamegraph"
  "https://github.com/LLNL/RAJA RAJA-parallel"
  "https://github.com/kokkos/kokkos kokkos-parallel"
  "https://github.com/ROCmSoftwarePlatform/rocm-cmake rocm-build"
  "https://github.com/oneapi-src/oneDNN onednn-inference"
  "https://github.com/openmp-forge/openmp-forge openmp-parallel"
  "https://github.com/intel/hyperscan hyperscan-regex"
  "https://github.com/google/re2 re2-regex"
  "https://github.com/oniguruma/oniguruma oniguruma-regex"
  "https://github.com/google/brotli brotli-compression"
  "https://github.com/lz4/lz4 lz4-compression"
  "https://github.com/facebook/zstd zstd-compression"
  "https://github.com/WireGuard/wireguard wireguard-vpn"
  "https://github.com/shadowsocks/shadowsocks shadowsocks-proxy"
  "https://github.com/v2fly/v2ray-core v2ray-proxy"
  "https://github.com/xray-project/xray xray-proxy"
  "https://github.com/getlantern/lantern lantern-proxy"
  "https://github.com/trojan-gfw/trojan trojan-proxy"
  "https://github.com/mixiaoxiao/PyQt-Qwt PyQtQwt-plotting"
  "https://github.com/GTK/gtk gtk-ui"
  "https://github.com/GNOME/gtk4 gtk4-ui"
  "https://github.com/madler/zlib zlib-compression"
  "https://github.com/libarchive/libarchive libarchive"
  "https://github.com/xz-mirror/xz xz-compression"
  "https://github.com/tukaani-project/xz-java xz-java"

  # ── Language-Specific Tools (50) ────────────────────────────────────────
  # Python ecosystem
  "https://github.com/pallets/werkzeug werkzeug-wsgi"
  "https://github.com/psf/black black-formatter"
  "https://github.com/charliermarsh/ruff ruff-linter"
  "https://github.com/PyCQA/pylint pylint-linter"
  "https://github.com/PyCQA/flake8 flake8-linter"
  "https://github.com/PyCQA/mypy mypy-typechecker"
  "https://github.com/python-attrs/attrs attrs-library"
  "https://github.com/marshmallow-code/marshmallow marshmallow-serialization"
  "https://github.com/yaml/pyyaml pyyaml-parser"
  "https://github.com/toml-lang/toml-test toml-parser"
  # Node.js ecosystem
  "https://github.com/npm/npm npm-registry"
  "https://github.com/yarnpkg/yarn yarn-pkg"
  "https://github.com/pnpm/pnpm pnpm-pkg"
  "https://github.com/DefinitelyTyped/DefinitelyTyped definitelytyped"
  "https://github.com/eslint/eslint eslint-linter"
  "https://github.com/prettier/prettier prettier"
  "https://github.com/stylelint/stylelint stylelint-linter"
  "https://github.com/postcss/postcss postcss-processor"
  "https://github.com/webpack/webpack webpack-bundler"
  "https://github.com/parcel-bundler/parcel parcel-bundler"
  # Rust ecosystem
  "https://github.com/rust-lang/cargo cargo-package"
  "https://github.com/rust-lang/rustfmt rustfmt-formatter"
  "https://github.com/rust-lang/rust-clippy clippy-linter"
  "https://github.com/bnjbvr/cargo-bloat cargo-bloat"
  "https://github.com/Kobzol/cargo-pgo cargo-pgo"
  # Java ecosystem
  "https://github.com/gradle/gradle gradle-build"
  "https://github.com/maven/maven maven-build"
  "https://github.com/adoptium/temurin-build temurin-build"
  "https://github.com/quarkusio/quarkus quarkus-framework"
  "https://github.com/micronaut-projects/micronaut micronaut-framework"
  # Go ecosystem
  "https://github.com/golangci/golangci-lint golangci-lint"
  "https://github.com/golang/tools golang-tools"
  "https://github.com/mitchellh/go-ps gops-process"
  "https://github.com/cosmtrek/air air-reload"
  "https://github.com/securego/gosec gosec-security"
  # C++ ecosystem
  "https://github.com/microsoft/vcpkg vcpkg-pkg"
  "https://github.com/conan-io/conan conan-package"
  "https://github.com/catchorg/Catch2 catch2-testing"
  "https://github.com/google/googletest googletest-testing"
  "https://github.com/doctest/doctest doctest-testing"
)

TOTAL=${#EXPANSION_REPOS[@]}
log "Expanding with $TOTAL additional repositories"
info "Target: repos 241-500"
echo ""

# Clone function
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

# Parallel execution
printf '%s\n' "${EXPANSION_REPOS[@]}" | \
  xargs -P "$PARALLEL_JOBS" -n 1 bash -c 'IFS=" " read -r url label <<< "$1"; clone_repo "$url" "$label"' _

# Summary
echo ""
CLONED=$(find "$REPOS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)
log "Expansion complete: $CLONED total repos ready"
info "Target: 500 repos"
info "Next: bash scripts/03_run_benchmarks_extended.sh"
