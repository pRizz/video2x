# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-24)

**Core value:** Make macOS a first-class, convenient, GPU-capable target for Video2X instead of an afterthought.
**Current focus:** Phase 3 - Runtime Smoke and GPU Proof

## Current Position

Phase: 3 of 5 (Runtime Smoke and GPU Proof)
Plan: Not started
Status: Phase 2 verified complete; Phase 3 planning is next
Last activity: 2026-03-24 - Verified Phase 2 after executing all three plans and confirming the doctor-first macOS build flow against the real repo state

Progress: [████░░░░░░] 40%

## Performance Metrics

**Velocity:**
- Total plans completed: 6
- Average duration: 5 min
- Total execution time: 0.5 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | 3 min | 1 min |
| 2 | 3 | 30 min | 10 min |

**Recent Trend:**
- Last 5 plans: 01-02 (1 min), 01-03 (2 min), 02-01 (7 min), 02-02 (19 min), 02-03 (4 min)
- Trend: Rising complexity
- Latest execution: 02-03 (4 min, 3 tasks, 5 files)

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Initialization: Use `just` as the contributor-facing workflow over shared CMake presets.
- Initialization: Target modern Apple Silicon on the latest macOS only.
- Initialization: Start macOS GPU enablement with a Vulkan portability path before any native Metal rewrite.
- Phase 1 plan 01-02: Represent the supported macOS Apple Silicon matrix with four explicit shared CMake presets spanning system and vendored dependency modes.
- Phase 1 plan 01-02: Keep `CMakeLists.txt` authoritative and unchanged unless preset-driven configure exposes a real CMake-side incompatibility.
- Phase 1 plan 01-01: Expose each supported macOS system and vendored Release/Debug preset as explicit `just` configure/build recipe pairs.
- Phase 1 plan 01-01: Move distro packaging helpers into a secondary `packaging` group so `just --list` stays macOS-first.
- Phase 1 plan 01-03: Publish the Apple Silicon macOS support boundary and canonical `just` command names directly in repo entrypoint docs.
- Phase 1 plan 01-03: Keep the docs book build landing page shallow until a later phase can add a first-class macOS guide.
- Phase 2 plan 02-01: Use `just doctor-macos` as the canonical aggregated prerequisite check before macOS configure or build commands.
- Phase 2 plan 02-02: Keep CMake authoritative for Apple Silicon build fixes, including Homebrew/OpenMP/FFmpeg/macOS linker compatibility, instead of moving logic into wrappers.
- Phase 2 plan 02-03: Treat the system Release and Debug path as the validated Phase 2 build contract and document vendored mode as a checkout-dependent fallback boundary.
- Phase 2 plan 02-03: Treat missing `vulkaninfo` as a warning rather than a hard Phase 2 configure/build gate when MoltenVK or equivalent tooling already satisfies the validated system path.

### Pending Todos

None yet.

### Blockers/Concerns

- Exact repo changes needed for portability-aware Vulkan device handling on macOS are still unverified.
- Real-world MoltenVK behavior for the shipped Video2X processor paths on Apple Silicon still needs runtime proof.
- Real-world MoltenVK behavior for actual Video2X runtime and GPU enumeration still needs proof in Phase 3.
- The validated install step still prints non-blocking `install_name_tool` rpath-deletion errors during macOS builds and should be monitored in later runtime validation.
- Vendored macOS configure still depends on fuller local `third_party/boost` checkout materialization; this did not block the Phase 2 system-path requirements but remains a local fallback caveat.
- Phase 3 has not been planned yet, so the next workflow step is to create the Phase 3 plan set.

## Session Continuity

Last session: 2026-03-24 11:39
Stopped at: Verified Phase 2 and prepared handoff to Phase 3 planning
Resume file: .planning/phases/02-macos-toolchain-bring-up/02-VERIFICATION.md
