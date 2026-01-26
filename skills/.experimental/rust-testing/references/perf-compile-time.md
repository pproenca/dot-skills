---
title: Reduce Test Compilation Time
impact: LOW-MEDIUM
impactDescription: 30-50% faster test builds
tags: perf, compilation, dev-dependencies, incremental
---

## Reduce Test Compilation Time

Minimize dev-dependencies and use workspace-level dependency deduplication. Each unique dependency version adds to compile time.

**Incorrect (duplicated and heavy dev-dependencies):**

```toml
# crate1/Cargo.toml
[dev-dependencies]
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
reqwest = { version = "0.11", features = ["json", "native-tls"] }

# crate2/Cargo.toml
[dev-dependencies]
tokio = { version = "1.34", features = ["full"] }  # Different version!
serde = { version = "1.0", features = ["derive"] }
```

**Correct (workspace-level dev-dependencies):**

```toml
# Cargo.toml (workspace root)
[workspace]
members = ["crate1", "crate2"]

[workspace.dependencies]
tokio = { version = "1.35", features = ["rt", "macros"] }  # Minimal features
serde = { version = "1.0", features = ["derive"] }
proptest = "1.4"

# crate1/Cargo.toml
[dev-dependencies]
tokio.workspace = true
serde.workspace = true

# crate2/Cargo.toml
[dev-dependencies]
tokio.workspace = true  # Same version, shared compilation
```

**Minimal feature sets:**

```toml
# Instead of "full", list only needed features
[dev-dependencies]
tokio = { version = "1.35", features = ["rt", "macros", "time"] }
# Not: features = ["full"]  # Compiles unused features

reqwest = { version = "0.11", features = ["json"] }
# Not: features = ["json", "native-tls", "cookies", "gzip"]
```

**Compile tests in parallel:**

```bash
# Use all available cores for compilation
CARGO_BUILD_JOBS=$(nproc) cargo test

# Or set in config
# .cargo/config.toml
[build]
jobs = 8
```

**Incremental compilation for tests:**

```toml
# .cargo/config.toml
[profile.dev]
incremental = true

[profile.test]
incremental = true
```

**Split heavy test dependencies:**

```toml
# Cargo.toml
[features]
expensive-tests = ["proptest", "criterion"]

[dev-dependencies]
# Always included - fast
tempfile = "3.10"
assert_cmd = "2.0"

# Optional - slow to compile
proptest = { version = "1.4", optional = true }
criterion = { version = "0.5", optional = true }
```

```bash
# Fast tests (default)
cargo test

# Full test suite when needed
cargo test --features expensive-tests
```

Reference: [Cargo - Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html)
