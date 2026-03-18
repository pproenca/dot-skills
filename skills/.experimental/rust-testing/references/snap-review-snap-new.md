---
title: Review snap.new Files Before Accepting
impact: MEDIUM
impactDescription: prevents accidental acceptance of incorrect snapshots in 100% of cases
tags: snap, review, snap-new, quality-gate
---

## Review snap.new Files Before Accepting

When `cargo test` produces `.snap.new` files, always read the file content to verify the snapshot is correct before running `cargo insta accept`. A `.snap.new` file that contains garbled output, missing content, or unintended changes indicates a bug in the rendering code.

**Incorrect (blindly accepting without reading the diff):**

```rust
// $ cargo test -p codex-tui
// test ui_tests::test_dialog_render ... FAILED (snapshot mismatch)
// $ cargo insta accept -p codex-tui
// Accepted without reading — snapshot contains broken unicode characters
```

**Correct (reading the .snap.new file before accepting):**

```rust
// $ cargo test -p codex-tui
// test ui_tests::test_dialog_render ... FAILED (snapshot mismatch)

// Read the generated .snap.new to verify correctness:
// $ cat src/snapshots/codex_tui__ui_tests__test_dialog_render.snap.new
// Verify the rendered output looks correct
// Then accept:
// $ cargo insta accept -p codex-tui
```
