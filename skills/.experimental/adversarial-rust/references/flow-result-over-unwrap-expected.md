---
title: Return Result for expected failures — unwrap only where Err proves a bug
tags: flow, result, unwrap, panics
---

## Return Result for expected failures — unwrap only where Err proves a bug

`.unwrap()`/`.expect()` on a file read, a parse of user input, or a network response is exception-thinking: "throw and let something upstream deal with it." In Rust nothing upstream deals with it — the thread unwinds (and when it's `main`, the process exits; under `panic = "abort"` the whole process dies on the spot), and the caller was never told failure was possible because the signature returned `T`, not `Result<T, E>`. The dividing line is *whose bug is it*: failures the caller can cause or must react to (missing file, malformed input, refused connection) travel as `Err` through `?`; `unwrap`/`expect` is reserved for states where `Err`/`None` would prove the program itself is broken — and then `expect("...")` should state that invariant.

**Incorrect (an expected failure treated as unreachable):**

```rust
fn load_config(path: &Path) -> Config {
    let raw = std::fs::read_to_string(path).unwrap(); // user typo = process abort
    toml::from_str(&raw).unwrap()
}
```

**Correct (the signature admits what can happen):**

```rust
fn load_config(path: &Path) -> Result<Config, ConfigError> {
    let raw = std::fs::read_to_string(path)
        .map_err(|source| ConfigError::Read { path: path.to_owned(), source })?;
    toml::from_str(&raw).map_err(ConfigError::Parse)
}
```

For mechanically keeping unwrap out of a whole workspace — `[workspace.lints]` denying `unwrap_used`/`expect_used` with local opt-ins — see `defensive-deny-unwrap-workspace-wide` in the sibling `openai-codex-rust-patterns` skill.

Reference: [The Rust Book — To panic! or Not to panic!](https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html)
