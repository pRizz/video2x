# Codebase Structure

**Analysis Date:** 2026-03-24

## Directory Layout

```text
video2x/
├── .planning/          # Internal planning outputs for codebase mapping
├── cmake/              # CMake package/version templates
├── docs/               # Book-style user and developer documentation
├── include/            # Public C++ headers for libvideo2x
├── models/             # Bundled GLSL shaders and ncnn model assets
├── packaging/          # Packaging assets for AppImage, Debian, Docker, Arch
├── scripts/            # Maintenance and asset download scripts
├── src/                # libvideo2x implementation sources
├── tools/              # CLI application sources and headers
├── CMakeLists.txt      # Top-level build definition
├── README.md           # Project overview and release/install links
├── CHANGELOG.md        # Release history
├── LICENSE             # AGPLv3 license text
├── NOTICE              # Third-party license notices
├── SECURITY.md         # Security policy
├── CONTRIBUTING.md     # Contribution guide
└── CODE_OF_CONDUCT.md   # Community conduct policy
```

## Directory Purposes

**.planning/:**
- Purpose: Repository-local analysis and planning artifacts.
- Contains: Markdown outputs such as `codebase/ARCHITECTURE.md` and `codebase/STRUCTURE.md`.
- Key files: `/.planning/codebase/ARCHITECTURE.md`, `/.planning/codebase/STRUCTURE.md`.
- Subdirectories: `codebase/` for codebase mapping docs.

**src/:**
- Purpose: Core `libvideo2x` implementation.
- Contains: `*.cpp` translation units for processing, FFmpeg wrappers, logging, and processor implementations.
- Key files: `src/libvideo2x.cpp`, `src/processor_factory.cpp`, `src/decoder.cpp`, `src/encoder.cpp`.
- Subdirectories: None.

**include/:**
- Purpose: Public headers for the library API.
- Contains: `include/libvideo2x/*.h`.
- Key files: `include/libvideo2x/libvideo2x.h`, `include/libvideo2x/processor.h`, `include/libvideo2x/encoder.h`.
- Subdirectories: `include/libvideo2x/` groups the exported API by module.

**tools/:**
- Purpose: CLI application sources and support headers.
- Contains: `tools/video2x/src/*.cpp` and `tools/video2x/include/*.h`.
- Key files: `tools/video2x/src/video2x.cpp`, `tools/video2x/src/argparse.cpp`, `tools/video2x/src/validators.cpp`.
- Subdirectories: `tools/video2x/src/` for implementation, `tools/video2x/include/` for headers.

**docs/:**
- Purpose: User and developer documentation site.
- Contains: `docs/book/` with Markdown source organized by topic.
- Key files: `docs/book/book.toml`, `docs/book/src/SUMMARY.md`, `docs/book/src/developing/architecture.md`.
- Subdirectories: `docs/book/src/building/`, `installing/`, `running/`, `developing/`, `other/`.

**models/:**
- Purpose: Runtime assets for processors.
- Contains: Shader files and `.bin`/`.param` model pairs.
- Key files: `models/libplacebo/anime4k-v4-a.glsl`, `models/realesrgan/realesrgan-plus-x4.bin`, `models/rife/rife-v4.26/flownet.bin`.
- Subdirectories: `libplacebo/`, `realcugan/`, `realesrgan/`, `rife/`.

**packaging/:**
- Purpose: Distribution and platform packaging support.
- Contains: AppImage metadata, Debian control files, Dockerfile, Arch PKGBUILD.
- Key files: `packaging/docker/Dockerfile`, `packaging/arch/PKGBUILD`, `packaging/appimage/video2x.desktop`.
- Subdirectories: `appimage/`, `debian/`, `docker/`, `arch/`.

**scripts/:**
- Purpose: One-off maintenance scripts.
- Contains: Python utilities for asset retrieval or regeneration.
- Key files: `scripts/download_merge_anime4k_glsl.py`.
- Subdirectories: None.

**cmake/:**
- Purpose: Reusable CMake configuration snippets and generated-file templates.
- Contains: `*.cmake.in` and header templates.
- Key files: `cmake/Video2XConfig.cmake.in`, `cmake/version.h.in`.
- Subdirectories: None.

## Key File Locations

**Entry Points:**
- `tools/video2x/src/video2x.cpp`: CLI executable entry point.
- `src/libvideo2x.cpp`: Library-level processing entry point.

**Configuration:**
- `CMakeLists.txt`: Top-level build options and target wiring.
- `cmake/version.h.in`: Generated version header template.
- `docs/book/book.toml`: Documentation site configuration.

**Core Logic:**
- `src/libvideo2x.cpp`: Processing orchestration.
- `src/processor_factory.cpp`: Processor registration and creation.
- `src/decoder.cpp` / `src/encoder.cpp`: FFmpeg input/output wrappers.
- `src/filter_*.cpp` and `src/interpolator_rife.cpp`: Concrete processing modules.

**Testing:**
- No dedicated `tests/` directory is present in the current tree.
- Behavioral verification is therefore driven by build/runtime execution and documentation checks.

**Documentation:**
- `README.md`: Public project overview.
- `docs/book/src/README.md`: Documentation landing page.
- `docs/book/src/developing/architecture.md`: Historical and current architecture notes.
- `docs/book/src/running/command-line.md`: CLI usage documentation.

## Naming Conventions

**Files:**
- `src/*.cpp` for implementation units, for example `src/encoder.cpp`.
- `include/libvideo2x/*.h` for public headers, for example `include/libvideo2x/processor.h`.
- `tools/video2x/src/*.cpp` and `tools/video2x/include/*.h` for CLI code.
- `models/**/**/*.bin` and `models/**/**/*.param` for ncnn model weights and definitions.
- `models/libplacebo/*.glsl` for bundled shader programs.

**Directories:**
- Lowercase, descriptive directory names such as `src/`, `include/`, `models/`, and `packaging/`.
- Topic-based doc directories under `docs/book/src/` such as `building/`, `installing/`, and `running/`.

**Special Patterns:**
- `README.md` is used as the landing page for several doc folders.
- `SUMMARY.md` defines the documentation book navigation.
- `*.in` files in `cmake/` are templates expanded by CMake.

## Where to Add New Code

**New Feature:**
- Primary code: `src/`
- Tests: Add a new `tests/` tree if verification is needed.
- Config if needed: `CMakeLists.txt` or `cmake/`

**New Processor / Module:**
- Implementation: `src/`
- Public API: `include/libvideo2x/`
- Registration: `src/processor_factory.cpp`

**New CLI Option:**
- Definition and parsing: `tools/video2x/src/argparse.cpp`
- Validation helpers: `tools/video2x/include/validators.h` and `tools/video2x/src/validators.cpp`
- UI/progress behavior: `tools/video2x/src/video2x.cpp`

**Utilities:**
- Shared helpers: `src/` or `include/libvideo2x/` depending on whether the helper is internal or exported.
- Path/string helpers: `include/libvideo2x/fsutils.h` and `src/fsutils.cpp`.

**Docs / Packaging / Assets:**
- Documentation: `docs/book/src/`
- Packaging: `packaging/`
- Model and shader assets: `models/`
- Asset maintenance scripts: `scripts/`

## Special Directories

**docs/book/:**
- Purpose: Generated documentation source tree for the project book.
- Source: Hand-authored Markdown and `book.toml`.
- Committed: Yes.

**models/:**
- Purpose: Versioned runtime assets required by the supported processors.
- Source: Bundled with the repo and referenced by CLI validation and processor selection.
- Committed: Yes.

**packaging/docker/:**
- Purpose: Container build definition for Video2X deployments.
- Source: `packaging/docker/Dockerfile`.
- Committed: Yes.

---

*Structure analysis: 2026-03-24*
*Update when directory structure changes*
