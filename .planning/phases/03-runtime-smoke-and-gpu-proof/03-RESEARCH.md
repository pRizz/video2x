# Phase 3: Runtime Smoke and GPU Proof - Research

**Goal:** Prove the macOS build is not only compilable but usable at runtime on Apple Silicon.

## Current Observable State

- The built tree binary exists at `build/macos-system-release/video2x`.
- `./build/macos-system-release/video2x --help` exits `0` and shows the expected CLI surface, including `--list-devices`, input/output arguments, processor selection, and GPU device arg `-d`.
- `./build/macos-system-release/video2x --list-devices` currently exits `0` on this host and prints `Apple M4 Max`, although it failed earlier in the same session with `Failed to create Vulkan instance.`
- The installed binary exists at `build/install/macos-system-release/bin/video2x` but fails immediately with `dyld: Library not loaded: @rpath/libvideo2x.dylib ... Reason: no LC_RPATH's found`.
- Installed model data exists under `build/install/macos-system-release/share/video2x/models`.
- A synthetic `libplacebo` workload failed locally and also surfaced the `/proc/self/exe` error path on macOS.
- Synthetic `realesrgan` and `realcugan` workloads both succeeded locally and produced output files.
- `tools/video2x/src/vulkan_utils.cpp` creates a Vulkan instance with a bare `VkInstanceCreateInfo` and no portability flags or extension list.
- `tools/video2x/src/argparse.cpp` exposes `--list-devices` and returns success-path `1` when listing works.
- `src/fsutils.cpp` searches the provided path, Linux locations, and the executable directory; it has no macOS-specific shared-data search path.

## Confirmed Root-Cause Candidates / Technical Implications

- The `--help` result proves the built binary starts and the CLI surface is wired correctly.
- The current `--list-devices` success means device enumeration is not categorically broken on this machine, but the earlier failure shows the portability path is still not well encoded or documented.
- Phase 3 therefore needs to capture and make explicit the passing portability conditions, not simply assume the current success will remain stable.
- The sample-workload proof should use a processor path already validated on this macOS toolchain, not `libplacebo`, until the libplacebo-specific runtime issue is understood and fixed.
- The Vulkan FAQ states that on macOS with modern MoltenVK, `vkCreateInstance` may return `VK_ERROR_INCOMPATIBLE_DRIVER` unless `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR` is added and `VK_KHR_portability_enumeration` is enabled.
- The Vulkan reference says `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR` makes portability-compliant physical devices visible in addition to default Vulkan devices.
- MoltenVK is the Vulkan-on-Metal portability layer for macOS, supports macOS 11.0+ at runtime, and exposes `VK_KHR_portability_subset`.
- Vulkan on macOS is via portability and translation layers, not native drivers, so Phase 3 needs to verify the portability path explicitly rather than assume generic Vulkan behavior.
- The installed binary rpath failure is a separate runtime packaging concern from Vulkan enumeration, but it affects any plan that wants to validate the installed artifact instead of only the build tree.

## Planning Constraints For Phase 3

- Keep the phase focused on runtime proof, not broader build-system cleanup.
- Treat Vulkan portability requirements as part of the validation story, not hidden implementation detail.
- Prove both smoke launch and device enumeration from the built binary on Apple Silicon.
- Include at least one short workload that produces output after the binary has been proven launchable and GPU-capable.
- Account for the installed binary failure as a separate validation boundary so the plan can distinguish built-binary proof from optional installed-artifact hardening.
- Use only the evidence above; do not assume a macOS-specific resource fix until a plan slice is explicitly assigned to it.

## Recommended Planning Shape

1. **Smoke launch and artifact boundary:** keep the built binary as the canonical proof target and treat installed-artifact repair as optional hardening.
2. **Portability-aware device enumeration:** encode and document the exact macOS portability conditions behind the observed successful `--list-devices` path, with failure behavior documented when those requirements are missing.
3. **Short sample workload:** choose one small processor-path run that already succeeds on this macOS toolchain and confirms output generation after the CLI launches and GPU/device enumeration are working.

## Sources

- [Vulkan FAQ: macOS portability instance creation](https://vulkan.lunarg.com/doc/view/1.4.328.1/windows/antora/tutorial/latest/90_FAQ.html)
- [VkInstanceCreateFlagBits reference](https://docs.vulkan.org/refpages/latest/refpages/source/VkInstanceCreateFlagBits.html)
- [MoltenVK Runtime User Guide](https://github.com/KhronosGroup/MoltenVK/blob/main/Docs/MoltenVK_Runtime_UserGuide.md)
- [Vulkan Guide: Portability Initiative](https://docs.vulkan.org/guide/latest/portability_initiative.html)
