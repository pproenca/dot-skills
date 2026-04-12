---
title: Stack env, syscalls, and namespace for network isolation
impact: HIGH
impactDescription: prevents network escape through any single uncooperative tool
tags: sandbox, network, seccomp, defense-in-depth
---

## Stack env, syscalls, and namespace for network isolation

Any single layer of network isolation has blind spots — env vars only work for cooperating tools, syscall filters can be bypassed via `io_uring`, and namespaces can be unshared. Codex stacks three coordinated layers: (1) env vars tell cooperating tools to refuse network (`PIP_NO_INDEX`, `NPM_CONFIG_OFFLINE`, `CARGO_NET_OFFLINE`, plus `HTTP(S)_PROXY=http://127.0.0.1:9` to break uncooperative ones); (2) a seccomp filter denies `connect`, `bind`, `listen`, `sendto`, `recvmmsg` and restricts `socket()` to `AF_UNIX`; (3) bubblewrap enters `--unshare-net`.

**Incorrect (single layer, python slips through):**

```rust
env_map.insert("HTTP_PROXY".into(), "http://127.0.0.1:9".into());
// python -c "import socket; socket.socket().connect(...)" still works.
```

**Correct (three layers stacked):**

```rust
// linux-sandbox/src/landlock.rs — syscall layer
NetworkSeccompMode::Restricted => {
    deny_syscall(&mut rules, libc::SYS_connect);
    deny_syscall(&mut rules, libc::SYS_accept);
    deny_syscall(&mut rules, libc::SYS_listen);
    deny_syscall(&mut rules, libc::SYS_sendto);
    deny_syscall(&mut rules, libc::SYS_recvmmsg);
    // recvfrom is allowed on purpose — `cargo clippy` uses socketpair
    // for child IPC and needs it.
    let unix_only_rule = SeccompRule::new(vec![SeccompCondition::new(
        0,
        SeccompCmpArgLen::Dword,
        SeccompCmpOp::Ne,
        libc::AF_UNIX as u64,
    )?])?;
    rules.insert(libc::SYS_socket, vec![unix_only_rule]);
    // io_uring syscalls are unconditionally denied — historic seccomp bypass.
    deny_syscall(&mut rules, libc::SYS_io_uring_setup);
    deny_syscall(&mut rules, libc::SYS_io_uring_enter);
    deny_syscall(&mut rules, libc::SYS_io_uring_register);
}

// windows-sandbox-rs/src/env.rs — env layer + deny-bin PATH prefix
env_map.entry("HTTP_PROXY".into())
    .or_insert_with(|| "http://127.0.0.1:9".into());
env_map.entry("GIT_SSH_COMMAND".into())
    .or_insert_with(|| "cmd /c exit 1".into());
let base = ensure_denybin(&["ssh", "scp"], None)?;
```

The `io_uring` denial is the most surprising one — io_uring has historically been a seccomp bypass path because submissions are queued asynchronously rather than through direct syscalls. Proxy-routed mode inverts the `AF_UNIX` rule and *denies* `AF_UNIX` so a process cannot smuggle traffic through a Unix-socket bridge.

Reference: `codex-rs/linux-sandbox/src/landlock.rs:185`, `codex-rs/windows-sandbox-rs/src/env.rs:123`.
