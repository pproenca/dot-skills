---
title: Pass context as an explicit argument, never store it in a struct
tags: ctx, context, api-design
---

## Pass context as an explicit argument, never store it in a struct

It is tempting to stash a `context.Context` in a struct field so methods don't each need a `ctx` parameter. The Go team explicitly warns against this, and for a process manager the bug is concrete: a context's *scope* is a single operation, but a struct's *lifetime* is the whole program. A `Supervisor{ctx}` captures the context that was current when it was built; every later `Start`/`Stop` call then uses a cancellation scope that no longer matches the request, so a per-command timeout or a fresh shutdown signal never reaches the work. Pass `ctx` as the first parameter of each method that does cancellable work.

```go
// Wrong: the context is frozen at construction time.
type Supervisor struct{ ctx context.Context }
func (s *Supervisor) Start(spec Spec) error { return run(s.ctx, spec) }

// Right: each call carries the context that matches its scope.
type Supervisor struct{ /* config, no context */ }

func (s *Supervisor) Start(ctx context.Context, spec Spec) error {
	return run(ctx, spec)
}
```

The exception the docs allow is narrow: a struct that *is* a single request (and is discarded with it) may hold a context. A long-lived manager, registry, or client is not that. When in doubt, thread it through — the explicit parameter makes the cancellation scope visible at every call site.

Reference: [pkg.go.dev — context (package overview)](https://pkg.go.dev/context) · [go.dev/blog — Contexts and structs](https://go.dev/blog/context-and-structs)
