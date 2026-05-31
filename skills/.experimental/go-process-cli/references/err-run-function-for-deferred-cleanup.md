---
title: Funnel main through a run() error so deferred cleanup runs
tags: err, exit-code, cleanup, defer
---

## Funnel main through a run() error so deferred cleanup runs

`os.Exit` — and `log.Fatal`, which calls it — terminates the process *immediately*, without running any deferred functions. Call either deep inside the program and every `defer` above it is skipped: the PID file is not removed, the child process is not killed, buffered logs are not flushed, the lock is not released. The fix is structural: `main` does nothing but call a `run() error` that owns all the `defer`s, and `os.Exit` appears in exactly one place — after `run` has returned and its defers have unwound.

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	if err := run(ctx); err != nil {
		slog.Error("fatal", "err", err)
		os.Exit(1) // the ONLY os.Exit; reached after run's defers ran
	}
}

func run(ctx context.Context) error {
	pidFile, err := acquirePIDFile("/run/myd.pid")
	if err != nil {
		return err
	}
	defer pidFile.Remove() // actually runs, because run returns normally

	srv := startServer(ctx)
	defer srv.Shutdown() // actually runs

	return srv.Wait(ctx)
}
```

This keeps every cleanup co-located with the resource it cleans up, and guarantees it executes on every exit path. The moment you reach for `log.Fatal` in a helper, you have silently disabled all of it — return an error instead and let it propagate to the single exit point.

Reference: [pkg.go.dev — os.Exit](https://pkg.go.dev/os#Exit)
