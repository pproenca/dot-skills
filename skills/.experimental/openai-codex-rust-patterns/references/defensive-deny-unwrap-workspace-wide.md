---
title: Deny unwrap and expect at the workspace level
impact: CRITICAL
impactDescription: prevents unreviewed panic sites across a 75-crate workspace
tags: defensive, lint, clippy, panic-discipline
---

## Deny unwrap and expect at the workspace level

Panics in production are almost always `.unwrap()` or `.expect()` calls that slipped through review. Codex inverts the default: `[workspace.lints.clippy]` sets `unwrap_used = "deny"` and `expect_used = "deny"` so panicking becomes a compile error, and `clippy.toml` relaxes the ban inside tests only. Every intentional panic site must be annotated locally, turning each exception into a grepable tombstone whose reason is spelled out next to the code.

**Incorrect (panic site slips through review):**

```rust
// Buried in a helper function — reviewers can't scan for this
fn absolute_tmp_root() -> AbsolutePathBuf {
    AbsolutePathBuf::from_absolute_path("/tmp")
        .expect("/tmp is absolute")
}
```

**Correct (workspace-wide deny, local annotated escape hatch):**

```toml
# Cargo.toml — workspace root lints
[workspace.lints.clippy]
expect_used = "deny"
unwrap_used = "deny"
```

```rust
// protocol/src/permissions.rs — escape hatch is visible and justified
FileSystemSpecialPath::SlashTmp => {
    #[allow(clippy::expect_used)]
    let slash_tmp = AbsolutePathBuf::from_absolute_path("/tmp")
        .expect("/tmp is absolute");
    /* ... */
}
```

The `#[allow]` attribute is the declaration that this `expect` is intentional, and the adjacent comment documents the invariant that makes it safe. Reviewers can `git grep expect_used` across the repo to audit every panic site in minutes.

Reference: `codex-rs/Cargo.toml:366`, `codex-rs/protocol/src/permissions.rs:1055`.
