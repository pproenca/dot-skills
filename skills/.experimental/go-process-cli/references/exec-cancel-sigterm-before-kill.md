---
title: Cancel a child with SIGTERM before SIGKILL using Cancel and WaitDelay
tags: exec, subprocess, signals, shutdown
---

## Cancel a child with SIGTERM before SIGKILL using Cancel and WaitDelay

`exec.CommandContext`'s built-in cancellation calls `Process.Kill()` — an unconditional SIGKILL. A database, a server, or a job runner killed that way loses in-flight work and leaves corrupt state, because SIGKILL cannot be trapped. Go 1.20 added two fields that fix this without hand-rolling a goroutine: `Cmd.Cancel` lets you choose *how* the process is stopped when the context ends, and `Cmd.WaitDelay` bounds how long to wait afterward before forcing a kill and closing I/O pipes.

```go
func startServer(ctx context.Context) error {
	cmd := exec.CommandContext(ctx, "myserver", "--config", "prod.yaml")

	// On ctx cancellation, ask politely first.
	cmd.Cancel = func() error {
		return cmd.Process.Signal(syscall.SIGTERM)
	}
	// If it hasn't exited 10s after SIGTERM, the runtime SIGKILLs it
	// and unblocks any pipe reads.
	cmd.WaitDelay = 10 * time.Second

	err := cmd.Run()
	switch {
	case ctx.Err() != nil:
		// We initiated the stop; a signal-exit here is the expected
		// outcome, not a crash. Check the context, not the error type.
		slog.Info("server stopped on shutdown signal")
		return nil
	case errors.Is(err, exec.ErrWaitDelay):
		// Exited 0 but left I/O pipes open past the grace window.
		slog.Warn("server exited but I/O pipes lingered past WaitDelay")
		return nil
	default:
		return err // a genuine, unsolicited failure
	}
}
```

This is the process-management equivalent of cancel-cooperatively-then-abort: well-behaved children flush and exit within the grace window; stuck ones are still bounded by `WaitDelay`.

`ErrWaitDelay` is narrower than it looks — the runtime returns it only when the child exits *successfully* but leaves its I/O pipes open past the grace window, not when a child is killed for ignoring SIGTERM (that surfaces as a signal-exit `*exec.ExitError`). So to tell "we stopped it" from "it crashed," check `ctx.Err()`, not the error type. `WaitDelay` bounds two distinct hazards: a child that won't die after `Cancel`, and a child that exited but left inherited pipes open — without it, such a pipe can keep `Wait` blocked indefinitely even after you signal the child.

Reference: [pkg.go.dev — os/exec.Cmd (Cancel, WaitDelay)](https://pkg.go.dev/os/exec#Cmd)
