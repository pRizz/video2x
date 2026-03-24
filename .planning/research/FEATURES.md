# Feature Research

**Domain:** Cross-platform developer workflow and Apple Silicon platform enablement for an existing C++ media app
**Researched:** 2026-03-24
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Users Expect These)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| One-command or two-command macOS bootstrap | Contributors expect a clean path from clone to build on a first-class platform | MEDIUM | Usually split into `doctor/bootstrap` plus `build` |
| Shared configure/build presets | Cross-platform CMake projects are expected to encode common build modes centrally | MEDIUM | Best expressed with `CMakePresets.json` and wrapped by `just` |
| Smoke-test commands | Build systems need proof that the produced binary actually runs | LOW | For this repo, `video2x --help`, `--list-devices`, and a short sample clip are the obvious checks |
| Dependency diagnostics | macOS failures are otherwise opaque: Xcode, Homebrew packages, Vulkan SDK, and env vars must all line up | MEDIUM | A `doctor-macos` target matters as much as `build-macos` |
| Platform docs parity | If macOS is first-class, docs must sit alongside Linux and Windows build instructions | LOW | Missing docs make the platform feel unofficial even if builds work |

### Differentiators (Competitive Advantage)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| macOS GPU-path research baked into project docs | Prevents wasted effort on the wrong backend direction | MEDIUM | This is especially valuable because the current codebase is Vulkan-first, not Metal-first |
| Explicit MoltenVK bring-up validation | Turns portability from guesswork into a repeatable developer flow | MEDIUM | Add commands that verify Vulkan SDK, loader, portability enumeration, and device listing |
| Consistent `just` interface across Linux, Windows, and macOS | Reduces contributor context switching and hides legacy recipe differences | MEDIUM | Keep the command names parallel even if implementations differ |
| Benchmark and backend sanity commands | Makes it possible to compare Apple Silicon bring-up quality instead of relying on anecdotes | MEDIUM | Add after basic smoke tests, not before |
| Clear dependency modes | Distinguish Homebrew/system deps from vendored or prebuilt deps in a single interface | HIGH | This becomes important when deciding how much macOS should mirror Linux or Windows |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| "Rewrite everything around native Metal immediately" | Native APIs feel like the "proper" Apple answer | The repo's current processors are Vulkan-centric, so this multiplies scope before basic macOS support exists | Start with MoltenVK and isolate any later native Metal spike to the hottest bottleneck |
| "Make `just` the build system" | It sounds simpler than CMake | It hides configuration state in shell recipes and becomes hard to reuse in CI or IDEs | Keep CMake authoritative and let `just` orchestrate |
| "Ship packaging and CI in the same first milestone" | It feels complete | It delays the more important local workflow and GPU-path proof work | Defer packaging and CI until local macOS bring-up is stable |

## Feature Dependencies

```text
doctor/bootstrap
    └──requires──> configure preset
                           └──requires──> build/install
                                                  └──requires──> smoke test
                                                                         └──requires──> GPU validation

documentation ──enables──> contributor success
benchmarking ──enhances──> GPU validation
packaging/CI  ──depends on──> stable local workflow
```

### Dependency Notes

- **GPU validation requires a successful smoke build:** there is no value in measuring MoltenVK or Apple GPU behavior before the binary and models load correctly.
- **Packaging and CI depend on a stable local macOS story:** otherwise automation will codify the wrong assumptions.
- **Documentation is part of the feature set:** for a build workflow project, unclear docs are effectively a missing feature.

## MVP Definition

### Launch With (v1)

- [ ] `just doctor-macos` or equivalent dependency and environment validation — essential because the current macOS path is unclear
- [ ] `just build-macos` backed by shared CMake presets — essential because contributor ergonomics are the core value
- [ ] `just smoke-macos` that proves the binary launches and sees the GPU path — essential because "builds" is not enough
- [ ] A written decision on the initial macOS GPU strategy — essential because the roadmap depends on it
- [ ] macOS build docs that match Linux/Windows quality — essential to make the platform truly first-class

### Add After Validation (v1.x)

- [ ] Benchmark commands for Apple Silicon GPU paths — add once the smoke path is trustworthy
- [ ] Optional VideoToolbox experiments for decode/encode — add only if the primary compute path is working
- [ ] More polished dependency-mode switches — add once the default contributor flow is stable

### Future Consideration (v2+)

- [ ] macOS packaging/distribution — deferred by user decision
- [ ] macOS CI automation — useful, but not part of first success
- [ ] Native Metal backend work — only if MoltenVK-based results are inadequate

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| macOS doctor/bootstrap flow | HIGH | MEDIUM | P1 |
| macOS build/install flow | HIGH | MEDIUM | P1 |
| macOS smoke and GPU validation flow | HIGH | MEDIUM | P1 |
| Documentation parity | HIGH | LOW | P1 |
| Benchmark command set | MEDIUM | MEDIUM | P2 |
| Optional VideoToolbox experiments | MEDIUM | MEDIUM | P2 |
| Packaging/distribution | MEDIUM | HIGH | P3 |
| macOS CI | MEDIUM | MEDIUM | P3 |
| Native Metal backend spike | LOW initially | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Existing Video2X repo | Upstream dependency docs | Our Approach |
|---------|-----------------------|--------------------------|--------------|
| Contributor entrypoint | Linux-heavy `.justfile`, mixed platform ergonomics | ncnn and MoltenVK document macOS bring-up separately | Unify around one contributor-facing `just` interface |
| macOS dependency guidance | No first-class macOS build doc yet | Vulkan SDK, MoltenVK, and ncnn each document their own pieces | Consolidate into repo-native `doctor/build/smoke` flow |
| GPU path decision | Implicit Vulkan assumptions in code | MoltenVK and ncnn provide the portability pieces | Make the initial GPU path explicit and documented |

## Sources

- Local repo: `.justfile`, `docs/book/src/building/linux.md`, `docs/book/src/building/windows.md`, `CMakeLists.txt`
- CMake presets manual: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html
- CMake `FindVulkan`: https://cmake.org/cmake/help/latest/module/FindVulkan.html
- MoltenVK README: https://github.com/KhronosGroup/MoltenVK
- Apple Metal overview: https://developer.apple.com/metal/
- ncnn build guide: https://github.com/Tencent/ncnn/wiki/how-to-build
- ncnn Vulkan notes: https://github.com/Tencent/ncnn/wiki/vulkan-notes
- FFmpeg docs: https://ffmpeg.org/ffmpeg.html

---
*Feature research for: macOS-first Video2X modernization*
*Researched: 2026-03-24*
