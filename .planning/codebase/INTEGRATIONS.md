# External Integrations

**Analysis Date:** 2026-03-24

## APIs & External Services

**Payment Processing:**
- None

**Email/SMS:**
- None

**External APIs:**
- GitHub Releases - Binary distribution for Windows, Linux, and AppImage builds referenced in `README.md` and `docs/book/src/installing/*.md`
  - Integration method: Download URLs in release/install docs, plus release automation in `.github/workflows/release.yml`
  - Auth: GitHub Actions secrets for publishing in `.github/workflows/release.yml`
- GitHub Container Registry - Container image distribution for `ghcr.io/k4yt3x/video2x`
  - Integration method: Container publishing in `.github/workflows/build.yml` and `.github/workflows/release.yml`
  - Auth: `secrets.GHCR_USER` and `secrets.GHCR_TOKEN` in `.github/workflows/release.yml`
- GitHub Pages - Documentation hosting for `docs/book/`
  - Integration method: Deployment in `.github/workflows/docs.yml`
  - Auth: GitHub Pages workflow permissions in `.github/workflows/docs.yml`
- GitHub API - Used by docs tooling to fetch the latest mdBook release in `.github/workflows/docs.yml`
  - Integration method: `curl https://api.github.com/repos/rust-lang/mdBook/releases/latest`

## Data Storage

**Databases:**
- None

**File Storage:**
- Local model and shader assets in `models/` are shipped with the repo and installed by `CMakeLists.txt`
- External download mirror `files.k4yt3x.com` is referenced in `README.md` for sample clips and as a fallback download source

**Caching:**
- None

## Authentication & Identity

**Auth Provider:**
- None

**OAuth Integrations:**
- None

## Monitoring & Observability

**Error Tracking:**
- None

**Analytics:**
- None

**Logs:**
- Local stdout/stderr logging only, via the application runtime and `spdlog`

## CI/CD & Deployment

**Hosting:**
- GitHub Actions for CI, release, and docs deployment in `.github/workflows/build.yml`, `.github/workflows/release.yml`, and `.github/workflows/docs.yml`
- GitHub Packages / GHCR for container publishing
- Arch AUR and `archlinuxcn` package ecosystems are called out in `README.md` and `docs/book/src/installing/linux.md`

**CI Pipeline:**
- GitHub Actions workflows build Linux, Windows, container, AppImage, and docs artifacts
- Release automation also downloads third-party build inputs from GitHub-hosted archives, including FFmpeg and ncnn in `.github/workflows/build.yml` and `.github/workflows/release.yml`

## Environment Configuration

**Development:**
- No runtime secret store is required
- Windows build steps expect `third_party/ffmpeg-shared` and `third_party/ncnn-shared` extracted from GitHub release archives, per `docs/book/src/building/windows.md`

**Staging:**
- Not modeled as a separate runtime environment in the repo

**Production:**
- GitHub Actions secrets hold publishing credentials for GHCR and releases in `.github/workflows/release.yml`

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Runtime Network Use

- The application code itself does not declare HTTP clients, webhooks, or cloud SDKs; `rg` over `src/`, `include/`, `tools/`, and `third_party/` only shows local Vulkan/API logging in `tools/video2x/src/vulkan_utils.cpp`
- Network access is concentrated in build/deploy scripts and documentation links, not in the runtime path

---

*Integration audit: 2026-03-24*
*Update when adding/removing external services*
