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
