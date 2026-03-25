---
phase: 05-optimization-gate
plan: "01"
subsystem: macos-benchmarking
tags: [macos, benchmark, applesilicon, just, moltenvk, evidence]
requires:
  - phase: 03-runtime-smoke-and-gpu-proof
    provides: validated built-binary macOS runtime path and canonical sample media generation pattern
  - phase: 04-documentation-and-strategy-publication
    provides: explicit MoltenVK-first strategy and published Apple Silicon support boundary
provides:
  - Thin `just` benchmark commands for macOS filtering and interpolation paths
  - Repo-owned benchmark wrapper around the existing `video2x --benchmark` mode
  - Baseline Apple Silicon benchmark evidence with quality gating and caveats
affects: [phase-05, benchmark-surface, repo-entrypoints, planning-evidence]
tech-stack:
  added: []
  patterns: [thin-just-wrapper, benchmark-quality-gate, evidence-first-baseline]
key-files:
  created:
    - scripts/macos_benchmark.sh
    - .planning/phases/05-optimization-gate/05-01-BASELINE.md
    - .planning/phases/05-optimization-gate/05-01-SUMMARY.md
  modified:
    - .justfile
key-decisions:
  - "Wrap the existing CLI benchmark mode instead of introducing a second timing or profiling mechanism."
  - "Generate a longer local benchmark clip by default so zero-second summaries are rejected as invalid evidence."
  - "Require both filtering and interpolation evidence on the current host unless an explicit interpolation blocker is captured."
patterns-established:
  - "macOS contributor helpers should hide known CLI quirks such as the dummy `--output` requirement instead of making contributors rediscover them."
  - "Benchmark numbers are only decision-grade when the elapsed-time summary is non-zero and the caveats are recorded next to the result."
requirements-advanced: [GPU-03]
duration: 18min
completed: 2026-03-25
---

# Phase 05-01 Summary

**Built the macOS benchmark workflow around the existing benchmark mode and captured the first Apple Silicon baseline**

## Performance

- **Duration:** 18 min
- **Completed:** 2026-03-25T02:19:00-05:00
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added `scripts/macos_benchmark.sh` as the repo-owned macOS benchmark wrapper around `video2x --benchmark`.
- Added thin `just` entrypoints for both filtering and interpolation benchmark paths:
  - `benchmark-macos-realesrgan`
  - `benchmark-macos-rife`
- Enforced a benchmark-quality gate so `Total time taken: 00:00:00` is rejected as invalid evidence rather than silently accepted.
- Hid the current CLI quirk that still requires a dummy `--output` path in benchmark mode.
- Captured a first Apple Silicon baseline in `.planning/phases/05-optimization-gate/05-01-BASELINE.md` with both filtering and interpolation results plus the current interpretation caveats.

## Task Commits

1. **Task 1: Expose a thin macOS benchmark workflow around the existing benchmark mode** - `dc555a4` `chore(05-01): expose macos benchmark workflow`
2. **Task 2: Record baseline Apple Silicon limitations and benchmark caveats** - `618572f` `chore(05-01): record apple silicon benchmark baseline`

## Verification

- `test -f scripts/macos_benchmark.sh` passed.
- `just --list --unsorted | rg "benchmark-macos"` passed.
- `just --show benchmark-macos-realesrgan` passed and showed thin delegation to the script.
- `just --show benchmark-macos-rife` passed and showed thin delegation to the script.
- `./scripts/macos_benchmark.sh benchmark-realesrgan` exited `0` and reported:
  - `Total frames processed: 238`
  - `Total time taken: 00:00:02`
  - `Average processing speed: 119.00 FPS`
- `./scripts/macos_benchmark.sh benchmark-rife` exited `0` and reported:
  - `Total frames processed: 475`
  - `Total time taken: 00:00:04`
  - `Average processing speed: 118.75 FPS`
- The accepted benchmark runs both cleared the non-zero elapsed-time quality gate.
- `rg -n "Average processing speed|dummy output|MoltenVK|Apple Silicon|bottleneck|limitation|rife|interpolation|blocker|invalid|too short|Total time taken" .planning/phases/05-optimization-gate/05-01-BASELINE.md` passed.
- `git diff -- .justfile scripts/macos_benchmark.sh .planning/phases/05-optimization-gate/05-01-BASELINE.md` was clean after the task commits.

## Issues Encountered

- The first wrapper revision logged benchmark-generation messages to stdout, which polluted the command-substitution path used to resolve the generated input file and caused the benchmark command to fail with `Could not open input file ...`. I corrected that by moving helper logs to stderr before capturing the baseline results.
- Both benchmark runs emitted the known duplicate MoltenVK `MVKBlockObserver` warning, but neither run failed.

## Baseline Notes

- The current benchmark workflow uses generated local clips because `data/` is absent on this host.
- Benchmark mode still initializes encoder state and logs `libx264` setup even though frame writes are skipped, so these numbers should be treated as compute-oriented throughput evidence rather than full end-to-end transcode measurements.
- No interpolation blocker appeared on this host; Phase 5 now has real evidence for both processor classes.

## Next Phase Readiness

- Phase 05-02 can now evaluate VideoToolbox, native Metal, CI, packaging, and current MoltenVK-path tuning against recorded Apple Silicon evidence instead of assumptions.
- Phase 05-03 can make an explicit next-milestone recommendation from documented tradeoffs rather than from an unresolved backend debate.
