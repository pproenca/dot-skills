---
title: Register a drain timeout to escape grandchild pipe leaks
impact: CRITICAL
impactDescription: prevents the whole agent from hanging when a killed child leaves grandchildren holding stdout
tags: defensive, timeout, subprocess, resource-leak
---

## Register a drain timeout to escape grandchild pipe leaks

Killing a timed-out child is not enough. If the child already forked grandchildren, they inherit the stdout and stderr pipes and hold them open, so the `read()` on the pipe never returns — hanging the whole agent. Codex runs the stdout collector in its own `tokio::spawn` and applies a separate `IO_DRAIN_TIMEOUT_MS` to joining that task, aborting the drain if it exceeds the deadline and returning an empty `StreamOutput`. The in-file comment explicitly pins the reasoning in place so no one removes the timeout as "redundant".

**Incorrect (single timeout on the child — hangs on inherited pipes):**

```rust
let output = tokio::time::timeout(
    child_deadline,
    child.wait_with_output(),
).await?;
// If the child is killed mid-run, grandchildren still hold stdout.
// wait_with_output() never returns — agent hangs forever.
```

**Correct (separate drain timeout with grepable justification):**

```rust
// core/src/exec.rs:73 — comment pins the invariant
// If the child process spawned grandchildren that inherited its
// stdout/stderr file descriptors those pipes may stay open after we
// `kill` the direct child on timeout. That would cause the `read_capped`
// tasks to block on `read()` indefinitely, effectively hanging the whole
// agent.
pub const IO_DRAIN_TIMEOUT_MS: u64 = 2_000;

async fn await_output(
    handle: &mut JoinHandle<io::Result<StreamOutput<Vec<u8>>>>,
    drain_timeout: Duration,
) -> io::Result<StreamOutput<Vec<u8>>> {
    match tokio::time::timeout(drain_timeout, &mut *handle).await {
        Ok(join_res) => join_res?,
        Err(_elapsed) => {
            handle.abort();
            Ok(StreamOutput { text: Vec::new(), truncated_after_lines: None })
        }
    }
}
```

The killing order matters too: `kill_child_process_group(&mut child)` runs before `child.start_kill()` so the grandchildren get a SIGKILL through the process group, and the drain timeout is the belt-and-braces safety net if that fails.

Reference: `codex-rs/core/src/exec.rs:73`, `codex-rs/core/src/exec.rs:1263`.
