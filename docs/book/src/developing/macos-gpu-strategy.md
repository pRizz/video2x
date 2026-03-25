# macOS GPU Strategy

This fork's initial macOS GPU strategy is **Vulkan SDK plus MoltenVK on Apple Silicon**, not a native Metal rewrite.

## Why This Is The First Path

Video2X already has a Vulkan-shaped processing stack:

- ncnn-backed processors such as Real-ESRGAN, Real-CUGAN, and RIFE already depend on Vulkan for GPU execution
- the Phase 3 macOS runtime proof succeeded with the current built CLI, device-list flow, and Real-ESRGAN sample workload
- the repository now encodes portability-aware Vulkan device enumeration explicitly instead of treating macOS as a special-case afterthought

That makes MoltenVK the shortest defensible route to first-class macOS support for this fork. It maps the existing Vulkan-oriented stack onto Metal without forcing a backend rewrite before the current path has been fully documented and evaluated.

## Current Platform Assumptions

The current macOS support target is intentionally narrow:

- latest macOS on Apple Silicon only
- source builds from this fork, not prepackaged releases
- `just` and shared CMake presets as the contributor entrypoint
- the built `build/macos-system-release/video2x` binary as the canonical validation target

Within that scope, the expectation is that contributors install either the Vulkan SDK or an equivalent MoltenVK-backed tooling surface, then use the validated build and runtime commands already documented elsewhere in the repo.

## Why Not Start With Native Metal

Native Metal remains a possible future direction, but it is not the first move for this milestone.

- Metal would widen the project scope from platform bring-up into backend redesign.
- The current processor stack already works through Vulkan-oriented dependencies such as ncnn.
- The repo now has verified Apple Silicon runtime proof through the portability path, which means the portability route is no longer hypothetical.

For the current milestone, the burden of proof is on the existing Vulkan path to fail materially before a deeper Metal investment becomes justified.
