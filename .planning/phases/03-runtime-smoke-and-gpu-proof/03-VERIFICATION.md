---
phase: 03-runtime-smoke-and-gpu-proof
status: passed
score: 94/100
verified_on: 2026-03-24
---

# Phase 03 Verification

## Verdict

Passed. The current checkout satisfies the Phase 3 runtime proof on this host: the macOS build launches, GPU/device enumeration is explicit about Vulkan portability requirements, and a short Real-ESRGAN sample workload completes and produces verified output.

## Evidence

- Canonical runtime entrypoints are present in [/.justfile](/Users/peterryszkiewicz/Repos/video2x/.justfile) and delegate to [scripts/macos_runtime_validation.sh](/Users/peterryszkiewicz/Repos/video2x/scripts/macos_runtime_validation.sh).
- The built binary exists at [build/macos-system-release/video2x](/Users/peterryszkiewicz/Repos/video2x/build/macos-system-release/video2x), and the installed secondary binary exists at [build/install/macos-system-release/bin/video2x](/Users/peterryszkiewicz/Repos/video2x/build/install/macos-system-release/bin/video2x).
- `just build-macos-system-release` exited `0`. It completed the install step for the repo-owned artifacts and printed non-fatal `install_name_tool` `no LC_RPATH load command` noise for third-party dylibs in the install tree.
- `just smoke-macos` exited `0` and reported `Smoke check passed` for the built canonical binary.
- `just list-devices-macos` exited `0`, logged the portability preconditions, and printed detected GPU entries, including `Apple M4 Max`.
- `just sample-macos-realesrgan` exited `0`, generated a local test clip with `ffmpeg`, ran the Real-ESRGAN workload, and verified the output with `ffprobe`.
- `./scripts/macos_runtime_validation.sh smoke --binary-mode installed` exited `0`, confirming the install-tree smoke path still works as a secondary check.
- `otool -l` on the installed CLI and library showed the expected macOS loader-relative rpaths: `@executable_path/../lib` for the CLI and `@loader_path` for `libvideo2x.dylib`.

## Requirement Coverage

### VAL-01

Covered. The built macOS `video2x` binary launches successfully through the canonical smoke command. Evidence: `just smoke-macos` and `./scripts/macos_runtime_validation.sh smoke --binary-mode installed`.

### VAL-02

Covered. GPU enumeration is validated from the built binary on macOS, and the validation flow makes portability requirements explicit. Evidence: `just list-devices-macos` printed the precondition banner mentioning MoltenVK-equivalent tooling and `VK_KHR_portability_enumeration`, then returned detected GPU names.

### VAL-03

Covered. The sample workload completes on macOS and produces output. Evidence: `just sample-macos-realesrgan` generated a short local input clip, produced `build/macos-runtime-validation/realesrgan/realesrgan-output.mp4`, and `ffprobe` confirmed the output contains a video stream.

### GPU-02

Covered. The Vulkan helper on macOS explicitly enables portability enumeration and emits actionable failures instead of relying on implicit loader behavior. Evidence: [tools/video2x/src/vulkan_utils.cpp](/Users/peterryszkiewicz/Repos/video2x/tools/video2x/src/vulkan_utils.cpp) checks for `VK_KHR_portability_enumeration`, enables the portability bit on macOS, and reports missing-portability / no-device / `vkCreateInstance` failures with specific guidance.

## Source Alignment

- [src/fsutils.cpp](/Users/peterryszkiewicz/Repos/video2x/src/fsutils.cpp) resolves resources relative to the executable on macOS, covering both the built tree and installed prefix layouts.
- [CMakeLists.txt](/Users/peterryszkiewicz/Repos/video2x/CMakeLists.txt) sets macOS rpaths for the CLI and shared library and includes a guarded install-time rpath repair step for the installed artifacts.
- [README.md](/Users/peterryszkiewicz/Repos/video2x/README.md) and [CONTRIBUTING.md](/Users/peterryszkiewicz/Repos/video2x/CONTRIBUTING.md) describe the same built-binary-first validation flow that the script and just recipes implement.

## Residual Caveats

- The host emits an `objc[...]: Class MVKBlockObserver is implemented in both ...` warning because two MoltenVK copies are installed (`/opt/homebrew` and `/usr/local`). This warning appeared during device enumeration and sample execution, but both commands still exited `0` and produced valid results.
- The `just build-macos-system-release` install step still prints non-fatal `install_name_tool` noise on third-party dylibs. The repo-owned CLI and library artifacts are repaired and validated afterward, so this is noisy but not blocking for Phase 3.
- The nested checkout dirty state in `third_party/boost` is out of scope for this verification and did not block the runtime proof.

## Final Assessment

This phase is verified as complete on the current checkout. The runtime contract is usable on macOS Apple Silicon, the portability requirement is explicit, and the sample workload proof is reproducible from the repository root.
