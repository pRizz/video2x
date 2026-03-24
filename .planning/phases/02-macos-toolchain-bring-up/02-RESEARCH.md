# Phase 2: macOS Toolchain Bring-Up - Research

**Researched:** 2026-03-24  
**Domain:** macOS Apple Silicon toolchain validation, CMake preset-backed builds, Homebrew/Vulkan SDK dependency setup  
**Confidence:** HIGH

## User Constraints

- Keep Phase 2 focused on prerequisite validation, build execution, and clean-checkout reproducibility.
- Use `just` as the contributor-facing workflow and keep the shared CMake presets as the source of truth.
- Target the latest macOS on Apple Silicon only.
- Do not drift into runtime smoke tests, GPU enumeration, packaging, CI, or a full macOS docs-book guide.
- Keep `CMakeLists.txt` authoritative unless preset-driven configure/build validation exposes a real incompatibility.

## Summary

Phase 1 already established the macOS Apple Silicon preset matrix and the thin `just` wrappers, so Phase 2 is not about inventing a new build surface. The work now is to make the prerequisite story explicit enough that a contributor can tell, in one command, whether their machine is ready for the configured system or vendored macOS builds. The current repo state shows the gap clearly: `cmake --preset macos-system-release` fails early on this machine because `PkgConfig` is missing, even though Xcode and Homebrew are otherwise present.

The planning target should be a small, fail-fast diagnostic path plus build verification that exercises the actual preset-backed workflow from a clean tree. The build side is already encoded in `CMakePresets.json` and `.justfile`; the missing work is to surface the macOS toolchain requirements, verify PATH and SDK discovery rather than only package installation, and make the system-versus-vendored dependency modes understandable to contributors before they hit CMake errors.

**Primary recommendation:** add one contributor-facing macOS doctor command that checks Xcode, Homebrew/PATH, `pkg-config`, Vulkan SDK/MoltenVK, and the relevant system packages, then validate both Release and Debug preset builds from a clean checkout using the existing `just` wrappers.

## Current Repo Reality

### What Already Exists

- `CMakePresets.json` defines four explicit macOS arm64 configure presets: system/vendored Release and Debug.
- `.justfile` already exposes thin `configure-*` and `build-*` recipes that forward directly to those presets.
- `README.md` and `CONTRIBUTING.md` already advertise the Apple Silicon macOS source-build boundary and the canonical `just` commands.
- `CMakeLists.txt` already encodes the real dependency contract:
  - non-Windows builds require `PkgConfig`
  - system builds require `ncnn`, `spdlog`, `Boost::program_options`, and `Vulkan`
  - FFmpeg discovery uses `pkg_check_modules(...)`

### Current Local Failure Signals

- `cmake --preset macos-system-release` currently fails at `Could NOT find PkgConfig`.
- Present on PATH: `cmake`, `ninja`, `ffmpeg`.
- Missing on PATH: `pkg-config`, `pkgconf`, `vulkaninfo`, `glslangValidator`, `ncnn-config`.
- `xcode-select --print-path` and `xcodebuild -version` are already valid on this machine.
- `brew --prefix` resolves to `/opt/homebrew`.

## Standard Stack

### Core

| Component | Current guidance / version | Purpose | Why it matters for this phase |
|---|---|---|---|
| `just` | existing repo workflow | Contributor entrypoint | Phase 2 should preserve the thin command surface from Phase 1. |
| CMake presets | `macos-system-*`, `macos-vendored-*` | Shared macOS build definitions | The build flow should stay preset-backed, not raw-flag-driven. |
| CMake | project minimum 3.27 in presets, 3.10 in `CMakeLists.txt` | Configure/build orchestration | The doctor should validate the same CMake path contributors use. |
| Ninja | installed locally | Build backend | Preset builds already target Ninja. |
| Xcode / Command Line Tools | Xcode 26.3 observed locally; Homebrew `molten-vk` requires Xcode >= 11.7 | Apple toolchain and SDK discovery | Needed for compiler, linker, and SDK/toolchain checks. |
| `pkgconf` | stable 2.5.1, install command `brew install pkgconf` | Provides `pkg-config` / `pkgconf` | `find_package(PkgConfig REQUIRED)` is the first macOS configure gate. |
| Vulkan SDK | official Vulkan toolchain for macOS | Loader, headers, `vulkaninfo`, validation layers | Official guidance still centers the SDK for macOS Vulkan support. |
| MoltenVK | stable 1.4.1, install command `brew install molten-vk` | Vulkan-on-Metal portability layer | macOS Vulkan is portability-based, not native. |

### Supporting

| Component | Current guidance / version | Purpose | Why it matters for this phase |
|---|---|---|---|
| FFmpeg | already present locally | Media I/O and transcoding | `pkg_check_modules(...)` makes this a required configure-time dependency. |
| Boost | stable 1.90.0 | `program_options` for the CLI | System builds require `find_package(Boost REQUIRED COMPONENTS program_options)`. |
| spdlog | stable 1.17.0 | Logging | System builds require `find_package(spdlog REQUIRED)`. |
| ncnn | stable 20260113 | Neural network inference backend | System builds require `find_package(ncnn REQUIRED)`; vendored builds still need the Vulkan toolchain path. |
| ncnn transitive deps | `abseil`, `glslang`, `libomp`, `protobuf`, `spirv-tools`, `molten-vk` | Homebrew dependency chain | Useful when diagnosing why `brew install ncnn` does or does not satisfy CMake discovery. |

## Architecture Patterns

### Keep The Build Surface Thin

- Keep `just` recipes as direct wrappers around preset names.
- Keep the system/vendored and Release/Debug matrix in `CMakePresets.json`, not duplicated in scripts.
- If the doctor logic grows beyond a few checks, place the logic in a small script and let `just` call it.

### Make Prerequisite Validation Aggregated

- The doctor command should report all missing prerequisites in one pass, not stop at the first error.
- Group diagnostics by subsystem: Apple toolchain, Homebrew/PATH, FFmpeg, Vulkan SDK/MoltenVK, and system-only libraries.
- Report the exact missing executable or package name and the fix command where possible.

### Validate The Real CMake Contract

- Prefer a short configure probe against the existing presets over a custom dependency resolver.
- Validate `pkg-config` discovery, CMake package discovery, and SDK/tool availability, not just installed package names.
- Reuse the preset names already checked in: `macos-system-release`, `macos-system-debug`, `macos-vendored-release`, `macos-vendored-debug`.

## Build-Mode Matrix

| Mode | Preset | Required external pieces | Planning implication |
|---|---|---|---|
| System Release | `macos-system-release` | Xcode, `pkg-config`, FFmpeg, ncnn, spdlog, Boost, Vulkan SDK/MoltenVK | This is the canonical contributor path to validate first. |
| System Debug | `macos-system-debug` | Same as system Release | Needed to prove contributors do not need custom Debug flags. |
| Vendored Release | `macos-vendored-release` | Xcode, `pkg-config`, FFmpeg, Vulkan SDK/MoltenVK | Confirms the fallback dependency mode still works on macOS. |
| Vendored Debug | `macos-vendored-debug` | Same as vendored Release | Useful as a mismatch detector between presets and build recipes. |

## Don't Hand-Roll

- Do not replace the shared presets with raw `cmake -D...` commands in docs or recipes.
- Do not build a second dependency manager around Homebrew; just validate the dependencies CMake actually needs.
- Do not assume `brew list` is enough; PATH discovery matters because `pkg-config`, `vulkaninfo`, and `glslangValidator` can still be missing from PATH.
- Do not treat `ncnn-config` as the contract; the repo uses `find_package(ncnn REQUIRED)`.
- Do not expand this phase into runtime smoke tests, GPU enumeration, packaging, CI, or the full macOS docs guide.
- Do not rewrite `CMakeLists.txt` unless a real preset-driven incompatibility is proven.

## Common Pitfalls

- `pkgconf` may be installed while `pkg-config` is still missing from PATH.
- `find_package(PkgConfig REQUIRED)` fails before any higher-level dependency check, so the doctor should surface that clearly.
- On macOS, Vulkan is portability-based; the Vulkan SDK provides the loader and tools, and MoltenVK provides the Metal-backed implementation.
- System builds have more failure points because CMake must find `ncnn`, `spdlog`, and Boost in addition to FFmpeg and Vulkan.
- A stale `build/` tree can hide clean-checkout issues; Phase 2 verification should start from fresh preset build directories.
- Checking only installed packages misses missing executables such as `vulkaninfo` and `glslangValidator`.

## Likely File Touch Points

- `.justfile` for a new macOS doctor/bootstrap recipe and any helper recipe names.
- `scripts/` for a small macOS prerequisite checker if the logic becomes more than a few shell checks.
- `README.md` and `CONTRIBUTING.md` only if the canonical command names or prerequisite summary need to be surfaced.
- `CMakePresets.json` only if a real clean-build mismatch appears during validation.
- `docs/book` should stay out of scope for Phase 2 unless a small wording fix is required to keep the current workflow accurate.

## Code Examples

### Canonical Contributor Flow

```bash
just doctor-macos
just configure-macos-system-release
just build-macos-system-release
```

### Expected Diagnostic Coverage

- `xcode-select --print-path`
- `xcodebuild -version`
- `brew --prefix`
- `command -v pkg-config`
- `command -v vulkaninfo`
- `command -v glslangValidator`
- `cmake --preset macos-system-release`
- `cmake --build --preset macos-system-release`

## Phase 2 Planning Implications

1. Plan the doctor work as a separate deliverable from the build recipes.
2. Make the doctor output actionable enough that missing macOS setup is obvious without reading docs first.
3. Verify both system and vendored preset builds from a clean tree, with Release and Debug covered.
4. Treat Vulkan SDK / MoltenVK as the macOS portability baseline now; deeper runtime portability behavior belongs to Phase 3.

## Sources

- [Homebrew Formulae: pkgconf](https://formulae.brew.sh/formula/pkgconf)
- [Homebrew Formulae: molten-vk](https://formulae.brew.sh/formula/molten-vk)
- [Homebrew Formulae: ncnn](https://formulae.brew.sh/formula/ncnn)
- [Homebrew Formulae: spdlog](https://formulae.brew.sh/formula/spdlog)
- [Homebrew Formulae: boost](https://formulae.brew.sh/formula/boost)
- [Vulkan Guide: Checking For Vulkan Support](https://docs.vulkan.org/guide/latest/checking_for_support.html)
- [Vulkan Guide: Loader](https://docs.vulkan.org/guide/latest/loader.html)
- [Vulkan Guide: Platforms](https://docs.vulkan.org/guide/latest/platforms.html)
- [Vulkan Guide: Development Environments & IDEs](https://docs.vulkan.org/guide/latest/ide.html)
- [Vulkan Guide: Portability Initiative](https://docs.vulkan.org/guide/latest/portability_initiative.html)
