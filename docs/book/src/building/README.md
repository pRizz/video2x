# Building

This section collects the current build entrypoints for Video2X.

The upstream project already documents Windows and Linux builds in detail. For this fork, the current source-build focus is the latest macOS on Apple Silicon, using the repo-root `just` commands as a thin front door over shared CMake presets.

Start with the dedicated [macOS (Apple Silicon)](macos.md) guide for the validated prerequisite surface, the canonical `just` build commands, and the current runtime-validation handoff.

From the repository root, the canonical macOS Release workflow is still:

```bash
just configure-macos-system-release
just build-macos-system-release
```

If system dependencies are not available, the matching `configure-macos-vendored-release` and `build-macos-vendored-release` recipes provide the current fallback. Debug variants follow the same naming pattern, and the macOS guide documents the full support boundary for this fork.

The Windows and Linux pages remain available below for their respective workflows, but the macOS guide is now the first-class source-build path for this fork.
