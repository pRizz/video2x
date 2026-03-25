# Phase 4: Documentation and Strategy Publication - Research

**Goal:** Publish a first-class macOS build guide and document the initial GPU strategy and platform boundaries.

## Current Observable State

- `docs/book/src/building/README.md` still says the macOS guidance is intentionally shallow and explicitly defers a first-class guide to a later phase.
- `docs/book/src/SUMMARY.md` includes Windows and Linux build pages but no macOS build page.
- `docs/book/src/developing/README.md` is minimal and there is no dedicated macOS GPU strategy page in the book today.
- `README.md` and `CONTRIBUTING.md` already contain detailed Phase 2 and Phase 3 macOS guidance, including the canonical `just` commands, runtime validation commands, Apple Silicon support boundary, MoltenVK portability expectations, and the built-binary-first validation story.
- `README.md` still tells readers that the docs book only calls out the current macOS boundary and that the fuller first-class macOS guide is deferred.
- Phase 3 verification already proved the current runtime contract on this host: `just smoke-macos`, `just list-devices-macos`, and `just sample-macos-realesrgan` all passed, and the Vulkan helper now encodes portability-aware enumeration explicitly.
- `mdbook` is not currently installed on this host, so Phase 4 execution cannot assume HTML book builds are available unless the environment is prepared or a fallback structural check is used.

## Documentation Implications

- The repo currently has the right macOS facts, but they are concentrated in entrypoint docs rather than in the docs book where long-lived platform guidance belongs.
- Phase 4 should move from "README-first with a shallow book pointer" to "book-first with aligned entrypoints," without inventing a second competing workflow.
- The macOS guide should stay authoritative about:
  - latest macOS on Apple Silicon only
  - `just` as the contributor entrypoint over shared CMake presets
  - `doctor-macos` before configure/build
  - system-mode Release/Debug as the validated path
  - vendored mode as a fallback that still depends on populated `third_party/`
  - built-binary-first runtime validation via Phase 3 commands
- The GPU strategy page should stay explicit that:
  - Vulkan SDK plus MoltenVK is the current first path
  - the codebase is already Vulkan-shaped through ncnn and the existing runtime
  - Vulkan portability requirements on macOS are part of the documented contract, not a hidden implementation detail
  - VideoToolbox and native Metal remain evidence-gated follow-up paths rather than Phase 4 deliverables

## Planning Constraints

- Keep Phase 4 documentation aligned to the commands and behavior already verified in Phases 2 and 3; do not let docs drift into aspirational workflow names.
- Avoid parallel-plan write conflicts by separating new content pages from navigation and top-level entrypoint alignment.
- Do not expand Phase 4 into new code changes unless a docs inconsistency reveals a concrete repo bug.
- Treat `mdbook` build verification as preferred but not guaranteed on this host; the plan should include a structural fallback so documentation work can still be verified locally.
- Keep Phase 5 intact as the place where deeper Metal or VideoToolbox decisions are recorded from evidence; Phase 4 should explain that gate, not preempt it.

## Recommended Planning Shape

1. **Book macOS guide content:** create a real `docs/book` macOS build page that captures prerequisites, canonical build flows, support boundaries, and the handoff into runtime validation.
2. **Book GPU strategy content:** create a dedicated macOS GPU strategy page under the developing section that explains why MoltenVK is the first route and what current boundaries remain.
3. **Entrypoint and navigation alignment:** wire the new pages into the docs book and align `README.md`, `CONTRIBUTING.md`, and book landing pages so contributors see one coherent macOS-first story.

## Verification Notes for Planning

- The final integration plan should verify navigation and content consistency across `README.md`, `CONTRIBUTING.md`, `docs/book/src/SUMMARY.md`, and the new book pages.
- If `mdbook` is available during execution, `mdbook build docs/book` is the strongest local verification.
- If `mdbook` is unavailable, the execution plan should still require structural checks such as:
  - referenced files exist
  - summary entries match new page paths
  - canonical command names and support-boundary language are consistent across docs

## Sources

- `.planning/ROADMAP.md`
- `.planning/STATE.md`
- `.planning/REQUIREMENTS.md`
- `.planning/research/SUMMARY.md`
- `.planning/research/STACK.md`
- `.planning/research/PITFALLS.md`
- `.planning/phases/03-runtime-smoke-and-gpu-proof/03-VERIFICATION.md`
- `README.md`
- `CONTRIBUTING.md`
- `docs/book/src/README.md`
- `docs/book/src/SUMMARY.md`
- `docs/book/src/building/README.md`
- `docs/book/src/building/linux.md`
- `docs/book/src/building/windows.md`
- `docs/book/src/developing/README.md`
