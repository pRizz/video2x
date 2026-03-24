---
phase: 03-runtime-smoke-and-gpu-proof
plan: "03"
subsystem: runtime-validation
tags: [macos, validation, just, docs, realesrgan]
requires:
  - phase: 03-runtime-smoke-and-gpu-proof
    provides: built macOS CLI plus portability-aware GPU enumeration
provides:
  - Repo-owned macOS smoke, device-list, and Real-ESRGAN sample validation commands
  - Thin `just` recipes for the canonical Phase 3 runtime proof surface
  - Contributor docs that describe the built-binary-first macOS validation contract
affects: [phase-03, macos-runtime, validation-surface, docs]
tech-stack:
  added: []
  patterns: [thin just delegation, built-binary-first validation, self-generated sample media]
key-files:
  created:
    - .planning/phases/03-runtime-smoke-and-gpu-proof/03-03-SUMMARY.md
  modified:
    - .justfile
    - scripts/macos_runtime_validation.sh
    - README.md
    - CONTRIBUTING.md
key-decisions:
  - "Keep the built `build/macos-system-release/video2x` binary as the canonical Phase 3 validation target and support installed-artifact checks only as a secondary script mode."
  - "Use `realesrgan` as the default macOS sample workload, generate a tiny local clip with `ffmpeg` when no input is provided, and verify the resulting output with `ffprobe`."
  - "Document the macOS Vulkan portability contract explicitly and avoid reusing Linux-oriented `LD_LIBRARY_PATH` recipes as if they were valid runtime proof on macOS."
patterns-established:
  - "Canonical macOS runtime validation commands should stay thin in `.justfile` and delegate to a repo-owned script."
  - "Phase 3 proof should cover smoke launch, detected GPU output, and a non-empty verified sample output without assuming checked-in sample media."
requirements-completed: [VAL-03]
completed: 2026-03-24
---

# Phase 03-03 Summary

**Published the canonical macOS runtime validation surface so contributors can prove smoke launch, device enumeration, and one short Real-ESRGAN workload directly from the repo root**

## Accomplishments

- Added `scripts/macos_runtime_validation.sh` with explicit `smoke`, `list-devices`, and `sample-realesrgan` subcommands, built-binary-first defaults, and a secondary installed-artifact mode.
- Added thin `just` recipes for `smoke-macos`, `list-devices-macos`, and `sample-macos-realesrgan` without inlining runtime logic or reusing Linux-only `LD_LIBRARY_PATH` recipes.
- Updated `README.md` and `CONTRIBUTING.md` so the macOS validation story matches the implementation exactly: built binary first, MoltenVK portability preconditions explicit, locally generated sample media supported, and `libplacebo` labeled non-canonical until revalidated.

## Task Commits

1. `35cfe27` - `test(03-03): add macos runtime validation script`
2. `952f639` - `test(03-03): add macos validation recipes`
3. `f3be7b0` - `docs(03-03): document macos runtime validation`

## Verification

- `just configure-macos-system-release` exited `0`.
- `just build-macos-system-release` exited `0`.
- `just --list --unsorted` showed `smoke-macos`, `list-devices-macos`, and `sample-macos-realesrgan`.
- `just --show smoke-macos`, `just --show list-devices-macos`, and `just --show sample-macos-realesrgan` each showed a one-line delegation into `scripts/macos_runtime_validation.sh`.
- `just smoke-macos` exited `0` against the built `build/macos-system-release/video2x` binary.
- `just list-devices-macos` exited `0` and printed detected GPU entries.
- `just sample-macos-realesrgan` exited `0`, generated `build/macos-runtime-validation/realesrgan/generated-input.mp4` locally with `ffmpeg`, and produced `build/macos-runtime-validation/realesrgan/realesrgan-output.mp4`.
- `ffprobe` verification inside `scripts/macos_runtime_validation.sh` confirmed the sample output contains a video stream and is non-empty.
- `./scripts/macos_runtime_validation.sh smoke --binary-mode installed` exited `0`, confirming the installed artifact remains a secondary supported validation target.
- `rg -n "smoke-macos|list-devices-macos|sample-macos-(realesrgan|realcugan)|MoltenVK|portability|detected GPU|ffmpeg|ffprobe|built binary" README.md CONTRIBUTING.md .justfile scripts/macos_runtime_validation.sh` showed a coherent built-binary-first validation story across implementation and docs.
- `git diff -- .justfile scripts/macos_runtime_validation.sh README.md CONTRIBUTING.md` was reviewed before the task and metadata commits.

## Runtime Caveats

- The host still warns that `MVKBlockObserver` is implemented by both Homebrew and `/usr/local` MoltenVK libraries. The duplicate-class warning appeared during `--list-devices` and the sample workload, but both commands still exited `0`.
- `just build-macos-system-release` still prints pre-existing `install_name_tool` `no LC_RPATH load command` messages while installing third-party dylibs outside this plan's file ownership. The repo-owned built and installed `video2x` smoke checks still passed.

## User Setup Required

None beyond the documented macOS prerequisite surface already required for the validated `macos-system-release` path.
