---
title: Only the sender closes a channel, exactly once
tags: work, concurrency, channels, panic
---

## Only the sender closes a channel, exactly once

`close(ch)` on an already-closed channel, or a send on a closed channel, is an unrecoverable panic — and in a worker pool it is easy to trigger by accident: two goroutines both think they own the channel, or a receiver closes it to "signal done." Go's convention exists precisely to make this impossible to get wrong: a channel is closed by its **sole sender**, and only to broadcast "no more values are coming." Receivers never close; they detect closure via the two-value receive. With multiple senders, none of them closes — a separate `sync.WaitGroup` coordinates the close.

```go
func produce(ctx context.Context, jobs []Job) <-chan Job {
	out := make(chan Job)
	go func() {
		defer close(out) // the single sender owns the close
		for _, j := range jobs {
			select {
			case out <- j:
			case <-ctx.Done():
				return // defer still closes out exactly once
			}
		}
	}()
	return out
}

// Fan-in from many senders: close once, after all of them finish.
func merge(cs ...<-chan Result) <-chan Result {
	out := make(chan Result)
	var wg sync.WaitGroup
	wg.Add(len(cs))
	for _, c := range cs {
		go func(c <-chan Result) {
			defer wg.Done()
			for r := range c {
				out <- r
			}
		}(c)
	}
	go func() { wg.Wait(); close(out) }() // one closer, after all senders done
	return out
}
```

Returning a receive-only channel (`<-chan T`) from a constructor encodes the ownership in the type: callers literally cannot close what they only receive from.

Reference: [go.dev/blog — Go Concurrency Patterns: Pipelines and cancellation](https://go.dev/blog/pipelines)
