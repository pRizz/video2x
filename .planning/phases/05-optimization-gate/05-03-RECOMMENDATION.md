# Phase 05-03 Next Milestone Recommendation

## Recommended Next Milestone

The next milestone should **optimize and characterize the current MoltenVK-first Apple Silicon path**, not pivot immediately into VideoToolbox-first work, native Metal, packaging, or CI-first automation.

## Why This Is Recommended Now

The current Phase 5 evidence supports an optimization-first direction:

- the current Apple Silicon benchmark baseline completed successfully for both a filtering path and an interpolation path
- no catastrophic MoltenVK or portability-layer failure appeared on this host
- the benchmark workflow is now reproducible through repo-owned commands instead of ad hoc shell history
- the current evidence is still compute-oriented and synthetic, so it is strong enough to reject backend overreach now but not strong enough to declare the current path fully characterized

This makes a narrow optimization milestone the best next step. It can answer the remaining evidence gap without forcing the project into premature backend churn or workflow expansion.

## Evidence Used

- [05-01-BASELINE.md](/Users/peterryszkiewicz/Repos/video2x/.planning/phases/05-optimization-gate/05-01-BASELINE.md)
  - Real-ESRGAN benchmark: `238` frames in `00:00:02`, `119.00 FPS`
  - RIFE benchmark: `475` frames in `00:00:04`, `118.75 FPS`
  - benchmark mode still requires a dummy `--output`
  - benchmark mode remains compute-oriented rather than full end-to-end transcode proof
- [05-02-EVALUATION.md](/Users/peterryszkiewicz/Repos/video2x/.planning/phases/05-optimization-gate/05-02-EVALUATION.md)
  - current MoltenVK-first path is the recommended leading candidate
  - macOS CI is recommended soon, but after one optimization-focused pass
  - VideoToolbox-first, native Metal-first, and packaging-first are not recommended as the first next step

## Deferred Options

### Deferred: macOS CI Automation

CI is deferred, not rejected.

- It has strong workflow value.
- It becomes more valuable once the benchmark and validation surfaces settle around the optimization work.
- It should be the next candidate after the optimization-focused milestone if no larger technical blocker appears.

### Deferred: Packaging and Distribution

Packaging remains deferred.

- It improves delivery, not diagnosis.
- The current milestone still needs stronger performance characterization before packaging becomes the highest-leverage next step.

### Deferred: VideoToolbox Experiments

VideoToolbox is deferred.

- It is only justified if end-to-end user impact is shown to be dominated by encode or decode overhead rather than compute throughput.
- The current evidence does not yet establish that bottleneck class.

### Deferred: Native Metal Exploration

Native Metal is deferred.

- The current MoltenVK-first path is usable on this Apple Silicon host.
- The current evidence does not show missing capability, unacceptable performance, or maintenance friction severe enough to justify a backend spike now.

## Revisit Conditions

This next milestone recommendation should be revisited if any of the following happens:

- larger or more representative workloads show that the current MoltenVK-first path has a clear compute-path collapse
- end-to-end transcode measurements show encode or decode overhead dominates user impact, making VideoToolbox materially more attractive
- reproducible portability-layer failures appear in device enumeration or real workloads despite the current validated path
- optimization work shows the current path cannot be improved meaningfully without backend changes
- workflow evidence shows CI automation has become the tighter bottleneck than technical characterization

## Support Boundaries That Remain In Force

Until later evidence changes the direction, the project keeps these support boundaries:

- latest macOS on Apple Silicon only
- Vulkan SDK plus MoltenVK remains the canonical GPU path
- `just` and shared CMake presets remain the contributor-facing workflow
- packaging and distribution remain deferred
- macOS CI remains deferred until after one optimization-focused pass

## Decision Summary

**Next milestone:** optimize and characterize the current MoltenVK-first Apple Silicon path.  
**Recommended later:** macOS CI automation.  
**Deferred:** packaging, VideoToolbox-first work, and native Metal-first work until their evidence gates are met.
