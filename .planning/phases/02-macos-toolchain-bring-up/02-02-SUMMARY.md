---
phase: 02-macos-toolchain-bring-up
plan: "02"
subsystem: infra
tags: [cmake, presets, macos, homebrew, ffmpeg, ncnn, vulkan]
requires:
  - phase: 01-build-surface-foundation
    provides: explicit macOS Apple Silicon preset matrix and thin preset-backed wrappers
provides:
  - AppleClang/Homebrew configure compatibility for macOS system presets
  - macOS-safe Release linker flags in authoritative top-level CMake
  - FFmpeg pkg-config link directory wiring for preset-backed system builds
affects: [02-macos-toolchain-bring-up, docs, doctor, macos-build]
tech-stack:
  added: []
  patterns: [top-level CMake owns Homebrew-specific discovery hints for preset-backed macOS builds]
key-files:
  created:
    - .planning/phases/02-macos-toolchain-bring-up/02-02-SUMMARY.md
  modified:
    - CMakeLists.txt
key-decisions:
  - "Keep CMake authoritative and fix Homebrew toolchain discovery in top-level CMake rather than wrapper scripts."
  - "Use Homebrew glslang for vendored ncnn configure on macOS instead of adding nested shell logic."
  - "Use Apple linker-compatible Release dead-strip flags instead of GNU-only --gc-sections on macOS."
patterns-established:
  - "macOS preset fixes belong in CMakeLists.txt, not in just recipes."
  - "pkg-config-discovered FFmpeg libraries on macOS need both include and library directory wiring."
requirements-completed: [BLD-01, BLD-02]
duration: 19min
completed: 2026-03-24
---

# Phase 2: macOS Toolchain Bring-Up Summary

**macOS Apple Silicon system presets now configure and build cleanly through top-level CMake, with Homebrew ncnn/OpenMP, FFmpeg, and Apple Release linker handling fixed in the authoritative layer**

## Performance

- **Duration:** 19 min
- **Started:** 2026-03-24T10:59:00Z
- **Completed:** 2026-03-24T11:18:05Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Fixed AppleClang/Homebrew configure-time discovery for external `ncnn` + `libomp` and vendored `ncnn` + Homebrew `glslang`.
- Fixed macOS FFmpeg linking and Release linker flags in top-level CMake so both system Release and Debug preset builds complete through `install`.
- Verified `cmake --list-presets`, fresh system Release/Debug configure, and fresh system Release/Debug builds from preset-backed trees.

## Task Commits

Each task was committed atomically:

1. **Task 1: Validate and fix configure-time preset wiring from clean build trees** - `fdcca12` (fix)
2. **Task 2: Make the system Release and Debug build presets complete end to end** - `6194fe2` (fix)

## Files Created/Modified
- `CMakeLists.txt` - Added macOS/Homebrew discovery hints for `libomp` and `glslang`, fixed FFmpeg link-directory wiring, and made Release linker flags Apple-compatible.
- `.planning/phases/02-macos-toolchain-bring-up/02-02-SUMMARY.md` - Captures execution outcome, commits, and residual risk for the orchestrator.

## Decisions Made

- No `CMakePresets.json` change was required; the preset matrix itself was sound once top-level CMake matched macOS/Homebrew reality.
- The Release linker fix stayed in the top-level compiler/linker policy block so all preset-backed Apple Release builds inherit it consistently.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Installed missing macOS prerequisites**
- **Found during:** Task 1 (configure validation)
- **Issue:** Fresh preset configure stopped immediately on missing `PkgConfig`, and the machine also lacked the Homebrew packages needed to validate the macOS system path.
- **Fix:** Installed `pkgconf`, `spdlog`, `ncnn`, `molten-vk`, `glslang`, and `vulkan-loader` with Homebrew.
- **Files modified:** None
- **Verification:** Fresh preset configure advanced past `PkgConfig` and resolved Homebrew-provided dependencies.
- **Committed in:** `fdcca12`

**2. [Rule 3 - Blocking] Initialized required local submodule content for validation**
- **Found during:** Task 1 (vendored/configure validation)
- **Issue:** The local checkout lacked populated `third_party` content needed to exercise the repo’s real system/vendored CMake paths.
- **Fix:** Initialized the top-level processor/vendor submodules locally and selectively populated Boost support submodules while investigating vendored configure.
- **Files modified:** None
- **Verification:** System preset configure/build exercised the real third-party tree instead of failing on missing checkout content.
- **Committed in:** `fdcca12`

---

**Total deviations:** 2 auto-fixed (2 Rule 3)
**Impact on plan:** Both deviations were prerequisite/blocker handling needed to validate the actual preset-backed macOS flow.

## Issues Encountered

- Vendored Release/Debug configure no longer fails on preset wiring, `PkgConfig`, or vendored `ncnn` glslang discovery, but it still stops in the local Boost superproject because the checkout needs additional Boost submodules beyond the ones selectively materialized during validation. This remained outside the owned-file scope for this plan worker.

## User Setup Required

None - no repo-owned setup document was generated.

## Next Phase Readiness

- Phase 02 now has validated system Release and Debug preset-backed builds on Apple Silicon macOS through authoritative CMake.
- The docs/doctor follow-up can point at concrete Homebrew prerequisites and the real preset names.
- Residual concern: vendored macOS configure still depends on deeper local Boost vendoring content on this machine, so the next worker should either finish that local vendored checkout story or explicitly narrow the intended vendored dependency boundary.

---
*Phase: 02-macos-toolchain-bring-up*
*Completed: 2026-03-24*
