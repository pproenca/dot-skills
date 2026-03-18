---
title: Update BUILD.bazel for Compile-Time File Access
impact: MEDIUM
impactDescription: prevents Bazel build failure when Cargo passes
tags: cfg, bazel, include-str, build-system
---

## Update BUILD.bazel for Compile-Time File Access

Bazel does not automatically make source-tree files available to compile-time Rust file access. When adding `include_str!`, `include_bytes!`, `sqlx::migrate!`, or similar macros that read files at build time, update the crate's `BUILD.bazel` with the appropriate data attribute (`compile_data`, `build_script_data`, or test data). Cargo resolves these paths from the manifest directory, but Bazel sandboxes builds and will fail if the file is not declared.

**Incorrect (works with Cargo but fails under Bazel):**

```rust
// codex-rs/core/src/prompts.rs
const SYSTEM_PROMPT: &str = include_str!("../prompts/system.txt");
// BUILD.bazel has no reference to prompts/system.txt
// cargo build passes, bazel build fails
```

**Correct (file declared in BUILD.bazel):**

```rust
// codex-rs/core/src/prompts.rs
const SYSTEM_PROMPT: &str = include_str!("../prompts/system.txt");
```

```python
# codex-rs/core/BUILD.bazel
rust_library(
    name = "codex-core",
    srcs = glob(["src/**/*.rs"]),
    compile_data = [
        "prompts/system.txt",
    ],
    # ...
)
```
