---
title: Stage incompatible restrictions via re-executing the same binary
impact: HIGH
impactDescription: eliminates the "seccomp breaks bwrap" conflict via two-stage application
tags: sandbox, linux, seccomp, bubblewrap
---

## Stage incompatible restrictions via re-executing the same binary

On Linux, some restrictions are mutually exclusive at setup time. Bubblewrap may need `CAP_SYS_ADMIN` to build the filesystem view, but turning on seccomp plus `PR_SET_NO_NEW_PRIVS` first would strip that capability and break bwrap. The solution: run bwrap as the outer stage, then have bwrap re-exec the same Codex binary back with a hidden `--apply-seccomp-then-exec` flag. The inner stage is already inside the namespace, applies seccomp to its own thread, then `execvp`'s the real user command.

**Incorrect (single-stage, restrictions fight each other):**

```rust
fn apply_all_restrictions() -> io::Result<()> {
    apply_seccomp()?; // sets NO_NEW_PRIVS
    bwrap_build_namespace()?; // fails — needs CAP_SYS_ADMIN
    Ok(())
}
```

**Correct (outer bwrap re-execs self to apply inner seccomp):**

```rust
// linux-sandbox/src/linux_run_main.rs
// Inner stage: apply seccomp after bubblewrap has already built
// the filesystem view.
if apply_seccomp_then_exec {
    if let Err(e) = apply_sandbox_policy_to_current_thread(
        &sandbox_policy,
        network_sandbox_policy,
        &sandbox_policy_cwd,
        /*apply_landlock_fs*/ false,
        allow_network_for_proxy,
        proxy_routing_active,
    ) {
        panic!("error applying Linux sandbox restrictions: {e:?}");
    }
    exec_or_panic(command);
}

// linux-sandbox/src/landlock.rs — conditional gate
if network_seccomp_mode.is_some()
    || (apply_landlock_fs && !sandbox_policy.has_full_disk_write_access())
{
    set_no_new_privs()?;
}
```

`apply_sandbox_policy_to_current_thread` is applied to the current *thread*, not the process — so it only affects the about-to-exec path and cannot leak into the outer process. The sandbox helper is literally the same ELF as the Codex CLI — work is selected by argv flags.

Reference: `codex-rs/linux-sandbox/src/linux_run_main.rs:138`, `codex-rs/linux-sandbox/src/landlock.rs:56`.
