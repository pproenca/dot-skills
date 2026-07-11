---
title: Collapse stateless Manager structs into module functions
tags: arch, modules, free-functions, manager-structs
---

## Collapse stateless Manager structs into module functions

The enterprise habit wraps every capability in a `*Manager`/`*Service` class because a class is the only unit of organization those languages have. In Rust the module is the namespace, so a struct with no fields is pure ceremony: callers must construct it, thread it through, and mock it, for zero information. codex-rs writes its stateless capabilities as plain `pub fn` in modules — `git-utils` exposes `get_git_repo_root`, `collect_git_info`, `recent_commits` as free functions, and `apply-patch` exposes `apply_patch`, `apply_hunks`, `print_summary` the same way. Its `*Manager` structs (`AuthManager` with 14 fields of locks and channels, `ThreadManager` owning the thread registry) earn the name by owning real state.

**Incorrect (a class wrapping stateless behavior):**

```rust
use std::path::{Path, PathBuf};

struct GitInfoService;

impl GitInfoService {
    fn new() -> Self {
        Self
    }

    fn get_git_repo_root(&self, base_dir: &Path) -> Option<PathBuf> {
        base_dir.ancestors().find(|p| p.join(".git").exists()).map(Path::to_path_buf)
    }
}
```

**Correct (the module is the namespace — how codex-rs ships `git-utils`):**

```rust
use std::path::{Path, PathBuf};

pub fn get_git_repo_root(base_dir: &Path) -> Option<PathBuf> {
    base_dir.ancestors().find(|p| p.join(".git").exists()).map(Path::to_path_buf)
}
```

**When a struct IS right:** it owns state or resources. codex-rs's `AuthManager` holds `RwLock<CachedAuth>`, a refresh `Semaphore`, and a `watch` channel — a genuine lifecycle owner. The test is one question: if every method takes `&self` and no method reads a field, the struct is a namespace pretending to be an object.

Reference: [codex-rs git-utils/src/info.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/git-utils/src/info.rs#L35), [codex-rs apply-patch/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/apply-patch/src/lib.rs#L276), [codex-rs login/src/auth/manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/login/src/auth/manager.rs#L1767)
