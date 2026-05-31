---
title: Aggregate failures across workloads with errors.Join
tags: err, errors, aggregation
---

## Aggregate failures across workloads with errors.Join

When a CLI stops, kills, or checks a whole fleet of processes, "return the first error" is the wrong report: if three of ten shutdowns fail, the operator needs all three, not whichever lost the race. `errgroup` is built to cancel on the *first* error — the right tool when one failure should abort the rest, but the wrong one when every item must be attempted and every failure recorded. For the run-them-all case, iterate, collect, and combine with `errors.Join` (Go 1.20+), which wraps multiple errors into one that still works with `errors.Is`/`errors.As`.

```go
func stopAll(ctx context.Context, procs []*Process) error {
	var errs []error
	for _, p := range procs {
		if err := p.Stop(ctx); err != nil {
			// Don't bail — record and keep going so every process is attempted.
			errs = append(errs, fmt.Errorf("stop %s: %w", p.Name, err))
		}
	}
	return errors.Join(errs...) // nil if errs is empty; combined otherwise
}
```

`errors.Join` returns `nil` when the slice is empty, so the happy path needs no special case, and its message lists each failure on its own line. Reach for it whenever completeness matters more than failing fast; reach for `errgroup` when the first failure should cancel the others.

Reference: [pkg.go.dev — errors.Join](https://pkg.go.dev/errors#Join)
