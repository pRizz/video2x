# Phase 05-01 Apple Silicon Baseline

## Benchmark Workflow Used

- Canonical benchmark entrypoint: `scripts/macos_benchmark.sh`
- Canonical binary target: `build/macos-system-release/video2x`
- Processor coverage captured:
  - Filtering: `benchmark-realesrgan`
  - Interpolation: `benchmark-rife`
- Input source: repo-owned generated benchmark clips because `data/` is absent locally
- Generated clip profile: `testsrc`, `320x180`, `24 fps`, `10 seconds`, `yuv420p`
- Benchmark mode: existing `video2x --benchmark` path with `--no-progress`

## Evidence Quality Gate

- The helper script treats `Total time taken: 00:00:00` as invalid evidence and fails the run.
- Both accepted baseline runs below cleared that gate:
  - Real-ESRGAN reported `Total time taken: 00:00:02`
  - RIFE reported `Total time taken: 00:00:04`
- No interpolation blocker was encountered on this host. The interpolation path produced a real benchmark result.

## Filtering Baseline: Real-ESRGAN

- Command surface: `./scripts/macos_benchmark.sh benchmark-realesrgan`
- Processor class: filtering
- Input file: `build/macos-benchmark/benchmark-realesrgan/generated-input.mp4`
- Summary:
  - `Total frames processed: 238`
  - `Total time taken: 00:00:02`
  - `Average processing speed: 119.00 FPS`
- Observations:
  - The benchmark completed successfully on the built Apple Silicon binary.
  - The run still initialized the encoder stack and printed `libx264` setup logs even though benchmark mode discarded frame writes.
  - The benchmark helper had to supply a dummy `--output` path because the CLI still rejects `--benchmark` without `--output` during argument parsing.

## Interpolation Baseline: RIFE

- Command surface: `./scripts/macos_benchmark.sh benchmark-rife`
- Processor class: interpolation
- Input file: `build/macos-benchmark/benchmark-rife/generated-input.mp4`
- Summary:
  - `Total frames processed: 475`
  - `Total time taken: 00:00:04`
  - `Average processing speed: 118.75 FPS`
- Observations:
  - The interpolation path completed successfully on the built Apple Silicon binary.
  - This provides real interpolation-path evidence for Phase 5 instead of a placeholder or inferred blocker.
  - As with the filtering path, benchmark mode still brought up encoder initialization before skipping frame writes.

## Host Caveats

- Duplicate MoltenVK warning was present in both runs:
  - `objc[...] Class MVKBlockObserver is implemented in both /opt/homebrew/Cellar/molten-vk/1.4.1/lib/libMoltenVK.dylib and /Users/peterryszkiewicz/VulkanSDK/1.4.341.1/macOS/lib/libMoltenVK.dylib`
- The warning did not block either benchmark run, but it adds noise to logs and should be treated as an environment caveat when comparing outputs.
- Benchmark mode measures processing throughput with frame writes skipped. It is useful for isolating compute-heavy work, but it is not a full end-to-end transcode measurement.
- The helper generates longer local clips because short synthetic clips can produce misleading `00:00:00` benchmark summaries on fast hosts.

## Current Limitations and Bottlenecks

- Workflow limitation: the CLI help surface implies benchmark mode is self-sufficient, but in practice the current path still needs a dummy `--output` argument. The helper script now hides that quirk for contributors, but the underlying CLI behavior remains a rough edge.
- Measurement limitation: benchmark summaries are only decision-grade when elapsed time is non-zero. Any too-short run must be rejected or rerun with longer input.
- Interpretation limitation: because benchmark mode bypasses frame writes but still initializes encoder state, these results are best treated as compute-oriented throughput evidence rather than a complete user-experience proxy.
- No clear catastrophic portability bottleneck appeared in these low-resolution synthetic runs. The current MoltenVK-first path looks usable on this Apple Silicon host, but that alone is not enough to justify a backend rewrite or a VideoToolbox-first shift.

## Phase 5 Use

This baseline provides the evidence floor for the next two Phase 5 plans:

- use these measured results and caveats to evaluate whether backend work, CI, or packaging deserves priority next
- treat the absence of a clear benchmark-path failure as evidence against making native Metal the default next step without stronger justification
