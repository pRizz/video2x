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

## Option Assessment

| Option | Current Evidence | Missing Evidence | Likely Payoff | Disqualify / Defer If | Status |
|--------|------------------|------------------|---------------|------------------------|--------|
| Tune current MoltenVK path | Benchmarks completed successfully for both filtering and interpolation; no catastrophic portability failure appeared | Representative higher-cost workloads and end-to-end comparisons | Highest chance of improving the current path without changing architecture | Defer only if larger workloads reveal that tuning cannot move the real bottleneck | Recommended leading candidate |
| VideoToolbox experiments | GPU strategy already treats VideoToolbox as a possible follow-up when media I/O dominates | Measured end-to-end runs proving encode or decode overhead is the real limiter | Medium if full transcode cost dominates user experience | Defer while only compute-oriented benchmark evidence exists | Not recommended as the first next step |
| Native Metal spike | Current docs define Metal as evidence-gated, and baseline does not show a clear backend failure | Proof of missing capability, unacceptable performance, or maintenance cost in the MoltenVK path | Potentially high, but only if the portability path is genuinely insufficient | Defer while current evidence shows a usable MoltenVK-first path | Not recommended as the first next step |
| macOS CI automation | Would convert the now-validated build, smoke, and benchmark flow into repeatable regression coverage | Decision on whether optimization evidence or workflow automation is the tighter bottleneck right now | High workflow leverage and regression prevention | Defer if the next milestone is supposed to answer a technical performance question first | Recommended soon, but after one optimization-focused pass |
| Packaging and distribution | Still out of scope for v1 and not needed to answer the Phase 5 technical gate | Clear packaging goals and stable local workflow worth automating | Useful user-facing leverage, but not diagnostic leverage | Defer while workflow evidence and regression automation still need to mature | Not recommended as the first next step |

## Current MoltenVK Path Assessment

The current MoltenVK path is the only option with direct measured support from the current Apple Silicon evidence. The compute-oriented benchmark runs were healthy enough to argue against an immediate backend rewrite, but they do not yet tell us enough about real user-visible transcode cost on representative media. That supports a narrow optimization-first milestone rather than a backend-first milestone.

## Recommended Decision Posture

- **Recommended:** optimize and characterize the current MoltenVK-first path next
- **Recommended later:** automate macOS CI once the benchmark and validation surface stabilizes around the optimization work
- **Not recommended now:** VideoToolbox-first work, native Metal-first work, or packaging-first work

## Confidence

The confidence level is moderate rather than high:

- compute evidence exists, but only on synthetic low-resolution clips
- end-to-end encode/decode evidence is still missing
- the current environment still carries duplicate MoltenVK log noise
- the repo now has enough structure to benchmark repeatably, which is a stronger starting point than before Phase 5

That is sufficient to reject backend overreach now, but not sufficient to declare the current path fully optimized.
