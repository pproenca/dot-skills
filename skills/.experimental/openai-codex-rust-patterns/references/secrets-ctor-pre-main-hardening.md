---
title: Harden a secret-handling process before main() runs, and fail closed
impact: HIGH
impactDescription: closes the core-dump / ptrace / LD_PRELOAD window before any arg parsing or allocation
tags: secrets, hardening, ctor, ptrace
---

## Harden a secret-handling process before main() runs, and fail closed

Hardening done at the top of `main()` is already too late: the runtime's constructors and the allocator have run, and an attacker who set `LD_PRELOAD` has already had their code loaded. Codex runs hardening from a `#[ctor::ctor]` function that executes *before* `main`, disabling core dumps, blocking debugger attach, and stripping dangerous environment variables. Each step that fails calls `std::process::exit` with a distinct code rather than continuing in a weakened state — hardening is fail-closed, not best-effort.

**Incorrect (hardening after the process is already exposed):**

```rust
fn main() -> anyhow::Result<()> {
    disable_core_dumps(); // constructors + allocator already ran; LD_PRELOAD already loaded
    let args = Args::parse();
    run(args)
}
```

**Correct (pre-main ctor, fail-closed, byte-level env filtering):**

```rust
// responses-api-proxy/src/main.rs
#[ctor::ctor]
fn pre_main() {
    codex_process_hardening::pre_main_hardening();
}

// process-hardening/src/lib.rs — Linux path
let ret = unsafe { libc::prctl(libc::PR_SET_DUMPABLE, 0, 0, 0, 0) };
if ret != 0 {
    eprintln!("ERROR: prctl(PR_SET_DUMPABLE, 0) failed: {}", std::io::Error::last_os_error());
    std::process::exit(PRCTL_FAILED_EXIT_CODE); // refuse to run un-hardened
}
set_core_file_size_limit_to_zero();             // RLIMIT_CORE = 0
remove_env_vars_with_prefix(b"LD_");            // macOS strips b"DYLD_"
```

Env keys are filtered on raw bytes (`key.as_os_str().as_bytes().starts_with(prefix)`), not UTF-8 strings, so a non-UTF-8 `LD_…` key can't slip past a lossy conversion. macOS additionally calls `ptrace(PT_DENY_ATTACH)`; each failure exits with its own code so the cause is greppable.

Reference: `codex-rs/responses-api-proxy/src/main.rs:4`, `codex-rs/process-hardening/src/lib.rs:44`, `codex-rs/process-hardening/src/lib.rs:133`.
