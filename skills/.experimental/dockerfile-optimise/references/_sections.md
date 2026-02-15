# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Layer Caching & Ordering (cache)

**Impact:** CRITICAL
**Description:** Wrong layer order invalidates all downstream cache, causing full rebuilds. Cache mounts and instruction ordering are the #1 build time optimization — a single misplaced COPY can add minutes to every build.

## 2. Multi-Stage Builds (stage)

**Impact:** CRITICAL
**Description:** Without multi-stage, build tools, compilers, and intermediate artifacts ship to production — 2-10x image size bloat, expanded attack surface, and slower deployments.

## 3. Base Image Selection (base)

**Impact:** HIGH
**Description:** The base image determines the size floor, security surface, and compatibility of every layer above it. Choosing the wrong base cascades through the entire image.

## 4. Build Context Management (ctx)

**Impact:** HIGH
**Description:** Large build contexts cause slow transfers to the builder daemon and spurious cache invalidation. Bind mounts and .dockerignore eliminate unnecessary data transfer.

## 5. Security & Secrets (sec)

**Impact:** HIGH
**Description:** Secrets in ARG or ENV persist in image layers forever and are readable by anyone with image access. Secret mounts, non-root users, and attestations are essential for production images.

## 6. Dependency Management (dep)

**Impact:** MEDIUM-HIGH
**Description:** Package manager operations are the most expensive build steps. Cache mounts, version pinning, and cleanup strategies eliminate redundant downloads and reduce image size.

## 7. Instruction Patterns (inst)

**Impact:** MEDIUM
**Description:** Incorrect CMD/ENTRYPOINT form breaks signal handling; missing HEALTHCHECK prevents orchestrator health detection; heredocs improve multi-line script readability.

## 8. Quality & Validation (lint)

**Impact:** MEDIUM
**Description:** Docker build checks, pipefail, standard labels, and single-concern containers catch silent failures and maintain long-term image quality.
