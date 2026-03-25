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

## Portability Requirements

The macOS GPU path is only valid when the Vulkan portability contract is satisfied.

- `VK_KHR_portability_enumeration` must be available and enabled during instance creation on macOS
- MoltenVK or equivalent Vulkan portability tooling must be installed and visible to the loader
- the validated runtime proof remains the built-binary-first command set:
  - `just smoke-macos`
  - `just list-devices-macos`
  - `just sample-macos-realesrgan`

Those commands are not optional polish. They are the current proof that the built CLI launches, enumerates a GPU through the portability layer, and completes a short ncnn-backed sample workload on Apple Silicon.

## Current Caveats

The portability route is working, but contributors should keep the current caveats in mind:

- a duplicate MoltenVK install can emit the `MVKBlockObserver` warning seen during Phase 3 validation when both `/opt/homebrew` and `/usr/local` provide `libMoltenVK.dylib`
- the install step still emits non-fatal `install_name_tool` rpath noise on some third-party dylibs, even though the repo-owned artifacts validate afterward
- the built binary is the canonical proof target; install-tree validation is still secondary
- `libplacebo` is not the canonical macOS proof path for this fork today

These caveats are documentation boundaries, not reasons to abandon the portability route immediately.

## Future Evidence Gate

Future backend work should stay evidence-driven.

- **VideoToolbox** is a possible optimization path, but only after measured end-to-end limitations show that decode or encode overhead is the real bottleneck.
- **Native Metal** becomes worth exploring only if the MoltenVK route shows missing capability, unacceptable performance, or maintenance friction that cannot be solved within the Vulkan-oriented stack.

Phase 5 is where this fork should record that evidence and decide whether deeper Apple-specific work is justified. Phase 4 only defines the current strategy and the warning signs that would force a reevaluation.
