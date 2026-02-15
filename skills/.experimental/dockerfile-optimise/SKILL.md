---
name: dockerfile-optimise
description: Dockerfile optimization guidelines from official Docker documentation. This skill should be used when writing, reviewing, or refactoring Dockerfiles to ensure optimal build time, image size, security, and robustness. Triggers on tasks involving Dockerfile creation, Docker image builds, container optimization, multi-stage builds, build cache, or Docker security hardening.
---

# Dockerfile Optimization Best Practices

Comprehensive Dockerfile optimization guide sourced exclusively from official Docker documentation. Contains 48 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Dockerfiles or modifying existing ones
- Optimizing Docker build times (layer caching, cache mounts, context management)
- Reducing Docker image size (multi-stage builds, minimal base images)
- Hardening container security (secret mounts, non-root users, attestations)
- Setting up CI/CD pipelines with Docker builds
- Reviewing Dockerfiles for anti-patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Layer Caching & Ordering | CRITICAL | `cache-` |
| 2 | Multi-Stage Builds | CRITICAL | `stage-` |
| 3 | Base Image Selection | HIGH | `base-` |
| 4 | Build Context Management | HIGH | `ctx-` |
| 5 | Security & Secrets | HIGH | `sec-` |
| 6 | Dependency Management | MEDIUM-HIGH | `dep-` |
| 7 | Instruction Patterns | MEDIUM | `inst-` |
| 8 | Quality & Validation | MEDIUM | `lint-` |

## Quick Reference

### 1. Layer Caching & Ordering (CRITICAL)

- [`cache-layer-order`](references/cache-layer-order.md) - Order layers by change frequency
- [`cache-copy-deps-first`](references/cache-copy-deps-first.md) - Copy dependency files before source code
- [`cache-copy-link`](references/cache-copy-link.md) - Use COPY --link for cache-efficient layer copying
- [`cache-mount-package`](references/cache-mount-package.md) - Use cache mounts for package managers
- [`cache-apt-combine`](references/cache-apt-combine.md) - Combine apt-get update with install
- [`cache-external`](references/cache-external.md) - Use external cache for CI/CD builds
- [`cache-invalidation`](references/cache-invalidation.md) - Avoid unnecessary cache invalidation
- [`cache-minimize-layers`](references/cache-minimize-layers.md) - Consolidate related RUN instructions

### 2. Multi-Stage Builds (CRITICAL)

- [`stage-separate-build-runtime`](references/stage-separate-build-runtime.md) - Separate build and runtime stages
- [`stage-named-stages`](references/stage-named-stages.md) - Use named build stages
- [`stage-parallel-branches`](references/stage-parallel-branches.md) - Exploit parallel stage execution
- [`stage-target-builds`](references/stage-target-builds.md) - Use target builds for dev/prod
- [`stage-copy-artifacts-only`](references/stage-copy-artifacts-only.md) - Copy only final artifacts between stages
- [`stage-reusable-base`](references/stage-reusable-base.md) - Create reusable base stages

### 3. Base Image Selection (HIGH)

- [`base-minimal-image`](references/base-minimal-image.md) - Use minimal base images
- [`base-official-images`](references/base-official-images.md) - Use Docker Official Images
- [`base-pin-versions`](references/base-pin-versions.md) - Pin base image versions with digests
- [`base-arg-version`](references/base-arg-version.md) - Use ARG before FROM to parameterize base images
- [`base-rebuild-regularly`](references/base-rebuild-regularly.md) - Rebuild images regularly with --pull
- [`base-distroless`](references/base-distroless.md) - Use distroless or scratch images for production

### 4. Build Context Management (HIGH)

- [`ctx-dockerignore`](references/ctx-dockerignore.md) - Use .dockerignore to exclude unnecessary files
- [`ctx-bind-mounts`](references/ctx-bind-mounts.md) - Use bind mounts instead of COPY for build-only files
- [`ctx-minimize-context`](references/ctx-minimize-context.md) - Keep build context small
- [`ctx-syntax-directive`](references/ctx-syntax-directive.md) - Use syntax directive for latest BuildKit features (prerequisite for cache mounts, secret mounts, heredocs, COPY --link)

### 5. Security & Secrets (HIGH)

- [`sec-secret-mounts`](references/sec-secret-mounts.md) - Use secret mounts for sensitive data
- [`sec-non-root-user`](references/sec-non-root-user.md) - Run as non-root user
- [`sec-no-secrets-in-args`](references/sec-no-secrets-in-args.md) - Never pass secrets via ARG or ENV
- [`sec-ssh-mounts`](references/sec-ssh-mounts.md) - Use SSH mounts for private repository access
- [`sec-attestations`](references/sec-attestations.md) - Enable SBOM and provenance attestations
- [`sec-no-unnecessary-packages`](references/sec-no-unnecessary-packages.md) - Avoid installing unnecessary packages
- [`sec-ephemeral-containers`](references/sec-ephemeral-containers.md) - Design ephemeral, stateless containers

### 6. Dependency Management (MEDIUM-HIGH)

- [`dep-cache-mount-apt`](references/dep-cache-mount-apt.md) - Use cache mount for apt package manager
- [`dep-cache-mount-npm`](references/dep-cache-mount-npm.md) - Use cache mount for npm, yarn, and pnpm
- [`dep-cache-mount-pip`](references/dep-cache-mount-pip.md) - Use cache mount for pip
- [`dep-version-pin`](references/dep-version-pin.md) - Pin package versions for reproducibility
- [`dep-cleanup-caches`](references/dep-cleanup-caches.md) - Clean package manager caches in the same layer

### 7. Instruction Patterns (MEDIUM)

- [`inst-json-cmd`](references/inst-json-cmd.md) - Use JSON form for CMD and ENTRYPOINT
- [`inst-healthcheck`](references/inst-healthcheck.md) - Define HEALTHCHECK for container orchestration
- [`inst-heredoc-scripts`](references/inst-heredoc-scripts.md) - Use heredocs for multi-line scripts
- [`inst-entrypoint-exec`](references/inst-entrypoint-exec.md) - Use exec in entrypoint scripts
- [`inst-workdir-absolute`](references/inst-workdir-absolute.md) - Use absolute paths with WORKDIR
- [`inst-copy-over-add`](references/inst-copy-over-add.md) - Prefer COPY over ADD

### 8. Quality & Validation (MEDIUM)

- [`lint-build-checks`](references/lint-build-checks.md) - Enable Docker build checks
- [`lint-pipefail`](references/lint-pipefail.md) - Use pipefail for piped RUN commands
- [`lint-labels`](references/lint-labels.md) - Use standard labels for image metadata
- [`lint-sort-arguments`](references/lint-sort-arguments.md) - Sort multi-line arguments alphabetically
- [`lint-single-concern`](references/lint-single-concern.md) - One concern per container

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
