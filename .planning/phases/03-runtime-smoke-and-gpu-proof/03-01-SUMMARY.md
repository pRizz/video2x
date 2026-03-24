---
phase: 03-runtime-smoke-and-gpu-proof
plan: "01"
subsystem: runtime
tags: [macos, fsutils, rpath, runtime-smoke, models]
requires:
  - phase: 02-macos-toolchain-bring-up
    provides: validated macOS system-release build and install trees
provides:
  - macOS executable-directory discovery that no longer falls back to `/proc/self/exe`
  - Executable-relative model lookup for both the built tree and the install prefix
  - Installed macOS CLI and shared library rpaths that resolve `libvideo2x` and sibling dylibs
affects: [phase-03, macos-runtime, model-discovery, install-layout]
tech-stack:
  added: []
  patterns: [executable-relative resource lookup, post-install Mach-O rpath repair]
key-files:
  created:
    - .planning/phases/03-runtime-smoke-and-gpu-proof/03-01-SUMMARY.md
  modified:
    - src/fsutils.cpp
    - CMakeLists.txt
key-decisions:
  - "Keep the built `build/macos-system-release/video2x` binary as the canonical Phase 3 proof target and fix model discovery through executable-relative lookup instead of caller working-directory assumptions."
  - "Teach macOS resource lookup about both `build/<preset>/video2x` and `<prefix>/bin/video2x` layouts in `fsutils` rather than relying on Linux-only `/usr/share` probes."
  - "Harden the installed artifact with a small repo-owned post-install rpath repair because CMake's generated `install_name_tool` edit aborts before `-add_rpath` when the copied Mach-O no longer carries the build-tree rpaths it tries to delete."
patterns-established:
  - "macOS runtime data lookup should start from the executable location, not `/proc/self/exe` or repo-root-relative current-working-directory assumptions."
  - "When install-time Mach-O edits are partially blocked by generated `-delete_rpath` steps, a narrow post-install repair in `CMakeLists.txt` is acceptable if it leaves the final installed artifact verifiably correct."
requirements-completed: [VAL-01]
duration: 8min
completed: 2026-03-24
---

# Phase 03: Runtime Smoke and GPU Proof Summary

**Repaired the macOS runtime path contract so the built binary finds models out of tree, and hardened the installed CLI enough to launch from the install prefix**

## Performance

- **Duration:** 8 min
- **Completed:** 2026-03-24T23:42:08Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Replaced the macOS `/proc/self/exe` fallback with `_NSGetExecutablePath` and added executable-relative resource candidates that cover the built tree and installed prefix layouts.
- Verified the canonical out-of-tree smoke path from `/tmp/video2x-phase3`, where the built `video2x` binary now resolves `models/realesrgan/...` without logging `Error reading /proc/self/exe: No such file or directory`.
- Hardened the installed macOS artifact with loader-relative rpaths so `build/install/macos-system-release/bin/video2x --help` now exits `0` and the installed `libvideo2x.dylib` can find sibling dylibs.

## Task Commits

1. **Task 1: Replace Linux-only executable-path lookup with a real macOS implementation** - `074c4bc` `fix(03-01): add macos executable-relative resource lookup`
2. **Task 2: Optionally harden the installed macOS artifact** - `bb89f1e` `fix(03-01): harden macos installed cli rpaths`

## Verification

- `cmake --build --preset macos-system-release` exited `0` after both task changes.
- `./build/macos-system-release/video2x --help` exited `0`.
- `ffmpeg -y -f lavfi -i testsrc=size=320x180:rate=12 -t 1 /tmp/video2x-phase3/input.mp4` exited `0`.
- `cd /tmp/video2x-phase3 && /Users/peterryszkiewicz/Repos/video2x/build/macos-system-release/video2x -i input.mp4 -o realesrgan-fsutils.mp4 -p realesrgan -s 2 --realesrgan-model realesr-animevideov3 --no-progress` exited `0` and produced `/tmp/video2x-phase3/realesrgan-fsutils.mp4`.
- The out-of-tree runtime probe no longer logged `Error reading /proc/self/exe: No such file or directory`, and it resolved the Real-ESRGAN model from executable-relative lookup instead of the repo-root current working directory.
- `./build/install/macos-system-release/bin/video2x --help` exited `0`.
- `otool -l ./build/install/macos-system-release/bin/video2x | rg -n "LC_RPATH|@loader_path|@executable_path"` showed `LC_RPATH` with `@executable_path/../lib`.
- `otool -l ./build/install/macos-system-release/lib/libvideo2x.dylib` showed `LC_RPATH` with `@loader_path`.
- `git diff -- src/fsutils.cpp CMakeLists.txt` was reviewed between task commits, and only the owned runtime-path changes were staged.

## Auto-fixed Issues

**1. CMake install-time rpath edits aborted before `-add_rpath` on copied macOS artifacts**

- **Found during:** Task 2 verification
- **Issue:** The generated install script tried to `-delete_rpath` entries that were already absent on the copied install-tree Mach-O files, which prevented the built-in `-add_rpath` step from repairing the installed CLI.
- **Fix:** Kept target-level `INSTALL_RPATH` settings and added a narrow post-install repair step in `CMakeLists.txt` that checks the installed Mach-O metadata with `otool` and adds the missing loader-relative rpath only when it is absent.
- **Verification:** `./build/install/macos-system-release/bin/video2x --help`; `otool -l ./build/install/macos-system-release/bin/video2x`; `otool -l ./build/install/macos-system-release/lib/libvideo2x.dylib`
- **Committed in:** `bb89f1e`

## Issues Encountered

- `cmake --build --preset macos-system-release` still prints benign `install_name_tool` `no LC_RPATH load command` messages from generated install steps, including third-party subdirectory installs that are outside this task's owned-file boundary. The repo-owned CLI and `libvideo2x` artifacts are repaired afterward and validate successfully, so this remained noise rather than a phase blocker.

## User Setup Required

None.

## Next Phase Readiness

- The built macOS runtime smoke target is now independent of launching from the repo root for model discovery.
- The installed macOS CLI launches successfully from the install prefix with loader-relative rpaths in place.
- Optional broader packaging cleanup, including third-party install-script noise outside the owned files, remains separate from this plan slice.
- Shared planning state files outside this summary remained untouched by this worker.
