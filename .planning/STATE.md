# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-24)

**Core value:** Make macOS a first-class, convenient, GPU-capable target for Video2X instead of an afterthought.
**Current focus:** Phase 4 - Documentation and Strategy Publication

## Current Position

Phase: 4 of 5 (Documentation and Strategy Publication)
Plan: Not started
Status: Phase 3 verified complete; Phase 4 planning is next
Last activity: 2026-03-24 - Verified Phase 3 after executing all three plans and proving the macOS smoke, device-list, and sample-workload flow against the real repo state

Progress: [██████░░░░] 60%

## Performance Metrics

**Velocity:**
- Total plans completed: 9
- Average duration: 6 min
- Total execution time: 1.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | 3 min | 1 min |
| 2 | 3 | 30 min | 10 min |
| 3 | 3 | 27 min | 9 min |

**Recent Trend:**
- Last 5 plans: 02-02 (19 min), 02-03 (4 min), 03-01 (8 min), 03-02 (8 min), 03-03 (10 min)
- Trend: Stable at higher complexity
- Latest execution: 03-03 (10 min, 4 tasks, 5 files)

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
- Phase 3 plan 03-01: Make built-binary macOS runtime proof independent of the caller's working directory through executable-relative resource lookup, with installed-artifact hardening as secondary.
- Phase 3 plan 03-02: Make Vulkan portability enumeration explicit on macOS and emit actionable MoltenVK-oriented failure guidance instead of generic instance-creation errors.
- Phase 3 plan 03-03: Publish `just`-level macOS smoke, device-list, and Real-ESRGAN sample validation commands backed by a repo-owned script and locally generated sample media.

### Pending Todos

None yet.

### Blockers/Concerns

- The validation host currently loads MoltenVK from both `/opt/homebrew` and `/usr/local`, which emits duplicate `MVKBlockObserver` warnings even though runtime validation passed.
- The validated install step still prints non-blocking `install_name_tool` rpath-deletion errors on third-party dylibs during macOS builds and should be monitored in later documentation or cleanup work.
- Vendored macOS configure still depends on fuller local `third_party/boost` checkout materialization; this did not block the Phase 2 system-path requirements but remains a local fallback caveat.
- Phase 4 has not been planned yet, so the next workflow step is to create the Phase 4 plan set.

## Session Continuity

Last session: 2026-03-24 18:03
Stopped at: Verified Phase 3 and prepared handoff to Phase 4 planning
Resume file: .planning/phases/03-runtime-smoke-and-gpu-proof/03-VERIFICATION.md
