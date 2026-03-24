# Contributing to Video2X

Thank you for considering contributing to Video2X. This document outlines the guidelines for contributing to ensure a smooth and effective development process. Should you have any questions or require assistance, please do not hesitate to reach out to the project maintainers.

## Canonical macOS Build Workflow for This Fork

For source builds, this fork currently supports the latest macOS on Apple Silicon. The contributor-facing front door is `just`; the recipes forward to the shared configure and build presets in `CMakePresets.json`.

Start by making sure the prerequisite surface is present:

- Xcode or the Apple Command Line Tools selected with `xcode-select`
- Homebrew installed under `/opt/homebrew`
- `cmake`, `ninja`, `ffmpeg`, and `pkg-config` available on `PATH`
- Vulkan portability tooling available through either the Vulkan SDK or Homebrew MoltenVK tooling, plus `glslangValidator`
- Homebrew `ncnn`, `spdlog`, and `boost` when using the validated `macos-system-*` presets

Run the preflight check first, then use one configure command and one build command from the repo root:

```bash
just doctor-macos
just configure-macos-system-release
just build-macos-system-release
```

Use the matching `*-debug` commands for Debug builds:

```bash
just doctor-macos
just configure-macos-system-debug
just build-macos-system-debug
```

If you need the vendored dependency fallback because those system-only Homebrew packages are unavailable, swap `system` for `vendored` in the command names:

```bash
just configure-macos-vendored-release
just build-macos-vendored-release
```

Vendored mode still depends on a populated repo checkout under `third_party/`. If vendored configure fails in `third_party/boost` while looking for targets such as `Boost::intrusive` or `Boost::smart_ptr`, refresh the local vendored checkout before assuming the preset-backed flow is broken. This document stays scoped to prerequisite setup and build execution; later phases can expand troubleshooting and platform-specific validation.

## Canonical macOS Runtime Validation

After `just configure-macos-system-release` and `just build-macos-system-release`, validate the runtime contract from the repo root with the built binary first:

```bash
just smoke-macos
just list-devices-macos
just sample-macos-realesrgan
```

Those `just` recipes stay thin and delegate to `scripts/macos_runtime_validation.sh`; they do not reuse the Linux-oriented `test-*` recipes or any `LD_LIBRARY_PATH` setup as if that were valid macOS proof.

- `just smoke-macos` passes when the built `build/macos-system-release/video2x` CLI returns success for `--help`.
- `just list-devices-macos` passes when the built CLI exits `0` and prints at least one detected GPU name. The exact preconditions are a working MoltenVK or equivalent Vulkan portability stack, `VK_KHR_portability_enumeration` advertised by the loader, and a real GPU visible through that portability layer.
- `just sample-macos-realesrgan` is the canonical sample workload for Phase 3. It uses the validated `realesrgan` path, generates a short local clip with `ffmpeg -y -f lavfi -i testsrc=size=320x180:rate=12 -t 1 ...` when you do not provide one, and verifies the resulting output file with `ffprobe`.

If you already have a local clip to process, call the script directly and pass it explicitly:

```bash
./scripts/macos_runtime_validation.sh sample-realesrgan --input /absolute/path/to/input.mp4
```

The built binary remains the canonical proof target. The install tree is supported only as a secondary check through the same script:

```bash
./scripts/macos_runtime_validation.sh smoke --binary-mode installed
```

Do not treat `libplacebo` as the canonical macOS runtime proof path until it is revalidated locally. If `realcugan` is needed for host-specific debugging, validate it separately instead of replacing `sample-macos-realesrgan` in the default workflow.

## Commit Messages

Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. This helps maintain a consistent and informative project history.

### Commit Message Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Common Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation updates
- **perf**: Performance improvements that do not affect the code's behavior
- **style**: Changes that do not affect the code's functionality (e.g., formatting)
- **refactor**: Code changes that neither fix a bug nor add a feature
- **test**: Adding or modifying tests
- **chore**: Maintenance or other non-functional updates

#### Common Scopes

Including a scope is optional but is strongly encouraged. One commit should only address changes to a single module or component. If a change must affect multiple modules, use `*` as the scope.

- **avutils**: The audio/video utilities
- **conversions**: The video format conversion utilities
- **decoder**: The video decoder module
- **encoder**: The video encoder module
- **fsutils**: The file system utilities
- **logging**: Any logging-related changes
- **libplacebo**: The libplacebo filter
- **realesrgan**: The Real-ESRGAN filter
- **realcugan**: The Real-CUGAN filter
- **rife**: The RIFE frame interpolator
- **video2x**: The Video2X command-line interface

#### Example

```
feat(encoder): add support for specifying video pixel format

Add the `pix_fmt` field to the `EncoderConfig` struct to allow users to specify the pixel format for encoding.

Closes #12345
```

## Documentation of Changes

All changes must be documented in the `CHANGELOG.md` file. The changelog must adhere to the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

### Example Changelog Entry

```markdown
## [Unreleased]

### Added

- Support for specifying video pixel format in the encoder module (#12345).

### Fixed

- A memory leak in the video encoder module (#23456).
```

## Coding Standards

All code contributions must strictly follow the coding standards outlined in this section. These standards help maintain code quality, readability, and consistency throughout the project. Before submitting any code changes, ensure your code adheres to these guidelines.

### C++ Code Style

C++ code must follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html). This ensures consistency and readability across the codebase. Additionally:

- Use smart pointers (`std::unique_ptr`, `std::shared_ptr`) instead of raw pointers wherever possible.
- Use `#pragma once` for header guards.
- Use `#include` directives in the following order:
  1. Related header files
  2. C++ standard library headers
  3. Third-party library headers
  4. Project-specific headers
- Never check pointers with implicit conversion to `bool`; always perform an explicit comparison with `nullptr`.
- Always set pointers to `nullptr` after freeing the associated memory.

### Code Formatting

All C++ code must be formatted using `clang-format` with the project's `.clang-format` configuration file before submitting a pull request. This helps maintain a uniform code style.

## Submitting a Pull Request

1. **Fork the repository**: Create a personal fork of the project.
2. **Create a branch**: Create a new branch for your changes:
   ```bash
   git checkout -b <type>/<scope>
   ```
3. **Write code**: Make your changes, ensuring they adhere to the coding standards and are properly documented.
4. **Document changes**: Update `CHANGELOG.md` with your changes.
5. **Commit changes**: Write clear and descriptive commit messages using the Conventional Commits format.
6. **Push changes**: Push your branch to your fork:
   ```bash
   git push origin <type>/<scope>
   ```
7. **Open a pull request**: Submit your pull request to the `master` branch of the original repository. Include a clear description of the changes made and reference any relevant issues.

## Code Reviews

All pull requests will undergo a code review. Please expect feedback from the maintainers after you submit the pull request. We may need further information or changes before merging your pull request.
