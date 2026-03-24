---
phase: 01-build-surface-foundation
plan: "03"
subsystem: docs
tags: [docs, macos, apple-silicon, just, presets]
requires:
  - phase: 01-build-surface-foundation/01-01
    provides: Thin macOS contributor-facing just recipes backed by shared CMake presets
  - phase: 01-build-surface-foundation/01-02
    provides: Shared macOS Apple Silicon configure/build preset names and stable output directories
provides:
  - Repo entrypoint docs that advertise the canonical Apple Silicon macOS workflow for this fork
  - Contributor guidance aligned with the preset-backed `just` command names from Phase 1
  - Docs book build index wording that acknowledges the current macOS boundary without inventing a full guide
affects: [phase-02-macos-toolchain, phase-04-documentation-and-strategy]
tech-stack:
  added: []
  patterns:
    - Entry-point docs mirror the shared `just` and preset naming instead of re-documenting raw CMake flags
key-files:
  created: []
  modified: [README.md, CONTRIBUTING.md, docs/book/src/building/README.md, docs/book/src/SUMMARY.md]
key-decisions:
  - "Present the latest macOS on Apple Silicon as the supported source-build boundary for this fork directly in repo entrypoint docs."
  - "Keep the docs book macOS build coverage intentionally shallow until a later phase can supply a first-class guide."
patterns-established:
  - "README.md, CONTRIBUTING.md, and docs/book/src/building/README.md should repeat the same canonical `just` command names for macOS."
  - "Book index pages can acknowledge fork-specific support boundaries without adding placeholder chapters."
requirements-completed: [BOOT-01]
duration: 2 min
completed: 2026-03-24
---

# Phase 1 Plan 03: Repo and book workflow alignment Summary

**Repo entrypoint docs and the book build index now point contributors to the supported Apple Silicon macOS `just` plus preset workflow without pretending a full macOS guide already exists.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-24T09:05:02Z
- **Completed:** 2026-03-24T09:06:46Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Added a dedicated macOS Apple Silicon source-build entrypoint to `README.md` with the canonical Release and vendored fallback command names.
- Added matching contributor guidance in `CONTRIBUTING.md` that makes `just` the front door and shared CMake presets the underlying source of truth.
- Expanded the docs book build index to acknowledge the current macOS workflow boundary and fixed the existing malformed desktop link in the book summary.

## Task Commits

Each task was committed atomically:

1. **Task 1: Update repo entrypoints to advertise the canonical macOS workflow** - `96c0a5a` (docs)
2. **Task 2: Align the docs book build index without creating a fake full macOS guide** - `6e77241` (docs)

## Files Created/Modified
- `README.md` - Adds the contributor-facing macOS Apple Silicon source-build entrypoint and canonical `just` commands.
- `CONTRIBUTING.md` - Documents the supported preset-backed macOS build workflow for contributors.
- `docs/book/src/building/README.md` - Keeps the book build landing page shallow while acknowledging the current macOS command entrypoints.
- `docs/book/src/SUMMARY.md` - Fixes the existing malformed `running/desktop.md` summary link.

## Decisions Made
- Put the macOS Apple Silicon source-build boundary directly in repo entrypoint docs so contributors do not have to infer the supported path from Linux packaging or raw CMake examples.
- Kept the book page intentionally shallow and routed detailed guidance to the repo entrypoints until a later phase can publish a real macOS build guide.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed the malformed desktop summary link**
- **Found during:** Task 2 (Align the docs book build index without creating a fake full macOS guide)
- **Issue:** `docs/book/src/SUMMARY.md` had a stray trailing `]` on the Desktop entry, leaving the summary syntax malformed during link verification.
- **Fix:** Removed the extra bracket while leaving the rest of the book structure unchanged.
- **Files modified:** `docs/book/src/SUMMARY.md`
- **Verification:** Confirmed the summary still references only existing pages and that `running/desktop.md` exists.
- **Committed in:** `6e77241` (part of Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix stayed within owned docs files and was necessary to keep the book summary clean while verifying Task 2.

## Issues Encountered

- `mdbook` is not installed in this environment, so docs verification used `rg` plus file-existence checks instead of a rendered book build.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 1 is complete and the canonical macOS workflow is now discoverable from repo and book entrypoints.
- Phase 2 can focus on prerequisite validation and build bring-up rather than workflow naming or doc-surface ambiguity.
- No `02-01` plan file exists yet, so the next execution step is planning the first Phase 2 task.

---
*Phase: 01-build-surface-foundation*
*Completed: 2026-03-24*
