---
phase: 03-runtime-smoke-and-gpu-proof
plan: "02"
subsystem: runtime
tags: [macos, vulkan, moltenvk, portability, gpu]
requires:
  - phase: 03-runtime-smoke-and-gpu-proof
    provides: built macOS system-release CLI plus a working Vulkan portability stack
provides:
  - Explicit macOS Vulkan instance creation with `VK_KHR_portability_enumeration`
  - Actionable macOS portability failure strings for device enumeration regressions
  - Verified `--list-devices` evidence from the built macOS CLI on 2026-03-24
affects: [phase-03, macos-runtime, gpu-enumeration]
tech-stack:
  added: []
  patterns: [portability-aware instance creation, actionable runtime diagnostics]
key-files:
  created:
    - .planning/phases/03-runtime-smoke-and-gpu-proof/03-02-SUMMARY.md
  modified:
    - tools/video2x/src/vulkan_utils.cpp
key-decisions:
  - "On macOS, fail early when the loader does not advertise `VK_KHR_portability_enumeration` instead of relying on implicit loader behavior."
  - "Enable `VK_KHR_portability_enumeration` and `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR` only inside the Vulkan helper, preserving the existing CLI boundary."
  - "Treat negative-runtime verification as source-confirmed on this host because breaking the active MoltenVK stack would destabilize the same machine used for the passing proof."
patterns-established:
  - "macOS Vulkan enumeration should make portability requirements explicit in code and logs."
  - "Runtime failure messages should name `VK_KHR_portability_enumeration`, portability enumeration, or MoltenVK instead of a generic instance-creation failure."
requirements-completed: [VAL-02, GPU-02]
completed: 2026-03-24
---

# Phase 03-02 Summary

**Made the macOS Vulkan helper portability-aware, preserved the passing `--list-devices` path in the built CLI, and tightened failure diagnostics so portability regressions are actionable**

## Accomplishments

- Added instance-extension discovery in `tools/video2x/src/vulkan_utils.cpp` and, on macOS, explicitly enabled `VK_KHR_portability_enumeration` plus `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`.
- Kept the scope inside the Vulkan helper only; no CLI exit-code or outer command-path changes were made.
- Replaced the generic macOS failure path with diagnostics that explicitly call out missing portability enumeration support, incompatible-driver-style instance creation failures, and zero visible portability-backed devices.

## Verification

- `cmake --build --preset macos-system-release`
  - Exited `0` after rebuilding `tools/video2x/src/vulkan_utils.cpp` and relinking `video2x`.
  - Existing `install_name_tool` "no LC_RPATH load command" messages still appeared during install steps, but they did not change this task's exit status and predated this scoped Vulkan-helper work.
- `./build/macos-system-release/video2x --list-devices`
  - Exited `0`.
  - Printed detected GPU names including `Apple M4 Max`.
- Safe negative runtime reproduction was not attempted on this host because it would require breaking the working Vulkan portability stack used for the success proof.
  - Source diff confirmation: the macOS failure strings now explicitly mention `VK_KHR_portability_enumeration`, portability enumeration, and MoltenVK for missing-extension, `vkCreateInstance`, and no-device cases.

## Passing Preconditions Observed On 2026-03-24

- Built `./build/macos-system-release/video2x` binary available locally.
- A working macOS Vulkan portability stack was present and advertised `VK_KHR_portability_enumeration`.
- The runtime environment exposed MoltenVK-backed enumeration strongly enough for `--list-devices` to return at least one real GPU name.

## Runtime Caveats

- This host currently warns that `MVKBlockObserver` is implemented by both `/opt/homebrew/Cellar/molten-vk/1.4.1/lib/libMoltenVK.dylib` and `/usr/local/lib/libMoltenVK.dylib`. Despite that environment warning, `--list-devices` still exited `0` and listed `Apple M4 Max`.
- With portability enumeration enabled explicitly, this host listed multiple `Apple M4 Max` entries. That behavior was observed, not introduced as separate filtering logic, because deduplication was out of scope for 03-02.

## Task Commits

1. `afd13e9` - `feat(03-02): enable macos portability enumeration`
2. `280830c` - `fix(03-02): clarify macos portability failures`

