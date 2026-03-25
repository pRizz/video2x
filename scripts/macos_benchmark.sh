#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_BUILT_BINARY="${REPO_ROOT}/build/macos-system-release/video2x"
DEFAULT_INSTALLED_BINARY="${REPO_ROOT}/build/install/macos-system-release/bin/video2x"
BENCHMARK_ROOT="${REPO_ROOT}/build/macos-benchmark"
DEFAULT_DURATION_SECONDS=10
DEFAULT_FRAME_RATE=24

usage() {
    cat <<'EOF'
Usage:
  scripts/macos_benchmark.sh benchmark-realesrgan [--binary-mode built|installed] [--binary /path/to/video2x] [--input /path/to/input.mp4]
  scripts/macos_benchmark.sh benchmark-rife [--binary-mode built|installed] [--binary /path/to/video2x] [--input /path/to/input.mp4]

Phase 05 canonical target:
  --binary-mode built      Use build/macos-system-release/video2x (default)

Secondary target:
  --binary-mode installed  Use build/install/macos-system-release/bin/video2x when available

Notes:
  - The helper wraps the existing `video2x --benchmark` mode; it does not add
    a second timing mechanism.
  - Video2X currently still requires `--output` even in benchmark mode, so this
    script provides a dummy output path automatically.
  - If --input is omitted, the script generates a local benchmark clip long
    enough to avoid misleading zero-second benchmark summaries on fast hosts.
  - A benchmark result with `Total time taken: 00:00:00` is rejected as
    insufficient evidence.
EOF
}

die() {
    echo "error: $*" >&2
    exit 1
}

log() {
    echo "==> $*" >&2
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found on PATH: $1"
}

binary_mode="built"
binary_override=""
input_path=""

parse_common_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --binary-mode)
                [[ $# -ge 2 ]] || die "--binary-mode requires a value"
                binary_mode="$2"
                shift 2
                ;;
            --binary)
                [[ $# -ge 2 ]] || die "--binary requires a value"
                binary_override="$2"
                shift 2
                ;;
            --input)
                [[ $# -ge 2 ]] || die "--input requires a value"
                input_path="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                die "unknown argument: $1"
                ;;
        esac
    done
}

resolve_binary() {
    if [[ -n "${binary_override}" ]]; then
        printf '%s\n' "${binary_override}"
        return
    fi

    case "${binary_mode}" in
        built)
            printf '%s\n' "${DEFAULT_BUILT_BINARY}"
            ;;
        installed)
            printf '%s\n' "${DEFAULT_INSTALLED_BINARY}"
            ;;
        *)
            die "unsupported --binary-mode: ${binary_mode}"
            ;;
    esac
}

binary_label() {
    case "${binary_mode}" in
        built)
            printf '%s\n' "built binary (canonical)"
            ;;
        installed)
            printf '%s\n' "installed binary (secondary)"
            ;;
        *)
            printf '%s\n' "custom override"
            ;;
    esac
}

validate_binary() {
    local binary_path="$1"
    [[ -x "${binary_path}" ]] || die "video2x binary is not executable: ${binary_path}"
}

generate_benchmark_input() {
    local destination="$1"
    mkdir -p "$(dirname "${destination}")"
    log "Generating benchmark clip at ${destination} (${DEFAULT_DURATION_SECONDS}s @ ${DEFAULT_FRAME_RATE} fps)"
    ffmpeg \
        -y \
        -f lavfi \
        -i "testsrc=size=320x180:rate=${DEFAULT_FRAME_RATE}" \
        -t "${DEFAULT_DURATION_SECONDS}" \
        -pix_fmt yuv420p \
        "${destination}" >/dev/null 2>&1
}

ensure_input() {
    local subcommand="$1"
    local sample_dir="${BENCHMARK_ROOT}/${subcommand}"

    if [[ -n "${input_path}" ]]; then
        [[ -f "${input_path}" ]] || die "input file does not exist: ${input_path}"
        printf '%s\n' "${input_path}"
        return
    fi

    require_command ffmpeg
    local generated_input="${sample_dir}/generated-input.mp4"
    if [[ ! -f "${generated_input}" ]]; then
        generate_benchmark_input "${generated_input}"
    fi
    printf '%s\n' "${generated_input}"
}

extract_elapsed_time() {
    local benchmark_output="$1"
    printf '%s\n' "${benchmark_output}" | sed -n 's/^Total time taken: //p' | head -n 1
}

extract_average_speed() {
    local benchmark_output="$1"
    printf '%s\n' "${benchmark_output}" | sed -n 's/^Average processing speed: //p' | head -n 1
}

run_benchmark() {
    local subcommand="$1"
    local binary_path="$2"
    local benchmark_root="${BENCHMARK_ROOT}/${subcommand}"
    local effective_input
    local dummy_output
    local benchmark_output
    local elapsed_time
    local average_speed

    effective_input="$(ensure_input "${subcommand}")"
    dummy_output="${benchmark_root}/discarded-output.mp4"

    mkdir -p "${benchmark_root}"
    rm -f "${dummy_output}"

    local -a cmd=(
        "${binary_path}"
        -i "${effective_input}"
        -o "${dummy_output}"
        --benchmark
        --no-progress
    )

    case "${subcommand}" in
        benchmark-realesrgan)
            cmd+=(
                -p realesrgan
                -s 2
                --realesrgan-model realesr-animevideov3
            )
            ;;
        benchmark-rife)
            cmd+=(
                -p rife
                -m 2
                --rife-model rife-v4.26
            )
            ;;
        *)
            die "unsupported benchmark subcommand: ${subcommand}"
            ;;
    esac

    log "Running ${subcommand} using $(binary_label): ${binary_path}"
    log "Benchmark input: ${effective_input}"
    log "Supplying a dummy --output path because benchmark mode still requires it during argument parsing."

    if ! benchmark_output="$("${cmd[@]}" 2>&1)"; then
        printf '%s\n' "${benchmark_output}"
        die "benchmark command failed for ${subcommand}"
    fi

    printf '%s\n' "${benchmark_output}"

    if ! printf '%s\n' "${benchmark_output}" | rg -q '^====== Video2X Benchmark summary ======$'; then
        die "expected a benchmark summary in ${subcommand} output"
    fi

    elapsed_time="$(extract_elapsed_time "${benchmark_output}")"
    [[ -n "${elapsed_time}" ]] || die "benchmark output did not include Total time taken"
    if [[ "${elapsed_time}" == "00:00:00" ]]; then
        die "benchmark output reported Total time taken: ${elapsed_time}; rerun with a longer input because this result is insufficient evidence"
    fi

    average_speed="$(extract_average_speed "${benchmark_output}")"
    [[ -n "${average_speed}" ]] || die "benchmark output did not include Average processing speed"

    log "Benchmark accepted with elapsed time ${elapsed_time} and average speed ${average_speed}"
}

main() {
    [[ $# -gt 0 ]] || {
        usage
        exit 1
    }

    local subcommand="$1"
    shift

    parse_common_options "$@"

    local binary_path
    binary_path="$(resolve_binary)"
    validate_binary "${binary_path}"

    case "${subcommand}" in
        benchmark-realesrgan|benchmark-rife)
            run_benchmark "${subcommand}" "${binary_path}"
            ;;
        --help|-h|help)
            usage
            ;;
        *)
            die "unknown subcommand: ${subcommand}"
            ;;
    esac
}

main "$@"
