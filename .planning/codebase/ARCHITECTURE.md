# Architecture

**Analysis Date:** 2026-03-24

## Pattern Overview

**Overall:** Native C++ video-processing library with a CLI front end

**Key Characteristics:**
- Reusable core library in `src/` and `include/libvideo2x/`
- CLI orchestration in `tools/video2x/`
- FFmpeg-driven decode/process/encode pipeline
- GPU-accelerated model and shader processors selected at runtime

## Layers

**CLI / Orchestration Layer:**
- Purpose: Parse command-line options, configure logging, start processing, and show progress.
- Contains: Argument parsing, progress timer, newline-safe console sink, Vulkan device listing.
- Depends on: `libvideo2x`, Boost.Program_options, spdlog.
- Used by: End users invoking `video2x`.

**Core Processing Library:**
- Purpose: Own the video pipeline and processing lifecycle.
- Contains: `VideoProcessor`, decoder/encoder wrappers, frame-processing loop, error/state handling.
- Depends on: FFmpeg, processor abstractions, logging helpers.
- Used by: CLI entry point and any future consumers of the library API.

**Processor Abstraction Layer:**
- Purpose: Hide the differences between upscalers and interpolators behind one interface.
- Contains: `processors::Processor`, `Filter`, `Interpolator`, `ProcessorFactory`, config structs.
- Depends on: FFmpeg frame/context types and processor-specific implementations.
- Used by: `VideoProcessor` when selecting and running a concrete processor.

**Processor Implementations:**
- Purpose: Run the actual enhancement algorithms.
- Contains: `FilterLibplacebo`, `FilterRealesrgan`, `FilterRealcugan`, `InterpolatorRIFE`.
- Depends on: Vulkan/ncnn/FFmpeg integration and model or shader assets.
- Used by: `ProcessorFactory` based on `ProcessorConfig`.

**Support Layer:**
- Purpose: Provide logging, filesystem, conversion, and FFmpeg utility helpers.
- Contains: `logger_manager`, `fsutils`, `avutils`, `conversions`.
- Depends on: stdlib, FFmpeg, spdlog, platform-specific path handling.
- Used by: Most of the core and CLI code.

## Data Flow

**CLI Processing Run:**

1. User runs `tools/video2x/src/video2x.cpp` through the `video2x` executable.
2. `parse_args()` in `tools/video2x/src/argparse.cpp` fills `Arguments`, `ProcessorConfig`, and `EncoderConfig`.
3. `LoggerManager` configures the `video2x` logger and hooks FFmpeg log output.
4. `VideoProcessor` is created with the selected processor, encoder settings, Vulkan device index, and hardware decode mode.
5. `VideoProcessor::process()` opens the input via `decoder::Decoder`, builds the concrete processor through `processors::ProcessorFactory`, and initializes `encoder::Encoder`.
6. Frames flow through `process_frames()` where FFmpeg decodes packets, the selected processor transforms or interpolates frames, and the encoder writes output.
7. The CLI thread shows progress and reacts to pause/resume/abort while the worker thread runs.
8. Success, failure, or abort is reported through logger output and the process return code.

**State Management:**
- Runtime state is in-memory and per-process: `VideoProcessorState`, frame counters, and CLI pause/resume timers.
- Persistent inputs are the input/output media files plus model/shader assets in `models/`.
- There is no database or network-backed application state.

## Key Abstractions

**VideoProcessor:**
- Purpose: Top-level pipeline coordinator.
- Examples: `src/libvideo2x.cpp`, `include/libvideo2x/libvideo2x.h`.
- Pattern: Facade over decode/process/encode stages.

**Processor:**
- Purpose: Uniform interface for all enhancement modes.
- Examples: `include/libvideo2x/processor.h`, `src/filter_libplacebo.cpp`, `src/interpolator_rife.cpp`.
- Pattern: Polymorphic strategy with factory creation.

**Decoder / Encoder:**
- Purpose: Wrap FFmpeg input and output setup.
- Examples: `include/libvideo2x/decoder.h`, `include/libvideo2x/encoder.h`, `src/decoder.cpp`, `src/encoder.cpp`.
- Pattern: Resource-owning adapters around libavformat/libavcodec.

**ProcessorFactory:**
- Purpose: Map `ProcessorType` to a concrete processor constructor.
- Examples: `src/processor_factory.cpp`.
- Pattern: Singleton registry with creator callbacks.

**LoggerManager and fsutils:**
- Purpose: Centralize logging and platform-specific path/string conversion.
- Examples: `src/logger_manager.cpp`, `include/libvideo2x/logger_manager.h`, `src/fsutils.cpp`, `include/libvideo2x/fsutils.h`.
- Pattern: Shared utility services.

## Entry Points

**CLI Executable:**
- Location: `tools/video2x/src/video2x.cpp`
- Triggers: User runs the `video2x` command.
- Responsibilities: Configure logger, parse args, start processing thread, display status.

**Library API:**
- Location: `src/libvideo2x.cpp`
- Triggers: Any consumer that links against `libvideo2x`.
- Responsibilities: Run the full processing pipeline for one input/output pair.

## Error Handling

**Strategy:** Log the concrete FFmpeg or validation failure, set processor state to failed, and return integer error codes.

**Patterns:**
- `VideoProcessor::process()` centralizes fatal error handling with a local helper that logs `av_strerror()` output.
- CLI parsing fails fast through Boost.Program_options validation in `tools/video2x/src/argparse.cpp` and `tools/video2x/include/validators.h`.
- The CLI exits with distinct nonzero codes for failure and abort paths.

## Cross-Cutting Concerns

**Logging:**
- `src/logger_manager.cpp` owns the shared `spdlog` logger and forwards FFmpeg logs through a callback.
- `tools/video2x/src/newline_safe_sink.cpp` preserves clean progress-bar output.

**Validation:**
- CLI option validation lives in `tools/video2x/src/argparse.cpp` and `tools/video2x/include/validators.h`.
- Processor-specific config checks are repeated in `src/processor_factory.cpp` before constructing a processor.

**Hardware Acceleration:**
- The pipeline can use an FFmpeg hardware device context plus Vulkan-backed processors.
- Device selection is passed from CLI parsing into `VideoProcessor` and then into `ProcessorFactory`.

**Asset Loading:**
- Shader and model names resolve to files under `models/`, such as `models/libplacebo/`, `models/realesrgan/`, `models/realcugan/`, and `models/rife/`.

---

*Architecture analysis: 2026-03-24*
*Update when major patterns change*
