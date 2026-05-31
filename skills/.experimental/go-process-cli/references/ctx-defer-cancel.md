---
title: Always defer cancel() from WithCancel, WithTimeout, and WithDeadline
tags: ctx, context, resource-leak
---

## Always defer cancel() from WithCancel, WithTimeout, and WithDeadline

Every derived context holds resources — at minimum a goroutine and, for timeouts, a `time.Timer` — that are released only when its `cancel` func is called. Drop the `cancel` on the floor and that context lives until its parent is cancelled, which for a root context is *program exit*. In a supervisor that creates a timeout per child, that is a steady leak of timers and goroutines. The discipline is mechanical: bind both return values and `defer cancel()` on the next line, even for `WithTimeout` where the deadline will fire anyway — `cancel` also frees resources immediately when the work finishes early, and `go vet` flags the missing call.

```go
func probe(ctx context.Context, addr string) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel() // releases the timer the instant probe returns

	cmd := exec.CommandContext(ctx, "healthcheck", addr)
	return cmd.Run()
}
```

`defer cancel()` is correct even on the success path: cancelling an already-finished or already-timed-out context is a harmless no-op, so there is never a reason to omit it. The only mistake is *not* calling it.

Reference: [pkg.go.dev — context.WithTimeout](https://pkg.go.dev/context#WithTimeout)
