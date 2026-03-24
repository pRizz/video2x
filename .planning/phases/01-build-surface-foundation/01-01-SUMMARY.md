---
phase: 01-build-surface-foundation
plan: "01"
subsystem: infra
tags: [just, cmake, presets, macos]
requires:
  - phase: 01-build-surface-foundation/01-02
    provides: Shared macOS preset names and stable build/install directories
provides:
  - Thin macOS contributor-facing just recipes backed by shared CMake presets
  - Grouped just command discovery that keeps packaging secondary to the macOS workflow
affects: [phase-01-plan-03, phase-02-macos-toolchain]
tech-stack:
  added: []
  patterns:
    - just forwards contributor-facing macOS commands directly to shared CMake presets
key-files:
  created: []
  modified: [.justfile]
key-decisions:
  - "Expose all supported macOS system and vendored Release/Debug entrypoints directly in `.justfile` rather than hiding dependency mode in shell logic."
  - "Move distro packaging recipes into a secondary `packaging` group so `just --list` reads as the macOS contributor workflow first."
patterns-established:
  - "Canonical macOS just recipes map one-to-one onto configure and build preset names."
  - "Packaging helpers remain available without sharing the primary contributor build group."
requirements-completed: [BOOT-01]
duration: 1 min
completed: 2026-03-24
---

# Phase 1 Plan 01: macOS-first `just` preset front door Summary

**`.justfile` now exposes a macOS-first preset-backed configure/build surface while pushing distro packaging helpers into a clearly secondary group.**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-24T09:00:00Z
- **Completed:** 2026-03-24T09:01:22Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- Replaced the raw Unix `cmake -D...` contributor recipes with explicit macOS system and vendored preset entrypoints.
- Added matching preset-backed build verbs for Release and Debug so the supported macOS matrix is discoverable from `.justfile` alone.
- Split distro packaging helpers into a secondary `packaging` group so `just --list` leads with the intended macOS workflow.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace raw macOS configure/build bundles with preset-backed recipes** - `2f25236` (feat)
2. **Task 2: Reorganize `.justfile` around canonical workflow discovery** - `e21481f` (feat)

## Files Created/Modified
- `.justfile` - Defines the thin macOS contributor recipes and separates packaging helpers from the primary workflow surface.

## Decisions Made
- Exposed each supported macOS preset as an explicit configure/build recipe pair instead of keeping generic Unix build commands that re-encode cache flags.
- Kept packaging helpers available but moved them into their own group so contributors see the macOS workflow before distro-specific recipes.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for `01-03` to align repo guidance and command discovery text with the new preset-backed macOS workflow.
- No blockers introduced by this plan; the next remaining build-surface work is documentation and guidance alignment.

---
*Phase: 01-build-surface-foundation*
*Completed: 2026-03-24*
