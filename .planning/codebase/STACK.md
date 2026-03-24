# Technology Stack

**Analysis Date:** 2026-03-24

## Languages

**Primary:**
- C++17 - Application code in `src/`, `include/`, and `tools/video2x/`

**Secondary:**
- CMake - Build configuration in `CMakeLists.txt`
- Bash/PowerShell - Build and release automation in `.github/workflows/*.yml` and `packaging/docker/Dockerfile`

## Runtime

**Environment:**
- Native desktop/CLI runtime on Linux and Windows
- OCI container runtime is supported via `packaging/docker/Dockerfile` and `docs/book/src/running/container.md`
- Requires a Vulkan-capable GPU and AVX2-capable CPUs for the prebuilt binaries, per `README.md`

**Package Manager:**
- No language package manager
- Source builds rely on system packages and vendored submodules, with Arch packaging defined in `packaging/arch/PKGBUILD`

## Frameworks

**Core:**
- FFmpeg libav* libraries - Video decode/encode and frame processing via `CMakeLists.txt` and `docs/book/src/running/command-line.md`
- Vulkan - GPU access and device enumeration via `tools/video2x/src/vulkan_utils.cpp` and `CMakeLists.txt`
- ncnn - Neural inference backend, wired through `third_party/ncnn` or external packages in `CMakeLists.txt`

**Testing:**
- No dedicated test framework is declared in the repo

**Build/Dev:**
- CMake 3.10+ - Primary build system in `CMakeLists.txt`
- mdBook - Documentation site build in `.github/workflows/docs.yml` and `docs/book/book.toml`
- GitHub Actions - CI builds in `.github/workflows/build.yml`, `.github/workflows/release.yml`, and `.github/workflows/docs.yml`

## Key Dependencies

**Critical:**
- FFmpeg (`libavcodec`, `libavfilter`, `libavformat`, `libavutil`, `libswscale`) - Core media pipeline
- ncnn - Neural network inference for Real-ESRGAN, Real-CUGAN, and RIFE
- spdlog - Logging in the shared library and CLI
- Boost.Program_options - CLI argument parsing in `tools/video2x/src/video2x.cpp`
- Vulkan SDK / loader - GPU execution and device discovery

**Infrastructure:**
- OpenMP - Build/runtime dependency in `packaging/arch/PKGBUILD`
- libplacebo / Anime4K GLSL shaders - Shader-based filtering support, backed by `models/libplacebo/`
- Vendored submodules in `third_party/` - `librealesrgan_ncnn_vulkan`, `librealcugan_ncnn_vulkan`, and `librife_ncnn_vulkan` from `.gitmodules`

## Configuration

**Environment:**
- Mostly configured through CMake options such as `VIDEO2X_USE_EXTERNAL_NCNN`, `VIDEO2X_USE_EXTERNAL_SPDLOG`, `VIDEO2X_USE_EXTERNAL_BOOST`, and `VIDEO2X_BUILD_CLI` in `CMakeLists.txt`
- Windows builds expect pre-extracted third-party binaries under `third_party/ffmpeg-shared` and `third_party/ncnn-shared`, as shown in `.github/workflows/build.yml` and `docs/book/src/building/windows.md`

**Build:**
- `CMakeLists.txt` - Main build definition
- `docs/book/book.toml` - mdBook configuration
- `.github/workflows/*.yml` - CI, release, and docs deployment

## Platform Requirements

**Development:**
- Linux or Windows with a C++17 compiler and Vulkan SDK / headers installed
- Git submodules are required for local source builds, per `.gitmodules`

**Production:**
- x86_64-focused binaries and packages
- Linux distribution packages, Windows installers, AppImage, Docker image, and GitHub release artifacts are produced from the repo

---

*Stack analysis: 2026-03-24*
*Update after major dependency changes*
