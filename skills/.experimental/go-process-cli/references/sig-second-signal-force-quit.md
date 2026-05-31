---
title: Let a second signal force-quit a wedged shutdown
tags: sig, signals, shutdown, context
---

## Let a second signal force-quit a wedged shutdown

Graceful shutdown can hang — a child ignores SIGTERM, a flush blocks on a dead socket. If the only signal handler is the one that *started* the graceful path, the user hits Ctrl-C again and nothing happens, because the program is still swallowing the signal. The fix is to stop intercepting after the first signal so the next one reaches the default handler and kills the process. `signal.NotifyContext`'s `stop()` does exactly this: once called, the next SIGINT/SIGTERM is no longer caught and terminates the program normally.

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-ctx.Done() // first signal arrived
		slog.Info("shutdown requested; press Ctrl-C again to force quit")
		stop() // stop catching signals — a second one now kills us
	}()

	if err := run(ctx); err != nil {
		os.Exit(1)
	}
}
```

This gives the operator an escape hatch without any extra signal plumbing: first signal = drain, second signal = die. Pair it with a *deadline* on the graceful path (see [Cancel a child with SIGTERM before SIGKILL](exec-cancel-sigterm-before-kill.md)) so an unattended supervisor also gets bounded shutdown time, not just an interactive user.

Reference: [pkg.go.dev — os/signal.NotifyContext](https://pkg.go.dev/os/signal#NotifyContext)
