---
phase: 01-build-surface-foundation
plan: "02"
subsystem: infra
tags: [cmake, presets, macos, apple-silicon]
requires: []
provides:
  - Shared macOS arm64 configure presets for system and vendored dependency modes
  - Matching CMake build presets with stable build and install directories under build/
  - Verified preset-driven configure behavior against the existing top-level CMake options
affects: [phase-01-plan-03, phase-02-macos-toolchain]
tech-stack:
  added: [CMake Presets]
  patterns:
    - Presets carry shared macOS build configuration instead of shell-assembled cache flags
key-files:
  created: [CMakePresets.json]
  modified: []
key-decisions:
  - "Use four explicit macOS arm64 presets for Release/Debug across system and vendored dependency modes."
  - "Leave CMakeLists.txt unchanged because the new presets already map cleanly onto the existing authoritative cache options."
patterns-established:
  - "Hidden base preset plus dependency-mode bases feed explicit contributor-facing macOS presets."
  - "Build presets target install and keep build/install output rooted under build/."
requirements-completed: [BLD-03]
duration: 1 min
completed: 2026-03-24
---

# Phase 1 Plan 02: Shared macOS preset matrix Summary

**Shared macOS Apple Silicon CMake presets now define the supported system and vendored build matrix without requiring contributors to reconstruct raw cache flags.**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-24T08:54:17Z
- **Completed:** 2026-03-24T08:55:33Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- Added a checked-in macOS arm64 preset matrix covering Release/Debug and system/vendored dependency modes.
- Added matching build presets that install into stable per-preset directories under `build/`.
- Verified that preset-driven configure uses the intended CMake cache variables and currently stops only on external dependency availability (`pkg-config`) on this machine.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the supported macOS preset matrix** - `fb585b2` (feat)
2. **Task 2: Keep CMake authoritative for preset-selected behavior** - `53cc666` (chore)

## Files Created/Modified
- `CMakePresets.json` - Defines the shared macOS Apple Silicon configure/build preset matrix and stable build/install output layout.

## Decisions Made
- Used a four-preset macOS arm64 matrix built from one hidden platform base plus hidden dependency-mode bases.
- Kept `CMakeLists.txt` unchanged because preset validation showed no CMake-side incompatibility beyond missing external tooling on the local machine.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `cmake --preset macos-system-release` stopped at missing `PkgConfig` / `PKG_CONFIG_EXECUTABLE` on this machine.
- `cmake --preset macos-vendored-debug` stopped at the same missing external dependency gate, but the preset itself supplied the required Video2X cache flags without manual overrides.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for `01-03` to wire contributor-facing discovery onto the new preset names.
- Local macOS prerequisite setup still needs to make `pkg-config` and the system multimedia/toolchain packages explicit in the next phase.

---
*Phase: 01-build-surface-foundation*
*Completed: 2026-03-24*
