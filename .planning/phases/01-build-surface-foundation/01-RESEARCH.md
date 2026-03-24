# Phase 1: Build Surface Foundation - Research

**Researched:** 2026-03-24  
**Domain:** Brownfield build-surface design for CMake + `just`  
**Confidence:** MEDIUM

## Summary

Phase 1 should create a contributor interface layer, not a second build system. The current repo already has CMake as the authoritative build graph, but the `.justfile` is carrying too much surface area: it hardcodes generators, build types, install prefixes, and large blocks of `-D...` flags across build, packaging, and test recipes. That makes `just` look like the build system when it should really be the front door.

The right plan is to move shared configuration into `CMakePresets.json`, keep `CMakeLists.txt` as the source of truth for targets and dependency wiring, and make `just` a thin, discoverable wrapper that selects presets and forwards to CMake. For macOS, the phase should stay narrow: Apple Silicon plus latest macOS only, with a small preset matrix that expresses the supported build variants and dependency modes without forcing contributors to reconstruct raw CMake invocations.

Primary recommendation: define one canonical macOS contributor workflow around preset names, and let `just` expose only those entrypoints.

## User Constraints

- Modern Apple Silicon on the latest macOS only.
- `just` is the contributor-facing workflow, but it must stay thin.
- Shared CMake presets are required for supported macOS build variants and dependency modes.
- This is a brownfield C++17 / CMake / FFmpeg / Vulkan / ncnn repo, so Phase 1 should wrap existing systems rather than replace them.
- Packaging, CI, and runtime GPU proof are out of scope for this phase.
- Phase 1 should make the macOS workflow discoverable without forcing contributors to reconstruct raw CMake flags.

## Current Surface

- `.justfile` currently mixes build, test, packaging, and distro-bootstrap responsibilities.
- The build recipes duplicate raw CMake flags instead of selecting a shared preset.
- `CMakeLists.txt` already owns the target graph and dependency selection through cache options such as `VIDEO2X_USE_EXTERNAL_*`, `VIDEO2X_ENABLE_NATIVE`, and `VIDEO2X_BUILD_CLI`.
- There is no checked-in `CMakePresets.json` or `CMakeUserPresets.json` yet.
- The docs tree has Linux and Windows build pages, but no macOS build page or macOS entry in `docs/book/src/SUMMARY.md`.
- `README.md` still presents the project as Linux/Windows-first from a contributor-workflow perspective.

## Standard Stack

| Layer | Standard | Role |
|---|---|---|
| Build system | CMake | Owns target wiring, cache options, install rules, and dependency discovery |
| Contributor interface | `just` | Owns discoverability and short commands, not build logic |
| Shared config | `CMakePresets.json` | Owns canonical configure/build presets for supported macOS modes |
| Local overrides | `CMakeUserPresets.json` | Holds developer-specific overrides outside version control |
| macOS dependency discovery | Homebrew/pkg-config-style system packages | Keeps the first supported macOS workflow simple and reproducible |

## Architecture Patterns

- Keep `CMakeLists.txt` authoritative for compile, link, and install behavior.
- Use a small preset inheritance chain: base macOS preset plus build-type and dependency-mode variants.
- Make `just` forward to preset names rather than assembling raw `cmake` flags.
- Keep local or experimental environment tweaks in `CMakeUserPresets.json` or shell env, not in checked-in recipes.
- Treat `just` recipe names as stable user-facing verbs, while CMake preset names carry the build configuration detail.

## Don't Hand-Roll

- Do not encode macOS-specific raw `cmake -D...` bundles directly in multiple recipes.
- Do not let `just` decide dependency graphs, install layout, or compiler flags beyond selecting a preset.
- Do not split supported macOS build logic between shell conditionals and CMake cache variables.
- Do not pull runtime Vulkan portability handling, device selection changes, or Metal abstractions into this phase.
- Do not add packaging or CI commands to the canonical macOS workflow yet.

## Common Pitfalls

- Treating a successful compile as proof of macOS support. Runtime proof belongs to later phases.
- Allowing `just` recipes to drift into platform-specific mini-scripts.
- Keeping Linux/Windows packaging recipes in the same mental bucket as the canonical contributor workflow.
- Expanding the macOS matrix too early. Phase 1 should choose a small supported set and make that set obvious.
- Ignoring the existing FFmpeg include-dir wiring concern in `CMakeLists.txt` if macOS configure checks expose it. That is a preexisting build-glue risk, not a Phase 1 goal, but it can block verification.

## Code Examples

```text
just build-macos-release  -> cmake --preset <macos-release> && cmake --build --preset <macos-release>
just build-macos-debug    -> cmake --preset <macos-debug> && cmake --build --preset <macos-debug>
just doctor-macos         -> prerequisite checks only; no build-graph logic
```

The exact names can vary, but the pattern should stay the same: `just` forwards to presets, it does not reimplement CMake.

## Planning Implications

- `01-01` should inventory the current `just` recipes and separate contributor workflow from packaging and test noise.
- `01-02` should introduce a minimal macOS preset matrix, likely one Release and one Debug path, and only the dependency modes that the fork will actually support on macOS.
- `01-03` should update discovery text so contributors see the canonical macOS path first, then supporting commands.
- Verification should include `just --list`, preset configure/build dry runs, and a diff review for duplicated flags removed.

## Phase Boundaries

- In Phase 1, touch `.justfile`, `CMakePresets.json`, and the top-level docs or README entrypoints that explain the canonical workflow.
- Defer `docs/book/src/building/linux.md`, `docs/book/src/building/windows.md`, and a first-class macOS build guide to Phase 4.
- Defer `src/`, `tools/`, and Vulkan runtime changes to Phases 2 and 3.
- If a needed macOS dependency mode does not fit cleanly into presets, fix the CMake-side configuration first rather than adding more shell conditionals.

## Sources

- [CMake Presets manual](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
- [CMake `FindVulkan`](https://cmake.org/cmake/help/latest/module/FindVulkan.html)
- [Just programmer's manual](https://just.systems/man/en/)
- [MoltenVK README](https://github.com/KhronosGroup/MoltenVK)
- [ncnn Vulkan notes](https://github.com/Tencent/ncnn/wiki/vulkan-notes)
- [Video2X `.justfile`](/Users/peterryszkiewicz/Repos/video2x/.justfile)
- [Video2X `CMakeLists.txt`](/Users/peterryszkiewicz/Repos/video2x/CMakeLists.txt)
- [Video2X docs building index](/Users/peterryszkiewicz/Repos/video2x/docs/book/src/building/README.md)
- [Video2X docs summary](/Users/peterryszkiewicz/Repos/video2x/docs/book/src/SUMMARY.md)
