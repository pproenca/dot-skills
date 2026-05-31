---
title: Use exec.CommandContext so a child dies with its context
tags: exec, subprocess, context, lifetime
---

## Use exec.CommandContext so a child dies with its context

`exec.Command` creates a child whose lifetime is independent of your program's cancellation. When the CLI is told to shut down, that child keeps running — now an orphan holding a port, a lock, or GPU memory. `exec.CommandContext` ties the process to a `context.Context`: when the context is cancelled (shutdown signal, timeout, parent error), the runtime kills the child automatically. For a tool whose whole job is managing processes, this binding is the default you want, not the exception.

```go
func startWorker(ctx context.Context, addr string) error {
	// When ctx is cancelled, the child is killed automatically.
	cmd := exec.CommandContext(ctx, "worker", "--listen", addr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("worker %s: %w", addr, err)
	}
	return nil
}
```

Be aware of the default kill behavior: plain `CommandContext` sends **SIGKILL** the instant the context is done, giving the child no chance to clean up. For anything stateful, override that with a graceful-then-forceful policy — see [Cancel a child with SIGTERM before SIGKILL](exec-cancel-sigterm-before-kill.md).

Reference: [pkg.go.dev — os/exec.CommandContext](https://pkg.go.dev/os/exec#CommandContext)
