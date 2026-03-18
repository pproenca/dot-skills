---
title: Follow the cargo insta Test Accept Workflow
impact: MEDIUM
impactDescription: 100% snapshot review rate before acceptance
tags: snap, cargo-insta, workflow, review
---

## Follow the cargo insta Test Accept Workflow

Follow the three-step workflow: run tests to generate `.snap.new` files, review changes, then accept. Never blindly accept snapshots without reviewing the diff. This workflow ensures every visual change is intentionally approved.

**Incorrect (accepting snapshots without review):**

```rust
// Developer runs tests, sees failures, immediately accepts
// $ cargo test -p codex-tui
// $ cargo insta accept -p codex-tui
// Snapshots accepted without checking what changed
```

**Correct (review then accept workflow):**

```rust
// Step 1: Run tests to generate updated snapshots
// $ cargo test -p codex-tui

// Step 2: Check what is pending
// $ cargo insta pending-snapshots -p codex-tui

// Step 3: Review the .snap.new files directly or preview
// $ cargo insta show -p codex-tui path/to/file.snap.new

// Step 4: Only after review, accept all snapshots
// $ cargo insta accept -p codex-tui
```
