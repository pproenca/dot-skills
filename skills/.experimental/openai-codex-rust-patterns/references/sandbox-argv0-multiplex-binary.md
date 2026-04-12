---
title: Multiplex helper binaries via argv[0] and symlinks
impact: MEDIUM-HIGH
impactDescription: eliminates TOCTOU risk and packaging overhead of shipping multiple binaries
tags: sandbox, deployment, argv, linux
---

## Multiplex helper binaries via argv[0] and symlinks

Shipping multiple binaries (`codex`, `codex-linux-sandbox`, `apply_patch`) is a packaging headache — and finding `codex-linux-sandbox` via `which` opens a TOCTOU between lookup and exec. Codex ships one binary. On startup it inspects `argv[0]`'s basename and dispatches into the relevant sub-entry-point, otherwise falls through to `main`. At startup the CLI creates a locked per-session temp dir under `~/.codex/tmp/arg0/`, drops symlinks for each alias pointing at `current_exe()`, and prepends that dir to `PATH`.

**Incorrect (multiple binaries, TOCTOU on lookup):**

```rust
let helper = which::which("codex-linux-sandbox")?; // race window
Command::new(helper).args(...).spawn()?;
```

**Correct (single binary, argv[0] dispatch, locked temp symlinks):**

```rust
// arg0/src/lib.rs
pub fn arg0_dispatch() -> Option<Arg0PathEntryGuard> {
    let mut args = std::env::args_os();
    let argv0 = args.next().unwrap_or_default();
    let exe_name = Path::new(&argv0)
        .file_name()
        .and_then(|s| s.to_str())
        .unwrap_or("");
    if exe_name == CODEX_LINUX_SANDBOX_ARG0 {
        codex_linux_sandbox::run_main();
    } else if exe_name == APPLY_PATCH_ARG0 {
        codex_apply_patch::main();
    }
    /* return guard for symlink temp dir */
}

// linux-sandbox/src/linux_run_main.rs — bwrap preserves argv0
if supports_argv0 {
    argv.splice(
        command_separator_index..command_separator_index,
        ["--argv0".to_string(), CODEX_LINUX_SANDBOX_ARG0.to_string()],
    );
}
```

The temp dir is `chmod 0700` and locked via `fs2::try_lock` so a janitor thread can clean stale siblings without racing live sessions. Windows, which lacks good symlinks, falls back to generated `.bat` stubs that exec the main binary.

Reference: `codex-rs/arg0/src/lib.rs:53`, `codex-rs/linux-sandbox/src/linux_run_main.rs:497`.
