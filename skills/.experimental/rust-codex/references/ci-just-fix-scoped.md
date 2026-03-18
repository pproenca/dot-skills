---
title: Use Scoped just fix for Clippy Linting
impact: LOW-MEDIUM
impactDescription: avoids slow workspace-wide Clippy builds (10-15min saved)
tags: ci, clippy, linting, just
---

## Use Scoped just fix for Clippy Linting

Before finalizing a large change, run `just fix -p <project>` in the `codex-rs` directory to fix linter issues. Always scope with `-p` to the changed crate to avoid slow workspace-wide Clippy builds. Only run `just fix` without `-p` if you changed shared crates that other packages depend on.

**Incorrect (workspace-wide clippy on a single-crate change):**

```bash
# Changed only codex-rs/tui/src/app.rs
cd codex-rs
just fix
# Runs clippy on all 76 crates, takes 10-15 minutes
```

**Correct (scoped to the changed crate):**

```bash
# Changed only codex-rs/tui/src/app.rs
cd codex-rs
just fix -p codex-tui
# Runs clippy on codex-tui only, takes 1-2 minutes
```

**When NOT to use this pattern:**

- When changes span shared crates like `codex-core` or `codex-protocol`, run unscoped `just fix` to catch downstream lint issues.
