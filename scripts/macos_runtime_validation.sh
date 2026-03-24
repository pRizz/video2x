#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_BUILT_BINARY="${REPO_ROOT}/build/macos-system-release/video2x"
DEFAULT_INSTALLED_BINARY="${REPO_ROOT}/build/install/macos-system-release/bin/video2x"
VALIDATION_ROOT="${REPO_ROOT}/build/macos-runtime-validation"

usage() {
    cat <<'EOF'
Usage:
  scripts/macos_runtime_validation.sh smoke [--binary-mode built|installed] [--binary /path/to/video2x]
  scripts/macos_runtime_validation.sh list-devices [--binary-mode built|installed] [--binary /path/to/video2x]
  scripts/macos_runtime_validation.sh sample-realesrgan [--binary-mode built|installed] [--binary /path/to/video2x] [--input /path/to/input.mp4] [--output /path/to/output.mp4]

Phase 03 canonical target:
  --binary-mode built      Use build/macos-system-release/video2x (default)

Secondary target:
  --binary-mode installed  Use build/install/macos-system-release/bin/video2x when available

Notes:
  - The sample path uses Real-ESRGAN as the canonical macOS workload.
  - If --input is omitted, the script generates a short local clip with ffmpeg.
  - `list-devices` requires a working Vulkan portability stack such as MoltenVK
    that advertises VK_KHR_portability_enumeration and yields at least one GPU.
EOF
}

die() {
    echo "error: $*" >&2
    exit 1
}

log() {
    echo "==> $*"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found on PATH: $1"
}

binary_mode="built"
binary_override=""
input_path=""
output_path=""

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
            --output)
                [[ $# -ge 2 ]] || die "--output requires a value"
                output_path="$2"
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

smoke_check() {
    local binary_path="$1"
    log "Smoke check using $(binary_label): ${binary_path}"
    "${binary_path}" --help >/dev/null
    log "Smoke check passed"
}

list_devices_check() {
    local binary_path="$1"
    local device_output

    log "Listing devices using $(binary_label): ${binary_path}"
    log "Passing preconditions: MoltenVK or equivalent Vulkan portability tooling, VK_KHR_portability_enumeration advertised, and at least one detected GPU."

    device_output="$("${binary_path}" --list-devices 2>&1)"
    printf '%s\n' "${device_output}"

    if ! printf '%s\n' "${device_output}" | grep -Eq '^[[:space:]]*[0-9]+\.[[:space:]]'; then
        die "expected at least one detected GPU entry from --list-devices"
    fi

    log "Device listing passed"
}

generate_sample_input() {
    local destination="$1"
    mkdir -p "$(dirname "${destination}")"
    log "Generating short local sample clip with ffmpeg at ${destination}"
    ffmpeg -y -f lavfi -i testsrc=size=320x180:rate=12 -t 1 -pix_fmt yuv420p "${destination}" >/dev/null 2>&1
}

assert_video_output() {
    local candidate="$1"
    local stream_type

    [[ -s "${candidate}" ]] || die "expected a non-empty output file at ${candidate}"
    stream_type="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of default=nokey=1:noprint_wrappers=1 "${candidate}" | head -n 1)"
    [[ "${stream_type}" == "video" ]] || die "ffprobe did not find a video stream in ${candidate}"
}

sample_realesrgan_check() {
    local binary_path="$1"
    local sample_dir="${VALIDATION_ROOT}/realesrgan"
    local effective_input="${input_path}"
    local effective_output="${output_path}"

    require_command ffmpeg
    require_command ffprobe

    mkdir -p "${sample_dir}"

    if [[ -z "${effective_input}" ]]; then
        effective_input="${sample_dir}/generated-input.mp4"
        generate_sample_input "${effective_input}"
    else
        [[ -f "${effective_input}" ]] || die "input file does not exist: ${effective_input}"
        log "Using caller-supplied input clip: ${effective_input}"
    fi

    if [[ -z "${effective_output}" ]]; then
        effective_output="${sample_dir}/realesrgan-output.mp4"
    fi

    mkdir -p "$(dirname "${effective_output}")"
    rm -f "${effective_output}"

    log "Running Real-ESRGAN sample using $(binary_label): ${binary_path}"
    "${binary_path}" \
        -i "${effective_input}" \
        -o "${effective_output}" \
        -p realesrgan \
        -s 2 \
        --realesrgan-model realesr-animevideov3 \
        --no-progress

    assert_video_output "${effective_output}"
    log "Sample output verified with ffprobe: ${effective_output}"
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
        smoke)
            smoke_check "${binary_path}"
            ;;
        list-devices)
            list_devices_check "${binary_path}"
            ;;
        sample-realesrgan)
            sample_realesrgan_check "${binary_path}"
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
