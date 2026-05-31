---
title: Make blocking waits cancellable instead of time.Sleep
tags: ctx, context, shutdown, polling
---

## Make blocking waits cancellable instead of time.Sleep

`time.Sleep` is uninterruptible. A poll loop or retry backoff built on `time.Sleep(interval)` cannot react to shutdown: when SIGTERM arrives mid-sleep, the process sits idle for the rest of the interval before noticing, so a 30-second poll loop can take up to 30 seconds to die — long enough for a supervisor to escalate to SIGKILL. Replace the sleep with a `select` over `ctx.Done()` and a timer, so the wait ends the moment *either* the interval elapses or cancellation arrives.

```go
// Unresponsive: a pending SIGTERM waits out the full interval.
func pollBad(ctx context.Context) {
	for {
		check()
		time.Sleep(30 * time.Second) // ignores ctx
	}
}

// Responsive: cancellation wins the race against the tick.
func poll(ctx context.Context) error {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	for {
		check()
		select {
		case <-ticker.C: // next interval
		case <-ctx.Done(): // shutdown — leave immediately
			return ctx.Err()
		}
	}
}
```

The same shape covers a cancellable single wait: `select { case <-time.After(d): case <-ctx.Done(): return ctx.Err() }`. The principle is that any wait inside a long-running process must be racing the context, so shutdown latency is bounded by *how often you reach a select*, not by your longest sleep.

Reference: [pkg.go.dev — time.Ticker](https://pkg.go.dev/time#Ticker) · [pkg.go.dev — context.Context](https://pkg.go.dev/context#Context)
