# Testing Patterns

**Analysis Date:** 2026-03-24

## Test Framework

**Runner:**
- No committed automated unit or integration test harness is present. `CMakeLists.txt` does not call `enable_testing()` or `add_test()`, and there is no in-tree `ctest`, `gtest`, `catch2`, or `doctest` usage in the workspace root.
- The CI workflows in `.github/workflows/build.yml` and `.github/workflows/release.yml` are build/package checks, not test suites.

**Assertion Library:**
- None in-tree.

**Run Commands:**
```bash
just build

cmake -S . -B build \
  -DVIDEO2X_USE_EXTERNAL_NCNN=OFF \
  -DVIDEO2X_USE_EXTERNAL_SPDLOG=OFF \
  -DVIDEO2X_USE_EXTERNAL_BOOST=OFF \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=build/libvideo2x-shared
cmake --build build --config Release --parallel --target install

just ubuntu2404
just test-realesrgan
```

## Test File Organization

**Location:**
- There is no committed `tests/` tree or `*_test.cpp` layout today. Validation helpers live next to CLI code in `tools/video2x/include/validators.h` and `tools/video2x/src/validators.cpp`.

**Naming:**
- If tests are added later, follow a clear source-adjacent pattern such as `foo_test.cpp` or a dedicated `tests/` directory.

**Structure:**
```text
src/
  *.cpp
include/libvideo2x/
  *.h
tools/video2x/src/
  *.cpp
tools/video2x/include/
  *.h
```

## Test Structure

**Suite Organization:**
- No formal suites are defined. Current verification is build-first, then smoke-test the CLI or package output.

**Patterns:**
- Use the repository docs to validate the build path on the target platform, then run a short CLI command with a known-good input.
- CLI validation errors are handled with `po::validation_error` in `tools/video2x/src/validators.cpp` and surfaced through `tools/video2x/src/argparse.cpp`.
- `README.md` documents `standard-test.mp4` as the canonical sample for setup validation and benchmarking.

## Mocking

**Framework:**
- None committed.

**What to Mock:**
- If tests are introduced, mock external dependencies such as FFmpeg, Vulkan, filesystem access, and networked model/download paths.

**What NOT to Mock:**
- Prefer real unit-level logic for pure validation helpers and small transformations.

## Fixtures and Factories

**Test Data:**
- The repo documents `README.md`'s `Standard Test Clip (240P)` as the canonical sample for setup validation and benchmarking.

**Location:**
- No shared fixture directory exists today.

## Coverage

**Requirements:**
- No coverage target or coverage gate is defined in the repo.

**Configuration:**
- No coverage configuration is committed.

**View Coverage:**
```bash
# No repo-defined coverage command exists today
```

## Test Types

**Unit Tests:**
- Not currently committed.

**Integration Tests:**
- Not currently committed.

**E2E Tests:**
- No browser or GUI E2E harness is committed for this repo.

## Common Patterns

**Async Testing:**
- Not applicable to the current test setup.

**Error Testing:**
- Runtime code generally returns `false`, `nullptr`, or a nonzero status on failure and logs via `spdlog`; CLI validation throws `po::validation_error`.

**Smoke Checks:**
- Use `video2x --help`, `video2x --list-devices`, and a short encode against the standard test clip from `README.md` to verify a build.
