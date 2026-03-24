#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_HOMEBREW_PREFIX="/opt/homebrew"

baseline_failures=0
system_failures=0
warnings=0

have_command() {
    command -v "$1" >/dev/null 2>&1
}

path_has_entry() {
    case ":${PATH}:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

print_section() {
    printf '\n== %s ==\n' "$1"
}

print_status() {
    printf '[%s] %s\n' "$1" "$2"
}

print_detail() {
    printf '      %s\n' "$1"
}

pass() {
    print_status "PASS" "$1"
}

warn() {
    warnings=$((warnings + 1))
    print_status "WARN" "$1"
}

fail_baseline() {
    baseline_failures=$((baseline_failures + 1))
    print_status "FAIL" "$1"
}

fail_system() {
    system_failures=$((system_failures + 1))
    print_status "FAIL" "$1"
}

formula_version() {
    local formula="$1"
    local maybe_version

    if maybe_version=$(brew list --versions "$formula" 2>/dev/null); then
        printf '%s\n' "${maybe_version#${formula} }"
        return 0
    fi

    return 1
}

formula_prefix() {
    local formula="$1"
    brew --prefix "$formula" 2>/dev/null
}

describe_tool() {
    local tool="$1"
    local maybe_path

    if maybe_path=$(command -v "$tool" 2>/dev/null); then
        printf '%s\n' "$maybe_path"
        return 0
    fi

    return 1
}

pkg_config_executable=""
pkg_config_source=""

if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'macOS doctor only runs on macOS hosts.\n'
    exit 1
fi

printf 'Video2X macOS doctor\n'
printf 'Checking Apple Silicon prerequisite readiness for preset-backed builds.\n'

print_section "Host"
host_architecture="$(uname -m)"
if [[ "$host_architecture" == "arm64" ]]; then
    pass "Apple Silicon host detected (${host_architecture})."
else
    fail_baseline "Unsupported host architecture '${host_architecture}'. Phase 02 targets Apple Silicon macOS only."
fi

print_section "Apple Toolchain"
if developer_dir=$(xcode-select --print-path 2>/dev/null); then
    pass "Active developer directory: ${developer_dir}"
else
    fail_baseline "Xcode or Command Line Tools are not selected."
    print_detail "Run 'xcode-select --install' or switch to a valid Xcode.app before configuring."
fi

if xcode_version=$(xcodebuild -version 2>/dev/null); then
    pass "xcodebuild is available."
    while IFS= read -r line; do
        print_detail "$line"
    done <<<"$xcode_version"
else
    fail_baseline "xcodebuild is unavailable. The Apple compiler and SDK toolchain are not ready."
fi

print_section "Homebrew"
if brew_path=$(describe_tool brew); then
    pass "Homebrew executable found at ${brew_path}"
    brew_prefix="$(brew --prefix 2>/dev/null)"
    print_detail "brew --prefix => ${brew_prefix}"

    if [[ "$brew_prefix" == "$EXPECTED_HOMEBREW_PREFIX" ]]; then
        pass "Apple Silicon Homebrew prefix matches ${EXPECTED_HOMEBREW_PREFIX}."
    else
        warn "Homebrew prefix is ${brew_prefix}; Apple Silicon default is ${EXPECTED_HOMEBREW_PREFIX}."
    fi

    if path_has_entry "${EXPECTED_HOMEBREW_PREFIX}/bin"; then
        pass "${EXPECTED_HOMEBREW_PREFIX}/bin is on PATH."
    else
        fail_baseline "${EXPECTED_HOMEBREW_PREFIX}/bin is missing from PATH."
        print_detail "Expected Apple Silicon Homebrew tools such as pkg-config, ninja, and Vulkan helpers to be shell-visible."
    fi

    if [[ -d "${EXPECTED_HOMEBREW_PREFIX}/sbin" ]]; then
        if path_has_entry "${EXPECTED_HOMEBREW_PREFIX}/sbin"; then
            pass "${EXPECTED_HOMEBREW_PREFIX}/sbin is on PATH."
        else
            warn "${EXPECTED_HOMEBREW_PREFIX}/sbin is not on PATH."
        fi
    fi
else
    fail_baseline "Homebrew is not installed or not on PATH."
    print_detail "Apple Silicon contributors are expected to use Homebrew under ${EXPECTED_HOMEBREW_PREFIX}."
fi

print_section "Baseline Build Surface"

if cmake_path=$(describe_tool cmake); then
    pass "cmake found at ${cmake_path}"
else
    fail_baseline "cmake is missing."
fi

if ninja_path=$(describe_tool ninja); then
    pass "ninja found at ${ninja_path}"
else
    fail_baseline "ninja is missing."
fi

if ffmpeg_path=$(describe_tool ffmpeg); then
    pass "ffmpeg found at ${ffmpeg_path}"
else
    fail_baseline "ffmpeg is missing."
fi

if [[ -n "${PKG_CONFIG_EXECUTABLE:-}" ]]; then
    if [[ -x "${PKG_CONFIG_EXECUTABLE}" ]]; then
        pkg_config_executable="${PKG_CONFIG_EXECUTABLE}"
        pkg_config_source="PKG_CONFIG_EXECUTABLE"
        pass "Using pkg-config executable from PKG_CONFIG_EXECUTABLE: ${pkg_config_executable}"
    else
        fail_baseline "PKG_CONFIG_EXECUTABLE points to a non-executable path: ${PKG_CONFIG_EXECUTABLE}"
        print_detail "This still trips CMake's 'Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)' gate."
    fi
fi

if [[ -z "$pkg_config_executable" ]]; then
    if pkg_config_path=$(describe_tool pkg-config); then
        pkg_config_executable="$pkg_config_path"
        pkg_config_source="PATH"
        pass "pkg-config found at ${pkg_config_executable}"
    elif pkgconf_path=$(describe_tool pkgconf); then
        pkg_config_executable="$pkgconf_path"
        pkg_config_source="PATH"
        pass "pkgconf found at ${pkg_config_executable}"
    else
        fail_baseline "Missing pkg-config / pkgconf."
        print_detail "This is the same gate behind CMake's 'Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)'."
        print_detail "Install pkgconf or configure CMake with -DPKG_CONFIG_EXECUTABLE=/path/to/pkg-config."
    fi
fi

if [[ -n "$pkg_config_executable" ]]; then
    print_detail "PkgConfig source: ${pkg_config_source}"
    missing_ffmpeg_modules=()
    for module in libavcodec libavfilter libavformat libavutil libswscale; do
        if "$pkg_config_executable" --exists "$module"; then
            pass "pkg-config resolves ${module}"
        else
            missing_ffmpeg_modules+=("$module")
        fi
    done

    if [[ ${#missing_ffmpeg_modules[@]} -gt 0 ]]; then
        fail_baseline "pkg-config cannot resolve required FFmpeg modules: ${missing_ffmpeg_modules[*]}"
        print_detail "CMake's pkg_check_modules(...) calls will fail until those module files are discoverable."
    fi
else
    warn "Skipping FFmpeg pkg-config module probe because the PkgConfig gate is not satisfied."
fi

print_section "Vulkan Portability Surface"

vulkan_stack_ready=false
if [[ -n "${VULKAN_SDK:-}" ]]; then
    if [[ -d "${VULKAN_SDK}" ]]; then
        pass "VULKAN_SDK is set: ${VULKAN_SDK}"
        vulkan_stack_ready=true
    else
        fail_baseline "VULKAN_SDK is set but the directory does not exist: ${VULKAN_SDK}"
    fi
else
    warn "VULKAN_SDK is not set."
fi

if vulkaninfo_path=$(describe_tool vulkaninfo); then
    pass "vulkaninfo found at ${vulkaninfo_path}"
    vulkan_stack_ready=true
else
    fail_baseline "vulkaninfo is missing."
    print_detail "Install the Vulkan SDK or ensure MoltenVK tooling is exposed on PATH."
fi

if glslang_path=$(describe_tool glslangValidator); then
    pass "glslangValidator found at ${glslang_path}"
    vulkan_stack_ready=true
else
    fail_baseline "glslangValidator is missing."
    print_detail "ncnn Vulkan shader compilation support is not fully preflighted without it."
fi

if have_command brew; then
    if molten_vk_version=$(formula_version molten-vk); then
        pass "molten-vk formula installed (${molten_vk_version})"
        molten_vk_prefix="$(formula_prefix molten-vk)"
        print_detail "molten-vk prefix => ${molten_vk_prefix}"
        vulkan_stack_ready=true
    else
        warn "molten-vk formula is not installed through Homebrew."
    fi
fi

if [[ "$vulkan_stack_ready" != true ]]; then
    fail_baseline "Neither a usable Vulkan SDK path nor MoltenVK tooling was detected."
fi

print_section "System-Mode Extra Dependencies"
print_detail "These checks only gate the macos-system-* presets. Vendored mode remains acceptable when this section is incomplete."

if have_command brew; then
    if ncnn_version=$(formula_version ncnn); then
        pass "ncnn formula installed (${ncnn_version})"
        print_detail "ncnn prefix => $(formula_prefix ncnn)"
    else
        fail_system "ncnn is missing for macos-system-* (CMake: find_package(ncnn REQUIRED))."
    fi

    if spdlog_version=$(formula_version spdlog); then
        pass "spdlog formula installed (${spdlog_version})"
        print_detail "spdlog prefix => $(formula_prefix spdlog)"
    else
        fail_system "spdlog is missing for macos-system-* (CMake: find_package(spdlog REQUIRED))."
    fi

    if boost_version=$(formula_version boost); then
        pass "boost formula installed (${boost_version})"
        print_detail "boost prefix => $(formula_prefix boost)"
        print_detail "Boost::program_options comes from this formula for the system presets."
    else
        fail_system "boost is missing for macos-system-* (CMake: find_package(Boost REQUIRED COMPONENTS program_options))."
    fi
else
    fail_system "Cannot inspect ncnn, spdlog, or boost because Homebrew is unavailable."
fi

print_section "Summary"

if (( baseline_failures == 0 )); then
    print_status "PASS" "Baseline macOS prerequisites are ready for the vendored presets."
else
    print_status "FAIL" "Baseline macOS prerequisites are not ready for preset-backed builds yet."
fi

if (( system_failures == 0 )); then
    print_status "PASS" "System-mode extras are ready for macos-system-*."
else
    print_status "FAIL" "System-mode extras are not ready for macos-system-*."
    print_detail "Vendored mode is still the fallback path once the baseline section passes."
fi

printf '\nResult: %d baseline issue(s), %d system-mode issue(s), %d warning(s).\n' \
    "$baseline_failures" \
    "$system_failures" \
    "$warnings"

if (( baseline_failures > 0 || system_failures > 0 )); then
    exit 1
fi
