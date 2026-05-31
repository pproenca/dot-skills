---
title: Use errgroup for fan-out with cancel-on-first-error
tags: work, concurrency, errgroup, cancellation
---

## Use errgroup for fan-out with cancel-on-first-error

The hand-rolled fan-out — `sync.WaitGroup` plus a buffered error channel — has two recurring defects: it keeps running every other goroutine after one fails (wasting work and time), and it surfaces only whichever error happened to land in the channel first. `errgroup.WithContext` solves both: the first goroutine to return a non-nil error cancels a shared context, so siblings that respect that context stop early, and `Wait()` returns that first error. It is the idiomatic fan-out primitive for managing N concurrent workloads.

```go
func launchAll(ctx context.Context, specs []WorkerSpec) error {
	g, ctx := errgroup.WithContext(ctx)
	for _, spec := range specs {
		spec := spec // capture before Go (pre-1.22 loops)
		g.Go(func() error {
			// ctx is cancelled the moment any sibling returns an error,
			// so a CommandContext child here is killed automatically.
			return runWorker(ctx, spec)
		})
	}
	// Waits for all; returns the first non-nil error.
	return g.Wait()
}
```

The cancellation only helps goroutines that actually *watch* `ctx` — a worker that ignores it runs to completion regardless. That is exactly why every child here should be launched with `exec.CommandContext(ctx, ...)`: the group's cancellation then propagates all the way down to the OS process.

Reference: [pkg.go.dev — golang.org/x/sync/errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup)
