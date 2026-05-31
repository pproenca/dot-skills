---
title: Bind a context to SIGINT and SIGTERM with signal.NotifyContext
tags: sig, signals, context, shutdown
---

## Bind a context to SIGINT and SIGTERM with signal.NotifyContext

The reflex is to catch `os.Interrupt` (Ctrl-C) on a channel. But a CLI that manages workloads is almost always stopped by a *supervisor* — systemd, Docker, Kubernetes, a parent process — and those send **SIGTERM**, not SIGINT. A process that only watches SIGINT ignores the polite stop and gets SIGKILL'd a few seconds later with no cleanup. `signal.NotifyContext` (Go 1.16+) collapses the channel boilerplate into a context whose cancellation *is* the shutdown signal, so the same `ctx` you already thread everywhere becomes the shutdown trigger.

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop() // restores default handler; lets a later signal kill normally

	if err := run(ctx); err != nil {
		slog.Error("exited with error", "err", err)
		os.Exit(1)
	}
}

func run(ctx context.Context) error {
	// ctx.Done() fires on the first SIGINT/SIGTERM.
	// Pass ctx down so every worker, child process, and blocking wait
	// observes the same cancellation.
	return supervise(ctx)
}
```

`stop()` is important: after the first signal you usually want a *second* one to terminate the process the default way (see [Let a second signal force-quit](sig-second-signal-force-quit.md)). Calling `stop()` unregisters the handler so the program no longer swallows signals once shutdown is underway.

Reference: [pkg.go.dev — os/signal.NotifyContext](https://pkg.go.dev/os/signal#NotifyContext)
