---
phase: 02-macos-toolchain-bring-up
plan: "01"
subsystem: infra
tags: [macos, just, cmake, homebrew, vulkan, pkg-config]
requires:
  - phase: 01-build-surface-foundation
    provides: preset-backed macOS configure/build recipes and contributor-facing just workflow
provides:
  - Aggregated macOS doctor script for Apple Silicon prerequisite checks
  - Thin `just doctor-macos` entrypoint beside the preset-backed macOS recipes
affects: [phase-02, contributor-onboarding, macos-builds]
tech-stack:
  added: [bash]
  patterns: [aggregated prerequisite reporting, thin just delegation]
key-files:
  created:
    - scripts/macos_doctor.sh
    - .planning/phases/02-macos-toolchain-bring-up/02-01-SUMMARY.md
  modified:
    - .justfile
key-decisions:
  - "Split doctor output into baseline macOS prerequisites versus extra macos-system-only dependencies so vendored mode remains explicit."
  - "Keep `just` limited to a single script delegation instead of duplicating dependency checks in the recipe surface."
  - "Leave the current preset configure failure on missing third_party source directories untouched because it is outside the owned files for plan 02-01."
patterns-established:
  - "macOS doctor scripts should aggregate all prerequisite failures in one pass."
  - "Contributor-facing `just` entries should delegate to repo-owned scripts when the logic is more than a trivial command."
requirements-completed: [BOOT-02]
duration: 7min
completed: 2026-03-24
---

# Phase 02: macOS Toolchain Bring-Up Summary

**Aggregated Apple Silicon macOS prerequisite reporting with explicit PkgConfig gate diagnostics and a thin canonical `just doctor-macos` entrypoint**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-24T10:48:00Z
- **Completed:** 2026-03-24T10:54:55Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added `scripts/macos_doctor.sh` to check Apple toolchain, Homebrew/PATH, baseline build tools, Vulkan portability tooling, and extra macOS system-mode dependencies in one pass.
- Made the doctor output call out the `PkgConfig` / `PKG_CONFIG_EXECUTABLE` gate directly when it is missing, including the exact CMake failure wording contributors would otherwise hit later.
- Added a single thin `doctor-macos` recipe to `.justfile` so the canonical macOS preflight command lives next to the preset-backed configure/build recipes.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement an aggregated Apple Silicon macOS doctor script** - `02d039c` (feat)
2. **Task 2: Expose the doctor through a thin canonical `just` entrypoint** - `fa8c752` (feat)

## Files Created/Modified

- `scripts/macos_doctor.sh` - Aggregated macOS prerequisite checker with baseline versus system-mode sections and actionable failure text.
- `.justfile` - Adds `doctor-macos` as a thin delegation to the repo-owned doctor script.
- `.planning/phases/02-macos-toolchain-bring-up/02-01-SUMMARY.md` - Records plan outcomes, verification, and task commits.

## Decisions Made

- Kept the prerequisite split explicit: baseline checks describe what vendored presets still need, while system-only checks describe what `macos-system-*` adds on top.
- Treated `PkgConfig` as a first-class gate in the doctor output instead of relying on downstream CMake errors to reveal it.
- Did not expand scope into fixing the current preset configure failure because it now points at missing `third_party/*_ncnn_vulkan` directories outside the files owned by this worker.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- On 2026-03-24, the host no longer reproduced the earlier `Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)` configure failure. `pkg-config` is now present at `/opt/homebrew/bin/pkg-config`, so `cmake --preset macos-system-release` fails later on missing `third_party/librealesrgan_ncnn_vulkan/src`, `third_party/librealcugan_ncnn_vulkan/src`, and `third_party/librife_ncnn_vulkan/src` directories instead.
- `bash scripts/macos_doctor.sh` and `just doctor-macos` currently report one remaining baseline prerequisite issue on this machine: `vulkaninfo` is missing from `PATH`. The script still reports the `PkgConfig` gate explicitly when that prerequisite is absent, verified with a constrained `PATH` run.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Contributors now have one canonical macOS doctor command and can distinguish baseline vendored-mode readiness from the extra requirements for `macos-system-*`.
- Shared planning state files remained untouched by this worker.
- The current workspace still has an out-of-scope configure blocker in missing third-party source directories, and the local machine still lacks `vulkaninfo`, so later Phase 02 verification work should account for both before claiming end-to-end macOS configure readiness.

---
*Phase: 02-macos-toolchain-bring-up*
*Completed: 2026-03-24*
