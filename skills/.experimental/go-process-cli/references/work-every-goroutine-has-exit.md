---
title: Give every goroutine a cancellation path so it cannot leak
tags: work, concurrency, goroutine-leak, context
---

## Give every goroutine a cancellation path so it cannot leak

A goroutine blocked forever on a channel send or receive is never collected — it leaks its stack, and anything it captured, for the life of the process. In a long-running supervisor these accumulate until memory or FDs run out. The default trap is a goroutine that does a bare `ch <- v` or `<-ch` with no second exit: if the reader (or writer) goes away, that goroutine is stuck. Every goroutine that blocks on a channel must *also* select on `ctx.Done()` so cancellation drains it.

```go
// Leaks: if nobody ever reads `results`, this goroutine blocks on send forever.
func watchBad(events <-chan Event, results chan<- Result) {
	for e := range events {
		results <- handle(e) // no escape if the reader is gone
	}
}

// Drains on cancellation: the ctx.Done() case lets the goroutine exit.
func watch(ctx context.Context, events <-chan Event, results chan<- Result) {
	for {
		select {
		case e, ok := <-events:
			if !ok {
				return
			}
			select {
			case results <- handle(e):
			case <-ctx.Done(): // reader gone / shutting down → exit
				return
			}
		case <-ctx.Done():
			return
		}
	}
}
```

The rule generalizes: a goroutine's lifetime must be bounded by something — a closed input channel, a cancelled context, or a `WaitGroup` the owner joins. If you cannot point to what stops a goroutine, it leaks. `defer wg.Done()` and a parent that calls `wg.Wait()` give the owner a way to confirm the goroutine actually finished before shutdown completes.

Reference: [go.dev/blog — Go Concurrency Patterns: Pipelines and cancellation](https://go.dev/blog/pipelines)
