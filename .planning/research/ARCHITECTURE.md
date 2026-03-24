# Architecture Research

**Domain:** Brownfield build-system and platform-enablement architecture for a Vulkan-oriented C++ media pipeline
**Researched:** 2026-03-24
**Confidence:** MEDIUM

## Standard Architecture

### System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                 Contributor Interface Layer                  │
├─────────────────────────────────────────────────────────────┤
│  just doctor   just build   just smoke   docs/book builds  │
└───────────────┬──────────────┬──────────────┬───────────────┘
                │              │              │
┌───────────────┴──────────────┴──────────────┴───────────────┐
│                 Shared Build Configuration                   │
├─────────────────────────────────────────────────────────────┤
│     CMakePresets.json     preset-specific cache vars        │
│     toolchain/env helpers  dependency mode selection        │
└───────────────┬──────────────────────────────┬──────────────┘
                │                              │
┌───────────────┴──────────────┐  ┌────────────┴──────────────┐
│     Platform Adapter Layer   │  │    Validation Layer       │
├──────────────────────────────┤  ├───────────────────────────┤
│ macOS: Vulkan SDK + MoltenVK │  │ video2x --help            │
│ Linux/Windows: existing flow │  │ video2x --list-devices    │
│ brew/pkg/third_party choices │  │ sample clip smoke tests   │
└───────────────┬──────────────┘  └────────────┬──────────────┘
                │                              │
┌───────────────┴──────────────────────────────┴──────────────┐
│                 Existing Video2X Runtime                     │
├─────────────────────────────────────────────────────────────┤
│ libvideo2x + CLI + FFmpeg + ncnn + Vulkan/libplacebo paths  │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `just` interface | Human-friendly commands and task discovery | Thin recipes calling CMake presets and smoke scripts |
| CMake preset layer | Canonical configure/build/install settings | `CMakePresets.json` plus optional `CMakeUserPresets.json` |
| Platform adapter | Resolve per-OS dependency and SDK differences | macOS preset/env helpers, current Linux/Windows logic retained |
| Validation layer | Prove the built artifacts actually work | doctor checks, device listing, sample clip smoke tests |
| Runtime pipeline | Process media with selected backend | Existing `libvideo2x` and `video2x` targets |

## Recommended Project Structure

```text
.
├── justfile or .justfile         # Contributor entrypoint
├── CMakePresets.json             # Shared configure/build/install presets
├── cmake/
│   ├── presets/                  # Optional included preset fragments
│   └── toolchains/               # Optional platform helper files
├── scripts/
│   ├── doctor/                   # Environment validation helpers
│   ├── smoke/                    # Repo-native smoke tests
│   └── bootstrap/                # Optional dependency bootstrap wrappers
├── docs/book/src/building/
│   ├── linux.md
│   ├── windows.md
│   └── macos.md                  # New first-class macOS guide
└── existing src/, include/, tools/, models/, packaging/
```

### Structure Rationale

- **Contributor commands stay shallow:** the more logic hidden in `just`, the harder it becomes to reason about reproducibility and CI reuse.
- **Presets own configuration:** shared cache variables, generators, binary dirs, and platform dependency modes belong in CMake, not shell recipes.
- **Validation scripts stay explicit:** smoke tests and doctor checks are platform-facing contract tests for the build surface.

## Architectural Patterns

### Pattern 1: Thin Orchestrator

**What:** `just` delegates quickly to CMake presets or small scripts.
**When to use:** Always for contributor-facing commands.
**Trade-offs:** More files, but much clearer separation between command UX and build logic.

**Example:**
```text
just build-macos
  -> cmake --preset macos-release
  -> cmake --build --preset macos-release
```

### Pattern 2: Preset-Driven Platform Matrix

**What:** Each supported build flavor gets a named preset instead of a custom shell incantation.
**When to use:** For release/debug, shared/static, macOS/Linux/Windows, and dependency-mode variations.
**Trade-offs:** Requires raising the practical CMake baseline for contributors.

### Pattern 3: Bring-Up Before Optimization

**What:** Establish a working Vulkan/MoltenVK path first, then optimize or re-architect only where evidence demands.
**When to use:** For brownfield macOS platform additions where the existing runtime is already Vulkan-centric.
**Trade-offs:** First milestone may not achieve absolute best Apple-native performance, but it minimizes wasted rewrite effort.

## Data Flow

### Request Flow

```text
Contributor
    ↓
just command
    ↓
CMake preset / helper script
    ↓
dependency + SDK resolution
    ↓
build/install
    ↓
repo-native smoke test
    ↓
runtime GPU/device validation
```

### State Management

```text
Repo-tracked state:
- CMakePresets.json
- justfile
- docs/building/macos.md
- smoke/doctor scripts

Local developer state:
- CMakeUserPresets.json
- Homebrew packages
- VULKAN_SDK environment
- local build directories
```

### Key Data Flows

1. **Bootstrap flow:** contributor command verifies Xcode, Homebrew tools, Vulkan SDK, and environment before any build begins.
2. **Build flow:** preset resolves dependency mode and generator, then produces the CLI and library artifacts.
3. **Validation flow:** smoke scripts run the produced binary, list devices, and execute a short sample workload to confirm the portability path.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Solo fork | A single macOS preset and minimal `just` wrappers are enough |
| Small contributor set | Add doctor commands, richer docs, and stable preset naming |
| Upstream-ready platform support | Add CI, broader compatibility matrix, and stricter dependency-mode policies |

### Scaling Priorities

1. **First bottleneck:** implicit environment assumptions on macOS — solve with doctor/bootstrap and checked-in presets.
2. **Second bottleneck:** backend uncertainty — solve with explicit MoltenVK validation and focused performance measurement.

## Anti-Patterns

### Anti-Pattern 1: Shell-Driven Build Graph

**What people do:** Put every compiler flag, package install, and environment branch directly into `just`.
**Why it's wrong:** The contributor interface becomes the only source of truth, which makes IDE, CI, and debugging workflows drift apart.
**Do this instead:** Keep `just` shallow and move reusable configuration into CMake presets and small scripts.

### Anti-Pattern 2: Native Metal First

**What people do:** Assume that supporting macOS well means immediately abandoning Vulkan.
**Why it's wrong:** This repo's processors, dependency graph, and runtime assumptions are already Vulkan-oriented.
**Do this instead:** Make MoltenVK the first integration step and use a later benchmark-driven spike to justify any Metal-native work.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| LunarG Vulkan SDK | Installed SDK + `VULKAN_SDK`-aware CMake discovery | Needed for MoltenVK, validation layers, and Vulkan tools on macOS |
| Homebrew | Contributor bootstrap dependency source | Best fit for macOS DX in the first milestone |
| ncnn | System package or upstream artifacts with Vulkan enabled | Must be validated on Apple GPUs, not just linked |
| FFmpeg | Existing libav* integration with optional hw device config | Keep current pipeline and validate macOS-specific acceleration separately |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `just` ↔ CMake presets | command invocation | Keep names stable and human-readable |
| platform helper ↔ runtime smoke tests | shell/process boundary | This is where macOS platform proof should live |
| existing runtime ↔ macOS portability layer | Vulkan loader + MoltenVK | Requires portability-aware instance/device handling |

## Sources

- Local repo: `CMakeLists.txt`, `.justfile`, `.planning/codebase/ARCHITECTURE.md`
- CMake presets manual: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html
- CMake `FindVulkan`: https://cmake.org/cmake/help/latest/module/FindVulkan.html
- MoltenVK README: https://github.com/KhronosGroup/MoltenVK
- Vulkan portability enumeration spec: https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_portability_enumeration.html
- Apple Metal overview: https://developer.apple.com/metal/
- Apple metal-cpp: https://developer.apple.com/metal/cpp/
- ncnn build guide: https://github.com/Tencent/ncnn/wiki/how-to-build
- ncnn Vulkan notes: https://github.com/Tencent/ncnn/wiki/vulkan-notes
- FFmpeg docs: https://ffmpeg.org/ffmpeg.html

---
*Architecture research for: macOS-first Video2X modernization*
*Researched: 2026-03-24*
