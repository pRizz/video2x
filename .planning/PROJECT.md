# Video2X macOS-first build and GPU enablement

## What This Is

This fork evolves Video2X from a Linux/Windows-oriented C++ video upscaling and interpolation project into one that treats modern macOS on Apple Silicon as a first-class development target. The immediate focus is to wrap the existing build surface behind a convenient `just`-driven workflow and research the most efficient path to native-feeling macOS GPU acceleration before committing to deeper backend changes.

## Core Value

Make macOS a first-class, convenient, GPU-capable target for Video2X instead of an afterthought.

## Requirements

### Validated

- ✓ Users can process videos through the existing CLI and shared library pipeline built around FFmpeg decode/process/encode stages — existing
- ✓ The codebase already supports GPU-backed processing paths through Vulkan, ncnn-backed processors, and libplacebo shader filters — existing
- ✓ The repository already has CMake-based builds, docs, and a `.justfile` that automates common Linux/Windows workflows — existing

### Active

- [ ] Contributors on modern Apple Silicon can bootstrap, build, and smoke-test the project with one or two `just` commands from a clean checkout
- [ ] The build system presents a clear, canonical developer interface that wraps existing CMake and packaging steps instead of forcing contributors to memorize platform-specific glue
- [ ] macOS build documentation and task entry points become first-class alongside Linux and Windows rather than implicitly secondary
- [ ] The project has a researched, evidence-backed plan for efficient macOS GPU acceleration, likely starting with a Vulkan portability path and explicitly evaluating when deeper native Metal work is justified
- [ ] The work is staged incrementally so the first milestone can deliver a working macOS workflow and a credible GPU integration direction without overcommitting to packaging or CI work

### Out of Scope

- macOS packaging and distribution artifacts — deferred to a later milestone so this effort can focus on build workflow and GPU-path enablement first
- Broad compatibility across Intel Macs or older macOS releases — modern Apple Silicon and latest macOS only for now
- Required macOS CI in the first milestone — useful later, but not necessary to prove local workflow and platform direction

## Context

Video2X is already a substantial brownfield codebase with a reusable core library in `src/` and `include/libvideo2x/`, a CLI in `tools/video2x/`, and GPU-oriented processor implementations selected at runtime. The current repository surface is strongest on Linux and Windows: documentation includes explicit Linux and Windows build guides, `.github/workflows/` covers Linux, Windows, containers, and docs, and the checked-in `.justfile` is especially Linux- and packaging-oriented. The macOS path is currently unclear, which creates friction for contributors and blocks serious platform work.

This effort is for the user's fork first, not immediate upstreaming. That lowers the coordination cost of experimenting with build ergonomics and platform strategy, but it also means the project artifacts should make the tradeoffs and boundaries explicit so future upstreaming is possible if the approach proves solid.

The GPU question is the biggest technical unknown. The existing codebase is centered on Vulkan-facing processors and FFmpeg-based media handling, while the user wants native-feeling, efficient macOS GPU support on Apple Silicon. The likely path involves researching Vulkan portability and Metal interop options carefully before implementation so the roadmap is grounded in what the current ecosystem actually supports.

## Constraints

- **Platform**: Modern Apple Silicon on the latest macOS only — older Macs and broad compatibility are intentionally deferred to reduce scope
- **Project shape**: Brownfield C++17 / CMake / FFmpeg / Vulkan / ncnn codebase — the plan should wrap and improve existing systems rather than replace them wholesale
- **Workflow**: `just` should become the convenient front door for contributors — the goal is one or two commands to get started on macOS
- **Scope**: CLI and library developer workflow first — packaging/distribution is deferred to a later milestone
- **Delivery strategy**: Incremental macOS GPU enablement — phase 1 can start with the most practical bridge path and only pursue deeper Metal-native architecture if justified by research
- **Ownership**: User fork first — decisions can optimize for experimentation and clarity before upstream coordination

## Current Planning Continuity

- **Next milestone recommendation**: Optimize and characterize the current MoltenVK-first Apple Silicon path before broadening into CI, packaging, or deeper backend work.
- **Deferred next-up options**: macOS CI is recommended after one optimization-focused pass; packaging, VideoToolbox experiments, and native Metal exploration stay deferred until their evidence gates are met.
- **Support boundary still in force**: latest macOS on Apple Silicon only, Vulkan SDK plus MoltenVK as the canonical GPU path, and `just` plus shared CMake presets as the contributor workflow.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Treat macOS as a first-class target | The main current pain is an unclear macOS workflow and second-class platform treatment | Adopted in v1 and retained for the next milestone |
| Use `just` as the canonical developer interface | Contributors should not need to memorize raw CMake, packaging, or bootstrap steps | Adopted in v1 |
| Target Apple Silicon on latest macOS only | Narrowing the platform matrix reduces uncertainty and speeds initial delivery | Adopted in v1 and retained |
| Take an incremental GPU path | A portability bridge may unlock usable macOS support sooner than a full native backend rewrite | Adopted; next milestone optimizes the MoltenVK-first path before any Metal spike |
| Defer packaging/distribution and likely defer CI | The first milestone should prove local workflow and technical direction before broadening scope | Packaging remains deferred; CI deferred until after one optimization-focused pass |

---
*Last updated: 2026-03-25 after Phase 5 recommendation*
