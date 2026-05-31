---
title: Log process-state transitions as structured slog records
tags: state, logging, slog, observability
---

## Log process-state transitions as structured slog records

A process supervisor's logs are read by *machines* — another supervisor, a log pipeline, an alerting rule — as often as by humans. `fmt.Printf("worker %s exited with %d\n", name, code)` forces every one of those consumers to parse free text with brittle regexes, and it loses the fields the moment the sentence is reworded. `log/slog` (Go 1.21+) emits each transition as key/value pairs that a JSON handler turns into queryable records: filter by `pid`, alert on `event=exited code!=0`, join on `name` — without parsing prose.

```go
func main() {
	// JSON handler → one structured record per line, machine-parseable.
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))
	// ...
}

func onExit(name string, pid, code int, d time.Duration) {
	slog.Info("process transition",
		"event", "exited",
		"name", name,
		"pid", pid,
		"code", code,
		"uptime", d,
	)
}
```

Keep the *key set* stable across transitions (`event`, `name`, `pid`) so records for `started`, `exited`, and `restarted` line up in queries. Attach per-process context once with `logger := slog.With("name", name, "pid", pid)` and reuse it, so you don't repeat the fields — and never restate them. Use a `TextHandler` for interactive runs and the `JSONHandler` under a supervisor; the call sites don't change.

Reference: [pkg.go.dev — log/slog](https://pkg.go.dev/log/slog)
