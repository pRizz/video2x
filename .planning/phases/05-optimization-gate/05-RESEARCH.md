# Phase 5: Optimization Gate - Research

**Goal:** Decide, from evidence, what performance and backend work should happen after the first milestone.

## Current Observable State

- Phase 4 is complete and the repo now has a first-class macOS build guide plus a MoltenVK-first GPU strategy page.
- `README.md` and `CONTRIBUTING.md` already point contributors at the canonical macOS build and runtime commands.
- `Phase 5` is still unplanned in the roadmap, and `GPU-03` remains the only v1 requirement left open.
- The current macOS workflow exposes build, smoke, device-list, and sample validation commands through `just`, but it does not expose any benchmark-specific `just` recipes yet.
- The repo already documents that `data/standard-test.mp4` is used for performance benchmarks in `README.md`, but the macOS validation flow now prefers locally generated sample media for runtime proof instead of relying on that clip.
- The CLI already has a latent benchmark mode:
  - `tools/video2x/src/argparse.cpp` defines `--benchmark` / `-b`
  - `tools/video2x/src/video2x.cpp` prints a benchmark summary including average FPS
  - `src/libvideo2x.cpp` skips frame encoding and writing when benchmark mode is enabled
- The existing macOS runtime helper script, `scripts/macos_runtime_validation.sh`, shows the repo already prefers thin repo-owned wrappers over ad hoc shell instructions when it wants a stable contributor workflow.

## What This Means

- Phase 5 does not need to invent a new low-level timing mechanism. The application already exposes a benchmark mode and already computes useful summary data.
- The real gap is workflow and evidence packaging: contributors need a documented way to run the benchmark mode consistently on Apple Silicon, compare processor paths, and capture results that are meaningful enough to justify further backend work.
- Because benchmark mode skips output writing, it is useful for isolating processing cost, but it does not fully represent end-to-end user experience. Phase 5 should therefore distinguish:
  - pure processing throughput
  - full transcode cost
  - backend-specific overhead such as decode, encode, and portability-layer effects
- The backend decision gate should remain evidence-driven. The current docs already say native Metal or VideoToolbox are follow-up options only if the MoltenVK path proves insufficient.

## Planning Implications

1. Establish a baseline for the current Apple Silicon path before proposing any optimization.
2. Formalize benchmark commands around the existing `--benchmark` flag instead of adding a parallel timing system.
3. Define a small, repeatable benchmark matrix for the supported processor paths and macOS GPU path.
4. Convert measured results into a concrete recommendation for the next milestone: optimize the current stack, add CI, package releases, or explore a deeper backend path.

## Likely Phase Shape

- **Plan 05-01:** capture measured or observed limitations in the initial Apple Silicon bring-up.
- **Plan 05-02:** formalize benchmark commands and evidence collection around the existing benchmark mode for supported processor paths.
- **Plan 05-03:** record the next-milestone recommendation and support boundaries in the planning docs.

## Risks and Pitfalls

- Benchmark results can be noisy on Apple Silicon because thermal state, background load, and power mode can change FPS materially.
- The current duplicate MoltenVK install warning can add noise to runtime logs even when the actual benchmark path is healthy.
- Comparing runs across different clips or different codec settings will produce misleading conclusions unless the benchmark inputs are fixed.
- `--benchmark` discards output writes, which is useful for isolating processing cost but can hide encode or mux bottlenecks that matter to real users.
- A benchmark that only measures one processor path will not be enough to justify backend changes; Phase 5 needs comparative evidence across the supported paths that matter to this fork.

## Recommendation

Phase 5 should formalize benchmark commands and reporting around the existing `--benchmark` support, not invent a new timing subsystem. The right outcome is a small, reproducible benchmark surface that tells us whether the current MoltenVK-first macOS path is good enough, whether any processor path is the bottleneck, and whether the next investment should be tuning, CI, packaging, or a deeper backend experiment.

## Sources

- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `.planning/phases/04-documentation-and-strategy-publication/04-VERIFICATION.md`
- `.planning/phases/03-runtime-smoke-and-gpu-proof/03-VERIFICATION.md`
- `README.md`
- `.justfile`
- `tools/video2x/src/argparse.cpp`
- `tools/video2x/src/video2x.cpp`
- `src/libvideo2x.cpp`
- `scripts/macos_runtime_validation.sh`
