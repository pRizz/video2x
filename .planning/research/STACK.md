# Stack Research

**Domain:** Brownfield C++ media pipeline modernization for macOS-first developer workflow and GPU bring-up
**Researched:** 2026-03-24
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| CMake + `CMakePresets.json` | 3.24+ | Canonical configure/build graph | CMake is already the project's build system, presets are the standard way to share reproducible configure/build settings, and CMake 3.24+ can discover `Vulkan::MoltenVK` directly |
| `just` | current stable | Developer command surface | The repo already uses `.justfile`; the right move is to make `just` a thin, discoverable front door over presets, smoke tests, and platform bootstrap instead of replacing CMake |
| Vulkan SDK for macOS | 1.4.341.1 | macOS Vulkan headers, loader, validation, tools | LunarG's official macOS SDK is the recommended way to develop Vulkan apps on macOS and includes MoltenVK plus validation layers |
| MoltenVK | 1.4.1 | Vulkan-over-Metal portability layer | It gives the existing Vulkan-oriented code a practical path onto Apple GPUs without rewriting the project around Metal first |
| ncnn with Vulkan enabled | 20250916 release line or newer | GPU inference for Real-ESRGAN, Real-CUGAN, and RIFE | Upstream publishes macOS and Apple Vulkan artifacts and documents Apple GPUs as supported through Vulkan compute |
| FFmpeg libav* | current upstream / system package | Decode, mux, encode, filter graph | FFmpeg is already central to Video2X; keep it as-is and treat macOS-specific acceleration as an optimization layer, not a new media stack |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `Vulkan::MoltenVK` | via CMake 3.24+ `FindVulkan` | Explicit target for macOS Vulkan portability | Use in macOS presets and link logic instead of ad-hoc SDK path guessing |
| `glslc` / `glslangValidator` | via Vulkan SDK | Shader compilation and validation | Use when shader or SPIR-V validation becomes part of the macOS bring-up workflow |
| Apple `metal-cpp` | current SDK-matched archive | Low-overhead C++ access to Metal | Keep as a fallback for a later native Metal phase only if MoltenVK proves insufficient |
| VideoToolbox | current macOS SDK / FFmpeg support | Optional hardware decode or encode path | Use only after basic macOS build and Vulkan processing work, because FFmpeg documents that filtered pipelines often pay copy costs that erase the benefit |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Xcode / Command Line Tools | Apple Clang, SDKs, linkers | MoltenVK recommends the latest public Xcode and currently supports being built with Xcode 15.0.1 or later |
| Homebrew | macOS dependency install | Use it for contributor bootstrap of `cmake`, `ninja`, `pkg-config`, `just`, `ffmpeg`, `ncnn`, `libomp`, and similar dependencies |
| `vulkaninfo` | Vulkan runtime validation | Add a `just doctor-macos` or equivalent command to prove the SDK and MoltenVK loader are wired correctly |
| `video2x --list-devices` | Project-level GPU verification | Use this as a repo-native smoke check after build succeeds |

## Installation

```bash
# Core macOS toolchain
brew install cmake ninja pkg-config just ffmpeg ncnn libomp

# Vulkan SDK / MoltenVK
# Install the official LunarG macOS Vulkan SDK and source its setup-env.sh

# Project flow
just doctor-macos
just build-macos
just smoke-macos
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `just` + CMake Presets | raw `cmake` commands only | Use raw CMake only for CI internals or debugging; it is not ergonomic enough as the contributor-facing interface |
| MoltenVK portability path | Native Metal backend immediately | Use native Metal only if measured performance or missing Vulkan features make MoltenVK unacceptable after bring-up |
| System packages on macOS via Homebrew | Vendoring every dependency into this repo | Vendor only dependencies that are unstable or operationally painful on macOS; otherwise prefer simpler bootstrap |
| Optional VideoToolbox optimization later | VideoToolbox-first architecture | Use VideoToolbox tactically for encode/decode tuning after the compute path works, not as the answer to Vulkan inference portability |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Replacing CMake with `just` | `just` is a command runner, not a build graph or dependency model | Keep CMake authoritative and let `just` wrap presets and checks |
| Direct Metal rewrite in the first milestone | The current processors and `libplacebo` path are Vulkan-oriented, so a first-pass Metal port explodes scope immediately | Bring up macOS through Vulkan SDK + MoltenVK first |
| Ad-hoc SDK path handling scattered across docs and recipes | It creates "works on my machine" failures on macOS | Centralize in presets, helper scripts, and a single doctor/bootstrap path |
| Treating VideoToolbox as the main GPU strategy | FFmpeg warns that most hwaccel paths are mainly useful for testing and often require copies back to system memory when filtering | Keep the primary processing stack on Vulkan/MoltenVK |

## Stack Patterns by Variant

**If the goal is fastest bring-up:**
- Use Homebrew-installed userland dependencies, the official Vulkan SDK, and `just` wrappers over CMake presets
- Because this minimizes repo churn while making macOS reproducible quickly

**If the goal becomes upstreamable long-term support:**
- Add repo-checked-in presets, explicit dependency modes, smoke tests, and documentation before adding CI or packaging
- Because upstreamability depends more on clarity and repeatability than on heroic platform hacks

**If MoltenVK performance or feature coverage proves insufficient:**
- Prototype a narrow native Metal spike around the hottest bottleneck rather than rewriting the whole stack
- Because Apple offers `metal-cpp`, but the project should only pay that cost where measurements justify it

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| CMake 3.24+ | Vulkan SDK / MoltenVK | 3.24 introduces `FindVulkan` support for the `MoltenVK` component |
| Vulkan SDK 1.4.341.1 | MoltenVK 1.4.x | LunarG's macOS SDK includes MoltenVK and the validation layers needed for bring-up |
| ncnn 20250916+ | Apple Silicon + Vulkan compute | Upstream release artifacts include macOS Vulkan packages and Apple GPU support is documented in Vulkan notes |
| Latest public Xcode | MoltenVK 1.4.x | MoltenVK recommends the latest public Xcode and documents support from Xcode 15.0.1 upward |

## Sources

- Local repo: `.justfile`, `CMakeLists.txt`, `docs/book/src/building/linux.md`, `docs/book/src/building/windows.md` — current build surface and platform bias
- CMake presets manual: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html — shared configure/build settings and checked-in preset workflow
- CMake `FindVulkan`: https://cmake.org/cmake/help/latest/module/FindVulkan.html — `MoltenVK` component and `VULKAN_SDK` handling
- LunarG Vulkan SDK latest macOS version: https://vulkan.lunarg.com/sdk/latest/mac.json — current official macOS SDK version
- MoltenVK README: https://github.com/KhronosGroup/MoltenVK — recommended macOS Vulkan path, Xcode guidance, and portability behavior
- Vulkan portability enumeration spec: https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_portability_enumeration.html — required enumeration behavior for portability devices
- Apple Metal overview: https://developer.apple.com/metal/ — native Apple GPU direction and platform scope
- Apple metal-cpp: https://developer.apple.com/metal/cpp/ — direct C++ Metal path if a later native backend becomes necessary
- ncnn releases: https://github.com/Tencent/ncnn/releases — published macOS / Apple Vulkan artifacts
- ncnn Vulkan notes: https://github.com/Tencent/ncnn/wiki/vulkan-notes — Apple GPU support and Vulkan compute usage
- ncnn build guide: https://github.com/Tencent/ncnn/wiki/how-to-build — macOS build and Homebrew guidance
- FFmpeg CLI docs: https://ffmpeg.org/ffmpeg.html — Vulkan device init and VideoToolbox caveats

---
*Stack research for: macOS-first Video2X modernization*
*Researched: 2026-03-24*
