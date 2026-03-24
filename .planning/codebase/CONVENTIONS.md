# Coding Conventions

**Analysis Date:** 2026-03-24

## Naming Patterns

**Files:**
- Lower snake case for source and header filenames, grouped by area such as `src/logger_manager.cpp`, `include/libvideo2x/logger_manager.h`, `tools/video2x/src/video2x.cpp`, and `tools/video2x/include/validators.h`.
- Public headers live under `include/libvideo2x/`; CLI-specific headers and sources live under `tools/video2x/`.

**Types:**
- PascalCase for classes, structs, and enums, such as `LoggerManager`, `VideoProcessor`, `VideoProcessorState`, and `Arguments`.

**Functions:**
- Lower snake case for free functions and methods, such as `parse_args`, `set_log_level`, `reconfigure_logger`, `process_frames`, and `hook_ffmpeg_logging`.

**Namespaces:**
- Lower snake case namespaces, commonly nested as `video2x::logger_manager` and `video2x::processors`.

**Macros / constants:**
- Upper snake case for macros and compile-time switches, such as `LIBVIDEO2X_API`, `PO_STR_VALUE`, and `BOOST_PROGRAM_OPTIONS_WCHAR_T`.

**Variables:**
- Lower snake case for locals and members, with trailing underscores for members like `logger_`, `frame_idx_`, and `total_frames_`.

## Code Style

**Formatting:**
- `clang-format` is the repo formatter, configured in `.clang-format` with Chromium-based styling, 4-space indentation, a 100-column limit, no short one-line enums, and `InsertBraces: true`.
- Long option tables in `tools/video2x/src/argparse.cpp` use `// clang-format off/on` blocks when alignment matters.

**Language level:**
- `CMakeLists.txt` builds the project as C++17.

**Compiler warnings:**
- `CMakeLists.txt` enables `-Wall -Wextra -Wpedantic -Wconversion -Wshadow` on GNU/Clang and `/W4 /permissive-` on MSVC.

**Headers:**
- `#pragma once` is used instead of traditional include guards.

## Import Organization

**Pattern:**
- Keep the owning header first, then group related standard or system headers cleanly, and keep third-party/project headers in nearby blocks. The exact order varies a bit between files such as `src/logger_manager.cpp` and `tools/video2x/src/argparse.cpp`, so match the local pattern instead of forcing a universal sort.

**Special cases:**
- Use `extern "C"` blocks for FFmpeg headers, as seen in `src/logger_manager.cpp` and `include/libvideo2x/libvideo2x.h`.

**Grouping:**
- Separate header groups with blank lines and let `clang-format` handle spacing and wrapping.

## Error Handling

**Patterns:**
- Prefer explicit checks and early returns over nested control flow.
- Runtime helpers typically return `bool`, `int`, or `nullptr` on recoverable failure, as in `src/logger_manager.cpp`, `src/conversions.cpp`, and `src/processor_factory.cpp`.

**Exceptions:**
- Reserve throwing for CLI validation helpers. `tools/video2x/include/validators.h` and `tools/video2x/src/validators.cpp` throw `po::validation_error` for invalid option values.

**Boundaries:**
- Catch parsing failures at the CLI boundary in `tools/video2x/src/argparse.cpp` and translate them into logged critical errors.

## Logging

**Framework:**
- `spdlog` is the project logger, configured centrally in `src/logger_manager.cpp` and used throughout `src/*.cpp` and `tools/video2x/src/*.cpp`.

**Patterns:**
- Use structured log messages with placeholders, keep FFmpeg messages prefixed with `[FFmpeg]`, and avoid `std::cout` or `printf` for runtime diagnostics.
- The logger exposes standard levels such as `debug`, `info`, `warn`, `error`, and `critical`.

## Comments

**When to comment:**
- Comment intent, platform quirks, and formatting exceptions, not obvious mechanics.
- Small explanatory comments are acceptable around non-obvious logic, such as the newline-safe logger handling in `tools/video2x/src/video2x.cpp`.

**When not to comment:**
- Avoid narrating simple assignments or control flow that already reads clearly.

## Function Design

**Shape:**
- Favor small helpers and early returns. Most functions in this repo are single-purpose wrappers around FFmpeg, ncnn, or CLI parsing.

**Parameters:**
- Pass configs by value when they become owned state, and by reference when used as output parameters, as in `parse_args`.

**Ownership:**
- Use `std::unique_ptr` and `std::shared_ptr` for explicit ownership and lifetime management.

## Module Design

**Structure:**
- Public API lives in `include/libvideo2x/`, implementation lives in `src/`, and the command-line front end lives in `tools/video2x/`.

**Exports:**
- `libvideo2x` is the shared library target and `video2x` is the CLI executable target in `CMakeLists.txt`.

**Barrels:**
- The repo does not use a general barrel-export pattern; headers are included directly.
