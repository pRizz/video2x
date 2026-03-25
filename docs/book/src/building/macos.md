# macOS (Apple Silicon)

Instructions for building this fork of Video2X on the latest macOS running on Apple Silicon.

## 1. Support Boundary

This fork currently validates source builds only on the latest macOS running on Apple Silicon. The contributor-facing entrypoint is `just`, and the recipes stay thin by forwarding into the shared presets in `CMakePresets.json`.

The validated path is the `macos-system-*` preset family:

- `macos-system-release`
- `macos-system-debug`

Vendored presets remain available as a fallback when the required Homebrew system packages are unavailable, but they are not the primary workflow for this fork.

## 2. Prerequisites

Before building, make sure the macOS prerequisite surface is in place:

- Xcode or the Apple Command Line Tools selected with `xcode-select`
- Homebrew installed under `/opt/homebrew`
- `cmake`, `ninja`, `ffmpeg`, and `pkg-config` available on `PATH`
- Vulkan portability tooling provided by either the Vulkan SDK or the Homebrew MoltenVK stack, plus `glslangValidator`
- Homebrew `ncnn`, `spdlog`, and `boost` for the validated `macos-system-*` path

Run the canonical preflight check from the repository root before configuring a build:

```bash
just doctor-macos
```

## 3. Build a Release Configuration

The canonical Release flow is:

```bash
just doctor-macos
just configure-macos-system-release
just build-macos-system-release
```

This path is the validated system-mode workflow for the fork and should be the default choice whenever the required Homebrew packages are available.

## 4. Build a Debug Configuration

The matching Debug flow is:

```bash
just doctor-macos
just configure-macos-system-debug
just build-macos-system-debug
```

Use the Debug path when you need symbols or want to inspect the current Apple Silicon build behavior more closely without reconstructing raw CMake invocations by hand.

## 5. Vendored Fallback

If the required system-mode Homebrew packages are not available, use the vendored preset family instead:

```bash
just configure-macos-vendored-release
just build-macos-vendored-release
```

The same naming pattern applies for Debug:

```bash
just configure-macos-vendored-debug
just build-macos-vendored-debug
```

Vendored mode still depends on a populated checkout under `third_party/`. If configure fails inside `third_party/boost`, refresh the local vendored checkout state before assuming the preset-backed workflow is broken.

## 6. Validate the Runtime Contract

After the canonical Release build succeeds, validate the built binary from the repository root:

```bash
just smoke-macos
just list-devices-macos
just sample-macos-realesrgan
```

These commands target the built `build/macos-system-release/video2x` binary first.

- `just smoke-macos` proves the CLI launches successfully on macOS.
- `just list-devices-macos` proves the Vulkan portability stack is working end to end and that the built CLI can enumerate at least one detected GPU.
- `just sample-macos-realesrgan` is the canonical sample workload for this fork's current macOS proof path. It uses the validated Real-ESRGAN processor, generates a short local input clip with `ffmpeg` when needed, and verifies the output with `ffprobe`.

If you need to probe the install tree as a secondary check, call the validation script directly:

```bash
./scripts/macos_runtime_validation.sh smoke --binary-mode installed
```

Do not treat `libplacebo` as the canonical macOS proof path until it has been revalidated locally.

## 7. Current Non-Goals and Caveats

The current v1 milestone is intentionally narrower than a full packaging or release effort:

- macOS packaging is out of scope for v1.
- Required macOS CI is out of scope for v1.
- Intel Mac support is out of scope for this fork.
- Older macOS releases are out of scope; the target is the latest macOS on Apple Silicon.

Keep the following caveats in mind while using the build guide:

- Vendored mode is a fallback, not the primary workflow.
- `third_party/boost` checkout state can still matter when vendored configure fails locally.
- The built binary is the canonical validation target; install-tree checks are secondary.
