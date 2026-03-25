# Phase 05-02 Evaluation

## Decision Goal

Choose the first post-v1 milestone from evidence, not preference. The current decision set is:

- tune the current MoltenVK-first path
- run targeted VideoToolbox experiments
- start a native Metal spike
- automate macOS CI
- pursue packaging and distribution

This evaluation is grounded in the current Apple Silicon baseline from [05-01-BASELINE.md](/Users/peterryszkiewicz/Repos/video2x/.planning/phases/05-optimization-gate/05-01-BASELINE.md), the existing MoltenVK-first strategy from [macos-gpu-strategy.md](/Users/peterryszkiewicz/Repos/video2x/docs/book/src/developing/macos-gpu-strategy.md), and the current support boundary of latest macOS on Apple Silicon only.

## Evaluation Criteria

The project will score follow-up options against these criteria:

| Criteria | What It Measures | Why It Matters |
|---------|------------------|----------------|
| Compute throughput | Whether the current processing path is GPU-limited, portability-limited, or obviously underperforming | Determines whether backend work is justified at all |
| Encode and decode overhead | Whether end-to-end user impact is dominated by work outside the compute path | Distinguishes VideoToolbox-style opportunities from backend rewrite pressure |
| Workflow leverage | Whether the option improves contributor confidence, repeatability, or regression detection | CI and packaging compete with backend work for milestone slots |
| Implementation scope | How much code, architecture churn, and validation surface the option adds | Protects the fork from premature backend overreach |
| Maintenance cost | Ongoing burden in docs, support, portability, and debugging | Helps reject attractive but expensive detours |
| Support boundary impact | Whether the option changes the current Apple Silicon / latest-macOS-only posture | Keeps milestone promises explicit |
| Confidence in evidence | Whether the current evidence is strong enough to justify the option now | Prevents decisions from outrunning the measured baseline |

## Bottleneck Classes

The current evidence must be interpreted by bottleneck class instead of treated as one generic performance signal:

| Bottleneck Class | Current Signal | Implication |
|------------------|----------------|------------|
| Compute throughput | Real-ESRGAN and RIFE benchmark mode both completed on Apple Silicon at roughly `119 FPS` on low-resolution synthetic clips | No immediate catastrophic compute-path failure is visible in the current MoltenVK-first path |
| Encode and decode overhead | Benchmark mode still initializes encoder state but skips frame writes, so the baseline is not a full transcode measurement | End-to-end encode or decode bottlenecks are still plausible and must not be inferred from benchmark mode alone |
| Portability-layer limitations | Duplicate MoltenVK warning persists, but no benchmark or runtime proof failure occurred on this host | The current portability path is noisy, not yet disproven |
| Contributor workflow gaps | Benchmark mode still requires a dummy `--output`, and the benchmark helper had to formalize that quirk | Workflow rough edges exist even when runtime works |
| Release-engineering gaps | There is still no macOS CI or packaging path in the validated surface | Workflow automation and release work remain legitimate competing milestones |

## Evidence Gates

### Current MoltenVK Path

Continue with the current MoltenVK-first path unless one of these evidence gates fails:

- benchmark-mode throughput indicates a clear compute-path collapse on representative Apple Silicon workloads
- runtime validation shows reproducible device-list or workload failures tied to the portability layer rather than to host setup noise
- larger or more representative workloads expose capability or maintenance problems that tuning cannot address

### VideoToolbox

VideoToolbox becomes justified only when:

- end-to-end user impact is limited by encode or decode overhead rather than by the compute path
- benchmark-mode throughput is acceptable, but full transcode runs still underperform materially
- the expected win is in media I/O or codec path efficiency, not in ncnn or Vulkan compute itself

VideoToolbox is not justified merely because it is Apple-native.

### Native Metal

Native Metal becomes justified only when:

- the MoltenVK route shows missing capability, unacceptable performance, or maintenance friction that survives benchmark-driven tuning
- the evidence points at the compute/backend path itself rather than at encode/decode or workflow issues
- a narrow spike can answer a specific hotspot question without rewriting the whole stack

Native Metal is not justified by the current low-resolution synthetic baseline.
