# Project Research Summary

**Project:** Video2X macOS-first build and GPU enablement
**Domain:** Brownfield build-system redesign and Apple Silicon platform enablement
**Researched:** 2026-03-24
**Confidence:** MEDIUM

## Executive Summary

The research points to a clear first move: keep CMake as the authoritative build system, promote `just` into the contributor-facing command surface, and formalize shared configuration in `CMakePresets.json`. That solves the immediate developer-experience problem without throwing away the existing build graph or pushing more logic into opaque shell recipes.

For macOS GPU support, the shortest credible path is Vulkan SDK plus MoltenVK, not a direct native Metal rewrite. MoltenVK is explicitly designed to run Vulkan over Metal on Apple platforms, ncnn documents Apple GPU support through Vulkan compute, and the existing Video2X processors are already Vulkan-oriented. The main risk is assuming that "builds on macOS" equals "supports macOS"; the roadmap therefore needs explicit device-listing and smoke-workload validation before any packaging, CI, or backend rewrite work is justified.

## Key Findings

### Recommended Stack

The recommended stack is conservative in architecture and aggressive in ergonomics: CMake 3.24+ with presets, `just` as the human interface, LunarG's macOS Vulkan SDK, MoltenVK as the initial GPU portability layer, Homebrew for contributor dependency bootstrap, and the existing FFmpeg/ncnn/libplacebo runtime kept intact.

**Core technologies:**
- CMake 3.24+: shared presets and direct `MoltenVK` discovery
- `just`: discoverable contributor commands over the existing build graph
- Vulkan SDK + MoltenVK: initial Apple Silicon GPU path without a backend rewrite
- ncnn Vulkan: existing inference backend with published macOS / Apple Vulkan support
- FFmpeg: existing media pipeline, with VideoToolbox treated as optional later optimization

### Expected Features

For this project, the "product" is the developer workflow and platform-support surface.

**Must have (table stakes):**
- macOS doctor/bootstrap command — contributors need an obvious first step
- macOS build/install command — the core promise is convenience
- macOS smoke + GPU validation command — the platform claim must be runtime-proven
- macOS build docs — first-class support is partly documentation quality

**Should have (competitive):**
- Explicit MoltenVK/Vulkan strategy documentation — reduces thrash and wrong turns
- Cross-platform naming consistency in `just` commands — reduces cognitive load
- Benchmark commands — makes Apple Silicon decisions evidence-based

**Defer (v2+):**
- Packaging/distribution
- macOS CI
- Native Metal backend experimentation

### Architecture Approach

Architecturally, the repo should gain a new contributor-interface layer rather than a new build system. `just` should stay thin, presets should own shared configuration, macOS dependency resolution should become explicit, and repo-native validation commands should prove the runtime path on Apple Silicon. This complements the existing `libvideo2x` / CLI architecture instead of fighting it.

**Major components:**
1. Contributor interface — `just` commands and build docs
2. Shared build configuration — presets and platform helper scripts
3. Validation layer — doctor, device listing, and smoke tests
4. Existing runtime — current FFmpeg + Vulkan + ncnn + libplacebo pipeline

### Critical Pitfalls

1. **Missing portability-aware Vulkan enumeration** — add explicit macOS device validation early
2. **VideoToolbox-first thinking** — keep it optional until the actual processing path works
3. **`just` recipe sprawl** — make presets authoritative and recipes shallow
4. **Native Metal too early** — only justify it with measurements
5. **Calling compilation success "macOS support"** — require runtime smoke proof

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Build Surface Unification
**Rationale:** The core pain is contributor friction and unclear macOS workflow.
**Delivers:** Shared presets, cleaned-up `just` interface, and macOS-facing docs scaffolding.
**Addresses:** command ergonomics, preset-driven configuration, platform parity.
**Avoids:** shell-logic sprawl.

### Phase 2: macOS Bring-Up and Dependency Validation
**Rationale:** After the command surface exists, the repo needs an explicit Apple Silicon build path.
**Delivers:** macOS bootstrap/doctor flow, Apple Silicon build preset, and documented SDK/dependency setup.
**Uses:** Homebrew, Vulkan SDK, MoltenVK.
**Implements:** platform adapter layer.

### Phase 3: Runtime Smoke and GPU Proof
**Rationale:** "Builds" is not sufficient evidence for platform support.
**Delivers:** `video2x --list-devices` validation, sample workload smoke tests, and early benchmark/proof points.
**Uses:** existing CLI/runtime and MoltenVK-backed Vulkan path.
**Implements:** validation layer.

### Phase 4: Optimization and Strategy Decisions
**Rationale:** Only after bring-up and smoke proof should the project decide whether deeper GPU/backend work is needed.
**Delivers:** measured gaps, optional VideoToolbox experiments, and a go/no-go decision on any native Metal spike.

### Phase Ordering Rationale

- Presets and command ergonomics come first because every later phase depends on a stable contributor workflow.
- macOS dependency bring-up comes before runtime benchmarking because a broken or implicit SDK setup poisons all later results.
- Runtime smoke proof comes before optimization because the project needs correctness before it needs speed.
- Native Metal is intentionally last because the existing codebase is already strongly Vulkan-shaped.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** precise macOS dependency mode and SDK discovery details
- **Phase 4:** whether measured MoltenVK results justify any native Metal work

Phases with standard patterns (skip research-phase):
- **Phase 1:** `just` + CMake preset cleanup is established engineering practice

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Grounded in official CMake, LunarG, MoltenVK, Apple, ncnn, and FFmpeg docs |
| Features | MEDIUM | Derived from repo context and common contributor-workflow expectations |
| Architecture | MEDIUM | Strongly informed by the existing codebase, but exact preset/scripting shape is still a project choice |
| Pitfalls | HIGH | Backed by explicit portability, hwaccel, and tooling guidance from upstream docs |

**Overall confidence:** MEDIUM

### Gaps to Address

- Exact code changes needed for portability-aware Vulkan enumeration inside this repo
- Whether the shipped processor stack behaves acceptably on Apple GPUs under MoltenVK
- Which dependencies should stay system-installed on macOS versus be vendored or prebuilt

## Sources

### Primary (HIGH confidence)
- CMake presets manual: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html
- CMake `FindVulkan`: https://cmake.org/cmake/help/latest/module/FindVulkan.html
- LunarG Vulkan SDK macOS version feed: https://vulkan.lunarg.com/sdk/latest/mac.json
- MoltenVK README: https://github.com/KhronosGroup/MoltenVK
- Vulkan portability enumeration spec: https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_portability_enumeration.html
- Apple Metal overview: https://developer.apple.com/metal/
- Apple metal-cpp: https://developer.apple.com/metal/cpp/
- ncnn releases: https://github.com/Tencent/ncnn/releases
- ncnn build guide: https://github.com/Tencent/ncnn/wiki/how-to-build
- ncnn Vulkan notes: https://github.com/Tencent/ncnn/wiki/vulkan-notes
- FFmpeg docs: https://ffmpeg.org/ffmpeg.html

### Secondary (MEDIUM confidence)
- Local repo sources: `.justfile`, `CMakeLists.txt`, `docs/book/src/building/*.md`, `.planning/codebase/*.md`

---
*Research completed: 2026-03-24*
*Ready for roadmap: yes*
