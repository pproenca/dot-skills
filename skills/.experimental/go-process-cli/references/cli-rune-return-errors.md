---
title: Return errors from RunE; never os.Exit inside a command
tags: cli, cobra, errors, exit-code
---

## Return errors from RunE; never os.Exit inside a command

Cobra offers both `Run func(...)` and `RunE func(...) error`. Using `Run` and calling `os.Exit`/`log.Fatal` inside it has the same defect as anywhere else — it skips deferred cleanup — plus two cobra-specific ones: the command becomes untestable (a test can't assert on a process that exited), and there is no single place to decide the exit code. Use `RunE`, return errors, and let one handler in `main` map them to an exit code. Then suppress cobra's reflex to print full usage on a *runtime* error (usage text belongs to *argument* errors, not "the database was down").

```go
var stopCmd = &cobra.Command{
	Use:           "stop [name]",
	Args:          cobra.ExactArgs(1),
	SilenceUsage:  true, // don't dump usage on a runtime failure
	SilenceErrors: true, // we print the error ourselves, once, in main
	RunE: func(cmd *cobra.Command, args []string) error {
		if err := stopProcess(cmd.Context(), args[0]); err != nil {
			return fmt.Errorf("stop %s: %w", args[0], err)
		}
		return nil
	},
}

func main() {
	if err := rootCmd.ExecuteContext(ctx); err != nil {
		slog.Error("command failed", "err", err)
		os.Exit(1)
	}
}
```

With `SilenceErrors`, `ExecuteContext` still *returns* the error, so `main` owns both the message and the code — and a richer mapping (e.g. `errors.As` to a `*NotFoundError` → exit 2) lives in exactly one spot. Argument-validation errors from cobra's `Args` validators still print usage, which is what you want for those.

Reference: [pkg.go.dev — cobra.Command (RunE, SilenceUsage)](https://pkg.go.dev/github.com/spf13/cobra#Command)
