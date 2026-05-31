---
title: Wire the signal-bound context into cobra with ExecuteContext
tags: cli, cobra, context, signals
---

## Wire the signal-bound context into cobra with ExecuteContext

A cobra app that calls `rootCmd.Execute()` gives its commands a context of `context.Background()` — one that is never cancelled. Commands then either ignore cancellation entirely or, worse, mint their own `context.Background()` internally, so the SIGTERM you carefully captured in `main` never reaches the work. `rootCmd.ExecuteContext(ctx)` threads your signal-bound context into the command tree; inside any `RunE`, `cmd.Context()` returns it, so shutdown propagates to every child process and goroutine the command spawns.

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// Pass the cancellable context into cobra, not Execute().
	if err := rootCmd.ExecuteContext(ctx); err != nil {
		os.Exit(1)
	}
}

var startCmd = &cobra.Command{
	Use: "start",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := cmd.Context() // the signal-bound context, not Background()
		return supervise(ctx) // SIGTERM now reaches everything below
	},
}
```

Always read the context from `cmd.Context()` inside a command rather than capturing a package-level variable — it keeps the command testable (a test passes its own context) and guarantees you use the one cobra actually propagated.

Reference: [pkg.go.dev — cobra.Command.ExecuteContext](https://pkg.go.dev/github.com/spf13/cobra#Command.ExecuteContext)
