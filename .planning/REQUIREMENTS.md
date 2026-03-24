# Requirements: Video2X macOS-first build and GPU enablement

**Defined:** 2026-03-24
**Core Value:** Make macOS a first-class, convenient, GPU-capable target for Video2X instead of an afterthought.

## v1 Requirements

### Bootstrap

- [x] **BOOT-01**: Contributor can discover the canonical macOS workflow from repo docs and the project's `just` command surface
- [ ] **BOOT-02**: Contributor can validate required macOS prerequisites, including Xcode tooling, package dependencies, Vulkan SDK availability, and required environment state, with one command

### Build

- [ ] **BLD-01**: Contributor can configure and build a Release macOS Apple Silicon build from a clean checkout with one or two `just` commands
- [ ] **BLD-02**: Contributor can configure and build a Debug macOS Apple Silicon build without manually assembling raw CMake flags
- [ ] **BLD-03**: Shared CMake presets define the supported macOS build variants and dependency modes used by the fork

### Validation

- [ ] **VAL-01**: Contributor can run a macOS smoke command that proves the built `video2x` binary launches successfully
- [ ] **VAL-02**: Contributor can verify GPU and device enumeration on macOS from the built binary
- [ ] **VAL-03**: Contributor can run at least one short sample workload on macOS and confirm output is produced successfully

### GPU Strategy

- [ ] **GPU-01**: Project docs define the initial macOS GPU strategy around Vulkan SDK and MoltenVK and explain why it is the first path
- [ ] **GPU-02**: Project docs and validation flow call out the Vulkan portability requirements that must be satisfied on macOS
- [ ] **GPU-03**: Project records the conditions that would justify deeper native Metal exploration after the initial bring-up

### Documentation

- [ ] **DOC-01**: `docs/book` includes a first-class macOS build guide alongside the Linux and Windows guides
- [ ] **DOC-02**: Contributor docs explain the canonical `just` commands, supported dependency setup, and expected macOS support boundaries for this fork

## v2 Requirements

### Performance and Automation

- **PERF-01**: Contributor can run Apple Silicon benchmark commands for supported processor paths
- **CI-01**: macOS build and smoke validation run in CI
- **PKG-01**: macOS packaging or distribution artifacts are produced from the fork
- **METL-01**: Project prototypes a native Metal backend only if the MoltenVK path proves insufficient

## Out of Scope

| Feature | Reason |
|---------|--------|
| Intel Mac support | The first milestone intentionally targets modern Apple Silicon only |
| Older macOS release support | The current goal is latest macOS only to reduce bring-up complexity |
| macOS packaging/distribution in v1 | Deferred so the first milestone can focus on build ergonomics and GPU-path validation |
| Required macOS CI in v1 | Deferred until the local macOS workflow is stable and worth automating |
| Full native Metal rewrite in v1 | Too large for the first milestone and not justified before portability-path results exist |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BOOT-01 | Phase 1 | Complete |
| BOOT-02 | Phase 2 | Pending |
| BLD-01 | Phase 2 | Pending |
| BLD-02 | Phase 2 | Pending |
| BLD-03 | Phase 1 | Pending |
| VAL-01 | Phase 3 | Pending |
| VAL-02 | Phase 3 | Pending |
| VAL-03 | Phase 3 | Pending |
| GPU-01 | Phase 4 | Pending |
| GPU-02 | Phase 3 | Pending |
| GPU-03 | Phase 5 | Pending |
| DOC-01 | Phase 4 | Pending |
| DOC-02 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0

---
*Requirements defined: 2026-03-24*
*Last updated: 2026-03-24 after roadmap draft*
