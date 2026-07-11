---
title: Redesign ownership instead of cloning to compile; keep only designed clones
tags: own, clone, ownership, arc-snapshot
---

## Redesign ownership instead of cloning to compile; keep only designed clones

When the borrow checker complains, the GC-trained reflex is `.clone()` until it compiles — which forks the data, so the copy the caller mutates is no longer the copy the owner reads, and the bug surfaces far from the clone. codex-rs denies `clippy::redundant_clone` workspace-wide and treats every surviving clone as a *designed* one of three kinds: a `Copy` bump (`ThreadId` is a `Copy` UUID newtype), an `Arc` pointer bump (`Config` clones deeply, so it travels as `Arc<Config>`; registry lookups return `thread.clone()` on an `Arc<CodexThread>`), or a deliberate snapshot (`AuthManager` "hands out cloned `CodexAuth` values so the rest of the program has a consistent snapshot"). The review question for any other clone is: who should own this data, and should the copies diverge?

**Incorrect (clone to silence the borrow checker — the copies silently diverge):**

```rust
struct SessionState {
    approved_commands: Vec<String>,
}

fn approve(state: &mut SessionState, command: &str) {
    // Clone so we can "keep using" the list while mutating state… but
    // now `commands` is a fork that never sees this or later approvals.
    let commands = state.approved_commands.clone();
    state.approved_commands.push(command.to_string());
    audit(&commands); // audits stale data
}

fn audit(commands: &[String]) {
    let _ = commands.len();
}
```

**Correct (restructure: mutate first, then borrow the single owner):**

```rust
struct SessionState {
    approved_commands: Vec<String>,
}

fn approve(state: &mut SessionState, command: &str) {
    state.approved_commands.push(command.to_string());
    audit(&state.approved_commands); // audits the one true list
}

fn audit(commands: &[String]) {
    let _ = commands.len();
}
```

**When a clone IS the design:** sharing (`Arc::clone` — advertise it by wrapping the type, as codex-rs does with `Arc<Config>` across 38 sites), snapshot semantics (a consistent copy extracted from behind a lock before an `.await`, so the guard drops early), or a `Copy` ID. In each case the divergence of copies is intended and named — not an accident of appeasing the compiler.

Reference: [codex-rs core/src/thread_manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/thread_manager.rs#L1113), [codex-rs login/src/auth/manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/login/src/auth/manager.rs#L1759), [codex-rs Cargo.toml workspace lints](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml#L498)
