# Roadmap: Video2X macOS-first build and GPU enablement

## Overview

This roadmap turns the current Linux/Windows-skewed Video2X fork into a project with a first-class Apple Silicon workflow and a defensible macOS GPU path. The journey starts by cleaning up the contributor entrypoint and shared build definitions, then makes macOS dependency and build bring-up explicit, then proves the runtime path on real Apple Silicon before locking in documentation and future backend decisions.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Build Surface Foundation** - Make `just` and CMake presets the canonical contributor workflow
- [x] **Phase 2: macOS Toolchain Bring-Up** - Add explicit Apple Silicon dependency validation and build paths
- [ ] **Phase 3: Runtime Smoke and GPU Proof** - Prove the built macOS binary runs and reaches the intended GPU path
- [ ] **Phase 4: Documentation and Strategy Publication** - Publish first-class macOS docs and the initial GPU strategy
- [ ] **Phase 5: Optimization Gate** - Decide what deeper macOS performance or backend work is actually justified

## Phase Details

### Phase 1: Build Surface Foundation
**Goal**: Establish a clear, canonical contributor interface around `just` and shared CMake presets.
**Depends on**: Nothing (first phase)
**Requirements**: [BOOT-01, BLD-03]
**Success Criteria** (what must be TRUE):
  1. Contributors can discover the canonical macOS workflow from repo docs and the `just` interface.
  2. Shared CMake presets define the supported macOS build configuration and dependency modes for this fork.
  3. Contributors no longer need to reconstruct platform-specific raw CMake flags to understand the intended workflow.
**Plans**: 3 plans

Plans:
- [x] 01-01: Audit and normalize the current `.justfile` and raw build entrypoints
- [x] 01-02: Introduce shared CMake presets for supported macOS build variants and dependency modes
- [x] 01-03: Align `just` command discovery and repo guidance with the preset-driven workflow

### Phase 2: macOS Toolchain Bring-Up
**Goal**: Make Apple Silicon dependency setup and macOS build execution explicit and reproducible.
**Depends on**: Phase 1
**Requirements**: [BOOT-02, BLD-01, BLD-02]
**Success Criteria** (what must be TRUE):
  1. Contributors can run one command that validates required macOS prerequisites and reports missing setup clearly.
  2. A Release macOS Apple Silicon build completes from a clean checkout with one or two canonical `just` commands.
  3. A Debug macOS Apple Silicon build completes without contributors assembling custom CMake invocations by hand.
**Plans**: 3 plans

Plans:
- [x] 02-01: Implement macOS doctor/bootstrap checks for Xcode tooling, Homebrew dependencies, Vulkan SDK, and environment state
- [x] 02-02: Add Apple Silicon Release and Debug build flows backed by the shared presets
- [x] 02-03: Validate the clean-checkout contributor experience and fix mismatches between presets, recipes, and local dependency modes

### Phase 3: Runtime Smoke and GPU Proof
**Goal**: Prove that the macOS build is not only compilable but usable at runtime on Apple Silicon.
**Depends on**: Phase 2
**Requirements**: [VAL-01, VAL-02, VAL-03, GPU-02]
**Success Criteria** (what must be TRUE):
  1. Contributors can run a smoke command that launches the built `video2x` binary successfully on macOS.
  2. Contributors can verify GPU and device enumeration from the built binary on macOS with actionable behavior when portability requirements are not met.
  3. At least one short sample workload completes successfully on macOS and produces output.
  4. The validation flow makes the required Vulkan portability behavior explicit rather than implicit.
**Plans**: 3 plans

Plans:
- [ ] 03-01: Clean up macOS runtime path handling around the built CLI and, if cheap, harden the installed artifact secondarily
- [ ] 03-02: Make the Vulkan and device-listing path portability-aware and explicit on macOS
- [ ] 03-03: Expose the built-binary smoke, device-list, and short sample-workload validation flow through commands and docs

### Phase 4: Documentation and Strategy Publication
**Goal**: Publish a first-class macOS build guide and document the initial GPU strategy and platform boundaries.
**Depends on**: Phase 3
**Requirements**: [GPU-01, DOC-01, DOC-02]
**Success Criteria** (what must be TRUE):
  1. `docs/book` includes a macOS build guide with parity to the Linux and Windows guides.
  2. Project docs explain that the initial GPU strategy is Vulkan SDK plus MoltenVK, and why that is the first path.
  3. Contributor docs explain the canonical `just` commands, dependency setup, and the explicit support boundaries for this fork.
**Plans**: 3 plans

Plans:
- [ ] 04-01: Write the first-class macOS build guide in `docs/book`
- [ ] 04-02: Publish the initial macOS GPU strategy, assumptions, and known limits in repo docs
- [ ] 04-03: Align README and related entrypoint docs with the new macOS-first workflow

### Phase 5: Optimization Gate
**Goal**: Decide, from evidence, what performance and backend work should happen after the first milestone.
**Depends on**: Phase 4
**Requirements**: [GPU-03]
**Success Criteria** (what must be TRUE):
  1. The project records observed gaps or bottlenecks in the initial macOS GPU path.
  2. The project documents the conditions that would justify VideoToolbox experiments or native Metal exploration.
  3. The next milestone recommendation is explicit about whether to optimize, automate CI, package releases, or explore a deeper backend path.
**Plans**: 3 plans

Plans:
- [ ] 05-01: Capture measured or observed limitations in the initial Apple Silicon bring-up
- [ ] 05-02: Evaluate optional follow-up paths such as VideoToolbox tuning or native Metal spikes against explicit criteria
- [ ] 05-03: Record next-milestone recommendations and support boundaries in planning docs

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Build Surface Foundation | 3/3 | Complete | 2026-03-24 |
| 2. macOS Toolchain Bring-Up | 3/3 | Complete | 2026-03-24 |
| 3. Runtime Smoke and GPU Proof | 0/3 | Not started | - |
| 4. Documentation and Strategy Publication | 0/3 | Not started | - |
| 5. Optimization Gate | 0/3 | Not started | - |
