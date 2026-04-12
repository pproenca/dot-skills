---
title: Clear the env and tether children via pre_exec before every spawn
impact: HIGH
impactDescription: prevents LD_PRELOAD inheritance and orphaned grandchildren after a parent kill
tags: sandbox, unix, lifecycle, env-scrubbing
---

## Clear the env and tether children via pre_exec before every spawn

Inherited environments leak `LD_LIBRARY_PATH`, `DYLD_INSERT_LIBRARIES`, and ambient shell secrets into every child — and if the agent is `kill -9`'d, its children keep running compute forever. Codex's spawn path calls `cmd.env_clear()` before re-adding a whitelisted env map, and in the `pre_exec` closure does three orthogonal things: `detach_from_tty`, `PR_SET_PDEATHSIG(SIGTERM)`, and outside the closure `kill_on_drop(true)`.

**Incorrect (inherits env and leaks grandchildren):**

```rust
let mut cmd = Command::new(program);
cmd.args(args); // inherits LD_PRELOAD, LD_LIBRARY_PATH, secrets
let handle = cmd.spawn()?; // no pdeathsig — kill -9 orphans compute
```

**Correct (clear env + tether via pre_exec):**

```rust
// core/src/spawn.rs
let mut cmd = Command::new(&program);
#[cfg(unix)]
cmd.arg0(
    arg0.map_or_else(|| program.to_string_lossy().to_string(), String::from),
);
cmd.args(args);
cmd.current_dir(cwd);
cmd.env_clear();
cmd.envs(allowed_env);

#[cfg(unix)]
unsafe {
    let detach_from_tty = matches!(
        stdio_policy,
        StdioPolicy::RedirectForShellTool,
    );
    #[cfg(target_os = "linux")]
    let parent_pid = libc::getpid(); // captured BEFORE the closure
    cmd.pre_exec(move || {
        if detach_from_tty {
            codex_utils_pty::process_group::detach_from_tty()?;
        }
        #[cfg(target_os = "linux")]
        codex_utils_pty::process_group::set_parent_death_signal(parent_pid)?;
        Ok(())
    });
}
cmd.stdin(Stdio::null()); // ripgrep hangs on open empty pipe otherwise
cmd.kill_on_drop(true);
```

`parent_pid` is captured *before* the closure because inside `pre_exec` the child is already a new process — `getpid()` there would return the child's own pid. `stdin = Stdio::null()` is specifically because ripgrep has a heuristic that reads stdin when it's an open pipe, causing it to hang on an empty one.

Reference: `codex-rs/core/src/spawn.rs:66`, `codex-rs/core/src/spawn.rs:85`.
