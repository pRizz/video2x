# Building

This section collects the current build entrypoints for Video2X.

The upstream project already documents Windows and Linux builds in detail. For this fork, the current source-build focus is the latest macOS on Apple Silicon, using the repo-root `just` commands as a thin front door over shared CMake presets.

From the repository root, the canonical macOS Release workflow is:

```bash
just configure-macos-system-release
just build-macos-system-release
```

If system dependencies are not available, the matching `configure-macos-vendored-release` and `build-macos-vendored-release` recipes provide the current fallback. Debug variants follow the same naming pattern.

This page stays intentionally shallow for Phase 1: it points contributors to the implemented command entrypoints and support boundary without pretending a full first-class macOS guide already exists. For the current contributor-facing wording, see the repo-root `README.md` and `CONTRIBUTING.md`.
