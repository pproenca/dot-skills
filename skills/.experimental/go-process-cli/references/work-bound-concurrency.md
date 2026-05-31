---
title: Bound concurrency instead of one goroutine per task
tags: work, concurrency, errgroup, resource-limit
---

## Bound concurrency instead of one goroutine per task

`for _, t := range tasks { go process(t) }` looks harmless because goroutines are cheap — but each one here *spawns an OS process*, opens files, and grabs sockets. With ten thousand tasks you get ten thousand concurrent children: PID exhaustion, `too many open files`, a thrashed scheduler, and an OOM kill. The number of in-flight goroutines is unrelated to how many *processes* the machine can sustain. Cap it. `errgroup.SetLimit(n)` makes `g.Go` block until a slot frees, so at most `n` workloads run at once with no manual semaphore.

```go
func processAll(ctx context.Context, tasks []Task) error {
	g, ctx := errgroup.WithContext(ctx)
	g.SetLimit(runtime.NumCPU()) // cap concurrent children

	for _, t := range tasks {
		t := t
		g.Go(func() error {
			return runTask(ctx, t) // blocks here until a slot is free
		})
	}
	return g.Wait()
}
```

Pick the limit from the bottleneck the workloads actually contend for: CPU-bound children → `runtime.NumCPU()`; processes hammering one database → its connection limit; I/O-bound → higher. The point is that the limit is a deliberate number tied to a real resource, not "however many tasks happened to arrive." For finer control across multiple call sites, `golang.org/x/sync/semaphore` offers a weighted variant.

Reference: [pkg.go.dev — errgroup.Group.SetLimit](https://pkg.go.dev/golang.org/x/sync/errgroup#Group.SetLimit)
