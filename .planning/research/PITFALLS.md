# Pitfalls Research

**Domain:** macOS platform enablement for a Vulkan-centric brownfield C++ media pipeline
**Researched:** 2026-03-24
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Assuming MoltenVK devices enumerate automatically

**What goes wrong:**
The app builds on macOS but fails to see any usable Vulkan device, leading developers to think the GPU path is broken.

**Why it happens:**
Portability devices are not enumerated by default; MoltenVK and the Vulkan portability spec both require portability-aware instance creation behavior.

**How to avoid:**
Make macOS bring-up explicitly validate portability-aware enumeration and document the required instance behavior in code, smoke tests, and docs.

**Warning signs:**
`vulkaninfo` works but the app sees zero devices, or device listing differs between local tools and `video2x --list-devices`.

**Phase to address:**
Phase 2: macOS GPU bring-up

---

### Pitfall 2: Treating VideoToolbox as the main answer to macOS GPU support

**What goes wrong:**
The project invests in FFmpeg hardware decode/encode plumbing but still fails to deliver a strong end-to-end macOS processing story.

**Why it happens:**
FFmpeg documents that most hwaccel modes are mainly useful for testing and often require copying frames back to system memory when filters are involved.

**How to avoid:**
Keep VideoToolbox optional and secondary. First prove the actual processing path on Vulkan/MoltenVK, then benchmark whether decode/encode acceleration is worth adding.

**Warning signs:**
Lots of work lands in FFmpeg hwaccel options while core processor bring-up, device validation, or model execution is still unresolved.

**Phase to address:**
Phase 3: validation and performance proof

---

### Pitfall 3: Letting `just` absorb the real build logic

**What goes wrong:**
Contributor commands work only in one shell or on one maintainer machine, and build configuration drifts across platforms.

**Why it happens:**
It is easy to keep patching shell recipes instead of consolidating configuration in CMake.

**How to avoid:**
Use `just` for ergonomics only. Put shared configuration in presets and platform helper scripts, then keep recipes small enough to read in one screen.

**Warning signs:**
Recipe files grow large, duplicate CMake flags proliferate, or docs and CI cannot reuse the same build definitions.

**Phase to address:**
Phase 1: build surface redesign

---

### Pitfall 4: Rewriting for native Metal too early

**What goes wrong:**
The project burns a milestone on backend churn without first proving whether the portability route is good enough.

**Why it happens:**
Metal is the native Apple API, and Apple documents strong C++ entry points through `metal-cpp`, which makes it tempting to jump straight there.

**How to avoid:**
Gate any Metal-native work behind explicit findings: missing Vulkan features, unacceptable performance, or integration barriers that MoltenVK cannot solve.

**Warning signs:**
Roadmap work starts discussing custom Metal shaders, new backend abstractions, or rewriting ncnn/libplacebo integration before the first macOS smoke path exists.

**Phase to address:**
Phase 4 or later: optimization / backend strategy

---

### Pitfall 5: Declaring success after "it builds"

**What goes wrong:**
The repo claims macOS support, but models fail to load, GPU listing fails, or sample processing crashes immediately.

**Why it happens:**
Brownfield platform work often stops at compilation rather than runtime validation.

**How to avoid:**
Define completion in terms of doctor, build, device listing, and at least one real smoke workload on Apple Silicon.

**Warning signs:**
No `smoke-macos` equivalent exists, and success is reported using only `cmake --build`.

**Phase to address:**
Phase 3: smoke tests and success criteria

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding macOS SDK paths in recipes | Fast local unblocking | Breaks for every other contributor and future SDK upgrade | Only for temporary debugging, never as the committed workflow |
| Keeping outdated platform docs while changing recipes | Saves writing time | Guarantees contributor confusion | Never |
| Mixing system, vendored, and prebuilt dependency modes implicitly | Lets one machine build quickly | Makes support impossible across contributors | Only if the mode is explicit in presets and docs |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Vulkan SDK / MoltenVK | Linking Vulkan without handling portability-specific enumeration behavior | Validate SDK install, loader visibility, and portability-aware device enumeration together |
| ncnn on macOS | Assuming "supports Apple GPU" means every model path is production-ready | Add smoke tests around the actual models Video2X ships |
| FFmpeg hw devices | Enabling hwaccel flags without measuring filter-pipeline copies | Benchmark after the main Vulkan processing path works |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Copy-heavy decode/filter/encode path | GPU path exists but throughput is disappointing | Measure end-to-end, not just device availability | As soon as real filtering or interpolation workloads run |
| Static assumptions about Apple GPU behavior | Some models or tile settings work, others regress badly | Add benchmark and smoke commands per processor path | During first serious macOS validation |
| Validation-free optimization | Time spent shaving flags before correctness is established | Prove build + smoke + GPU listing first | Immediately |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Pulling platform dependencies from unofficial mirrors | Supply-chain and reproducibility risk | Use official Homebrew, LunarG, Apple, and upstream project release sources |
| Encoding secrets or machine-specific paths in presets or recipes | Leaks environment details and breaks sharing | Keep shared presets repo-safe and use local overrides where needed |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Different command names and expectations per platform | Contributors cannot transfer knowledge between Linux, Windows, and macOS | Use consistent `doctor/build/smoke` naming across platforms |
| Hidden prerequisites | New contributors fail before the first meaningful command | Add an explicit doctor/bootstrap step with actionable output |
| macOS docs weaker than Linux docs | The platform feels unofficial | Give macOS a full build guide, not a footnote |

## "Looks Done But Isn't" Checklist

- [ ] **macOS build support:** Often missing runtime GPU validation — verify `video2x --list-devices` on Apple Silicon
- [ ] **MoltenVK integration:** Often missing portability-aware instance behavior — verify physical device enumeration actually works
- [ ] **`just` ergonomics:** Often missing shared presets — verify raw CMake and `just` use the same build definitions
- [ ] **Smoke testing:** Often missing a real sample workload — verify at least one processor path runs on a short clip

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Portability enumeration missing | LOW | Patch instance creation and add a dedicated smoke assertion |
| `just` logic sprawl | MEDIUM | Move repeated flags into presets and split scripts by responsibility |
| Native Metal overreach | HIGH | Pause rewrite work, restore portability-first roadmap, benchmark before re-committing |
| False-success macOS support | MEDIUM | Add runtime smoke tests and tighten success criteria retroactively |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| MoltenVK enumeration failure | Phase 2 | Device listing works on Apple Silicon |
| `just` logic sprawl | Phase 1 | Recipes are thin and preset-backed |
| VideoToolbox misprioritization | Phase 3 | Main Vulkan smoke path exists before hwaccel optimization work |
| Native Metal overreach | Phase 4+ | No native backend work starts without benchmark-backed justification |
| False-success support claims | Phase 3 | macOS smoke commands run a real workload |

## Sources

- MoltenVK README: https://github.com/KhronosGroup/MoltenVK
- Vulkan portability enumeration spec: https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_portability_enumeration.html
- Apple Metal overview: https://developer.apple.com/metal/
- Apple metal-cpp: https://developer.apple.com/metal/cpp/
- ncnn Vulkan notes: https://github.com/Tencent/ncnn/wiki/vulkan-notes
- ncnn build guide: https://github.com/Tencent/ncnn/wiki/how-to-build
- FFmpeg docs: https://ffmpeg.org/ffmpeg.html
- Local repo: `.justfile`, `CMakeLists.txt`, `.planning/codebase/CONCERNS.md`

---
*Pitfalls research for: macOS-first Video2X modernization*
*Researched: 2026-03-24*
