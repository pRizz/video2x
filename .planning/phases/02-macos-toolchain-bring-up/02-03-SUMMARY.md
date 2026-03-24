---
phase: 02-macos-toolchain-bring-up
plan: "03"
subsystem: infra
tags: [macos, just, doctor, docs, vendored, boost]
requires:
  - phase: 02-macos-toolchain-bring-up
    provides: validated preset-backed macOS system Release/Debug builds and known vendored Boost checkout boundary
provides:
  - Validated clean-checkout `just` evidence for macOS system Release and Debug flows
  - macOS doctor output aligned with the actual preset-backed configure/build gates
  - Repo entrypoint docs that describe the validated system path and bounded vendored fallback
affects: [phase-02, contributor-onboarding, macos-builds, docs]
tech-stack:
  added: []
  patterns: [doctor-first macOS workflow, thin just recipe descriptions, bounded vendored fallback guidance]
key-files:
  created:
    - .planning/phases/02-macos-toolchain-bring-up/02-03-SUMMARY.md
  modified:
    - .justfile
    - scripts/macos_doctor.sh
    - README.md
    - CONTRIBUTING.md
key-decisions:
  - "Treat `vulkaninfo` as an optional runtime probe instead of a hard configure/build prerequisite when MoltenVK or a Vulkan SDK already satisfies the preset-backed workflow."
  - "Keep `just` thin and explain the supported system path plus vendored checkout boundary through comments and docs rather than shell logic."
  - "Document vendored mode as the fallback when system packages are unavailable, while making the remaining `third_party/boost` checkout dependency explicit instead of overpromising a fully repaired vendored path."
patterns-established:
  - "macOS doctor checks should reflect the actual preset gates observed during clean-checkout validation."
  - "Contributor-facing docs should name the canonical `just` commands and the exact prerequisite split between baseline and system-only requirements."
requirements-completed: [BOOT-02, BLD-01, BLD-02]
duration: 4min
completed: 2026-03-24
---

# Phase 02: macOS Toolchain Bring-Up Summary

**Validated `just`-driven macOS system Release/Debug builds, corrected the doctor to match real preset gates, and documented the bounded vendored fallback in the repo entrypoints**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-24T11:20:29Z
- **Completed:** 2026-03-24T11:24:27Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- Validated fresh `just`-driven macOS system Release and Debug configure/build flows by moving the existing preset build trees aside and recreating them through the canonical recipes.
- Fixed the doctor and `just` command surface so it now matches the validated system path: `pkg-config` remains explicit, `vulkaninfo` is no longer treated as a false hard gate, and vendored checkout expectations are visible.
- Updated `README.md` and `CONTRIBUTING.md` so both entrypoints describe the same doctor-first macOS workflow, prerequisite set, and vendored fallback boundary.

## Task Commits

Each task was committed atomically:

1. **Task 1: Run the clean-checkout macOS contributor matrix through canonical commands** - `05178aa` (chore)
2. **Task 2: Fix remaining command-surface and diagnostic mismatches** - `d6ef12b` (fix)
3. **Task 3: Publish the validated prerequisite and fallback guidance in repo entrypoints** - `4841671` (docs)

## Files Created/Modified

- `.justfile` - Adds recipe descriptions that call out the supported system path and the vendored checkout requirement without adding wrapper logic.
- `scripts/macos_doctor.sh` - Aligns Vulkan and vendored fallback messaging with the actual preset-backed configure/build behavior.
- `README.md` - Publishes the doctor-first macOS setup and build path at the repo entrypoint.
- `CONTRIBUTING.md` - Expands contributor guidance with concrete prerequisites, canonical system commands, and the vendored checkout caveat.
- `.planning/phases/02-macos-toolchain-bring-up/02-03-SUMMARY.md` - Captures the validation evidence, task commits, and residual vendored limitation for the orchestrator.

## Decisions Made

- Treated missing `vulkaninfo` as a warning because fresh `just configure/build-macos-system-{release,debug}` succeeded with the Homebrew MoltenVK stack and `glslangValidator`.
- Kept the command layer thin: `just` still delegates directly to shared presets and the doctor script rather than embedding mode-specific build logic.
- Narrowed vendored guidance to the reality this worker could verify: fallback recipes remain available, but a complete `third_party/` checkout is still required for local vendored configure to succeed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected the doctor's Vulkan hard gate**
- **Found during:** Task 1 (Run the clean-checkout macOS contributor matrix through canonical commands)
- **Issue:** `just doctor-macos` failed on missing `vulkaninfo` even though fresh system Release and Debug configure/build flows succeeded through `just`.
- **Fix:** Downgraded missing `vulkaninfo` to a warning, added MoltenVK/Homebrew Vulkan loader checks, and surfaced the vendored checkout requirement in the command and doctor output.
- **Files modified:** `.justfile`, `scripts/macos_doctor.sh`
- **Verification:** `just doctor-macos`, `just --list --unsorted`, `just --show doctor-macos`
- **Committed in:** `d6ef12b`

---

**Total deviations:** 1 auto-fixed (1 Rule 1)
**Impact on plan:** The auto-fix removed a false prerequisite signal and kept the owned command/doctor surfaces aligned with the validated preset-backed workflow.

## Issues Encountered

- Fresh `just configure-macos-vendored-release` still fails in the local `third_party/boost` checkout with missing imported targets such as `Boost::intrusive`, `Boost::describe`, `Boost::bind`, `Boost::function_types`, `Boost::integer`, and `Boost::smart_ptr`. Repairing that third-party checkout state was out of scope for this worker, so the owned recipe/doctor/docs surfaces were updated to describe the vendored fallback boundary instead of pretending it was fixed here.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Contributors now have a validated doctor-first macOS system Release/Debug workflow that matches the actual `just` recipes and top-level docs.
- The repo entrypoints and doctor now agree on the concrete prerequisite set: Xcode, Homebrew, `pkg-config`, FFmpeg, Vulkan SDK or MoltenVK tooling, and the extra Homebrew packages needed for `macos-system-*`.
- Vendored fallback remains documented and available as the alternative command surface, but end-to-end vendored validation still depends on separate remediation of the local `third_party/boost` checkout state.
- Shared planning state files remained untouched by this worker.

---
*Phase: 02-macos-toolchain-bring-up*
*Completed: 2026-03-24*
