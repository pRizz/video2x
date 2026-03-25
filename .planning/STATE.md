# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-24)

**Core value:** Make macOS a first-class, convenient, GPU-capable target for Video2X instead of an afterthought.
**Current focus:** Phase 5 - Optimization Gate

## Current Position

Phase: 5 of 5 (Optimization Gate)
Plan: Not started
Status: Phase 4 verified complete; Phase 5 planning is next
Last activity: 2026-03-24 - Verified Phase 4 after executing all three plans and publishing the first-class macOS docs-book surface plus the MoltenVK-first GPU strategy

Progress: [████████░░] 80%

## Performance Metrics

**Velocity:**
- Total plans completed: 12
- Average duration: 7 min
- Total execution time: 1.4 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 3 | 3 min | 1 min |
| 2 | 3 | 30 min | 10 min |
| 3 | 3 | 27 min | 9 min |
| 4 | 3 | 23 min | 8 min |

**Recent Trend:**
- Last 5 plans: 03-02 (8 min), 03-03 (10 min), 04-01 (6 min), 04-02 (7 min), 04-03 (10 min)
- Trend: Stable
- Latest execution: 04-03 (10 min, 3 tasks, 6 files)

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
- Phase 4 plan 04-01: Put the validated Apple Silicon build workflow into `docs/book` directly instead of leaving macOS guidance scattered across root docs.
- Phase 4 plan 04-02: Publish Vulkan SDK plus MoltenVK as the explicit first-class macOS GPU strategy and document the portability contract plus future evidence gate.
- Phase 4 plan 04-03: Make the docs book the discoverable home for the macOS guide and GPU strategy, then align README and CONTRIBUTING back to that published surface.

### Pending Todos

None yet.

### Blockers/Concerns

- `mdbook` is not installed on the validation host, so Phase 4 used structural documentation checks instead of a local HTML book build.
- The validation host currently loads MoltenVK from both `/opt/homebrew` and `/usr/local`, which emits duplicate `MVKBlockObserver` warnings even though runtime validation passed.
- The validated install step still prints non-blocking `install_name_tool` rpath-deletion errors on third-party dylibs during macOS builds; the new GPU-strategy docs record this caveat, but the underlying host behavior remains.
- Vendored macOS configure still depends on fuller local `third_party/boost` checkout materialization; this did not block the Phase 2 system-path requirements but remains a local fallback caveat.
- Phase 5 has not been planned yet, so the next workflow step is to create the Phase 5 plan set.

## Session Continuity

Last session: 2026-03-25 00:18
Stopped at: Verified Phase 4 and prepared handoff to Phase 5 planning
Resume file: .planning/phases/04-documentation-and-strategy-publication/04-VERIFICATION.md
