# Codebase Concerns

**Analysis Date:** 2026-03-24

## Tech Debt

**FFmpeg wiring in `CMakeLists.txt`:**
- Issue: The non-Windows FFmpeg include wiring passes `${libavfilter_LIBRARIES}` into `target_include_directories(...)` instead of `${libavfilter_INCLUDE_DIRS}`.
- Why: This looks like a copy/paste slip in the build glue.
- Impact: Header resolution becomes environment-sensitive and can fail or behave inconsistently across distros.
- Fix approach: Correct the variable, then add a configure-time check that verifies FFmpeg include paths and libraries are both populated.

**Loose input validation in `tools/video2x/src/argparse.cpp` and `tools/video2x/src/validators.cpp`:**
- Issue: Only a subset of options are validated; codec names, pixel formats, extra encoder options, device IDs, and several numeric encoder settings are passed through with little guardrail.
- Why: The CLI is designed to expose FFmpeg and ncnn flexibility quickly.
- Impact: Bad combinations fail late in the pipeline, often after expensive decode/filter setup has already happened.
- Fix approach: Add tighter bounds and compatibility checks at parse time, especially for codec, pixel format, and encoder option combinations.

## Known Bugs

**No repo-confirmed reproducible bug was verified in this pass:**
- Symptoms: None isolated with static inspection alone.
- Trigger: N/A.
- Workaround: N/A.
- Root cause: The current mapping pass surfaced risk areas, not a validated runtime failure.

## Security Considerations

**Remote shader generation in `scripts/download_merge_anime4k_glsl.py`:**
- Risk: The script fetches shader sources from `raw.githubusercontent.com/bloc97/Anime4K/master` with no checksum or signature verification.
- Current mitigation: The commit path is fixed in the script only by branch name, not by content hash.
- Recommendations: Pin to an audited commit, record expected hashes, and fail the script if upstream content changes unexpectedly.

**Custom shader and model path loading in `src/fsutils.cpp`, `tools/video2x/src/validators.cpp`, and `src/libplacebo.cpp`:**
- Risk: Built-in resource lookup accepts arbitrary readable local paths, and `custom_shader_path` is passed into the libplacebo filter string without escaping `'`.
- Current mitigation: The app checks that the path exists before using it.
- Recommendations: Escape filter arguments safely, prefer explicit allowlists for built-in assets, and document that custom shader paths are fully trusted local code.

## Performance Bottlenecks

**Single-threaded frame pipeline in `src/libvideo2x.cpp`:**
- Problem: Decode, filter/interpolate, and encode happen in one serial loop, with the UI thread polling progress every 100 ms.
- Measurement: No repo benchmark numbers are tracked for this path.
- Cause: The design prioritizes simplicity and predictable state transitions over parallel throughput.
- Improvement path: Profile the pipeline, then consider batched decode/filter stages or lower-overhead progress polling if UI work becomes visible.

**Static GPU tile sizing in `src/filter_realesrgan.cpp` and `src/filter_realcugan.cpp`:**
- Problem: Tile size is selected from hardcoded GPU heap-budget thresholds.
- Measurement: No measured throughput table is stored in-repo.
- Cause: The code uses coarse heuristics instead of runtime adaptation.
- Improvement path: Calibrate tile sizing per model/device pair and persist known-good values or auto-tune them from a benchmark run.

## Fragile Areas

**Filter graph construction in `src/libplacebo.cpp`:**
- Why fragile: Filter arguments are assembled by string concatenation, including quoted shader paths.
- Common failures: Paths containing quotes or unusual characters can break filter parsing; Windows path normalization only handles backslashes.
- Safe modification: Build filter args through escaping helpers or a dedicated argument builder instead of raw string concatenation.
- Test coverage: No dedicated tests were found for filter-graph argument escaping.

**Stateful processing loop in `src/libvideo2x.cpp`:**
- Why fragile: Pause/resume/abort, frame cloning, PTS recalculation, and flush behavior all depend on subtle ordering in one loop.
- Common failures: Off-by-one frame counts, bad flush behavior, or hangs if a return path is changed without preserving cleanup semantics.
- Safe modification: Change one state transition at a time and verify abort/pause/flush behavior with a real sample clip.
- Test coverage: No automated integration test was found for the main processing lifecycle.

## Scaling Limits

**GPU memory headroom for ncnn-backed filters in `src/filter_realesrgan.cpp` and `src/filter_realcugan.cpp`:**
- Current capacity: Not quantified in the repo; tile sizes are chosen from fixed heap-budget thresholds.
- Limit: Large frames or lower-VRAM devices can fall back to very small tiles, which increases overhead and can make processing impractically slow.
- Symptoms at limit: Longer runtimes, possible out-of-memory failures, or forced conservative tile sizes.
- Scaling path: Add device/model-specific tuning and a measured fallback path instead of relying only on the current threshold table.

## Dependencies at Risk

**System FFmpeg and optional external ncnn in `CMakeLists.txt`:**
- Risk: The build depends on pkg-config-visible FFmpeg packages and optionally `find_package(ncnn)`, so distro packaging changes can break builds.
- Impact: Compile-time or link-time failures, especially on newer toolchains or minimal Linux environments.
- Migration plan: Keep a supported vendored or containerized build path for environments where system packages drift.

**Upstream model and shader assets in `models/` and `scripts/download_merge_anime4k_glsl.py`:**
- Risk: Bundled model/shader contents can change upstream or become stale relative to the code that expects them.
- Impact: Silent quality regressions or load failures if formats drift.
- Migration plan: Track asset provenance, pin upstream inputs, and add checksum checks for generated assets.

## Missing Critical Features

**No repository test suite for the processing pipeline:**
- Problem: There is no `tests/` tree or equivalent automated coverage for CLI parsing, resource lookup, encoder setup, or FFmpeg/ncnn lifecycle handling.
- Current workaround: Issues are caught manually, typically only after running the app against a sample video.
- Blocks: Regression detection for path handling, option parsing, and frame-lifecycle bugs is mostly manual.
- Implementation complexity: Medium to high, because the best coverage here is integration-style and needs real media fixtures.

**No integrity verification for generated assets:**
- Problem: The repo has a shader-generation script, but no enforced hash/signature checks for the generated files.
- Current workaround: Trust the upstream source and the checked-in artifacts.
- Blocks: Reproducible rebuilds and supply-chain confidence for shader assets.
- Implementation complexity: Low to medium.

## Test Coverage Gaps

**CLI and validation paths in `tools/video2x/src/argparse.cpp` and `tools/video2x/src/validators.cpp`:**
- What's not tested: Option parsing, invalid option rejection, and help/version/list-device exits.
- Risk: Silent regressions in user-facing flags and error handling.
- Priority: High.
- Difficulty to test: Requires process-level tests and, for some paths, platform-specific behavior.

**Filesystem and resource discovery in `src/fsutils.cpp`:**
- What's not tested: Resource lookup precedence, executable-directory fallback, and readable-file checks.
- Risk: Packaged assets can be shadowed or become undiscoverable without notice.
- Priority: High.
- Difficulty to test: Needs fixture directories and controlled path layouts.

**Muxing and flush behavior in `src/encoder.cpp` and `src/libvideo2x.cpp`:**
- What's not tested: Trailer writing, stream mapping, flush paths, and frame-count bookkeeping.
- Risk: Output files can be subtly corrupted even when the process exits successfully.
- Priority: High.
- Difficulty to test: Needs sample inputs with audio/subtitle streams and real encoder backends.

*Concerns audit: 2026-03-24*
*Update as issues are fixed or new ones discovered*
