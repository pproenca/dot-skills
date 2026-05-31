---
title: Read the child's real exit code from exec.ExitError
tags: exec, subprocess, exit-code, errors
---

## Read the child's real exit code from exec.ExitError

A process supervisor must distinguish *why* a child failed: exit 0 (clean), exit 1 (generic error), exit 137 (SIGKILL/OOM), exit 2 (config error), and so on. The naive handler collapses everything to "err != nil → exit 1", discarding the one number a supervisor needs to decide whether to restart, alert, or give up. `cmd.Run()` returns an `*exec.ExitError` when the child ran but exited non-zero; unwrap it with `errors.As` and call `ExitCode()`. A nil error means exit 0; a non-`ExitError` error (e.g. binary not found) means the child never ran at all.

```go
func runChild(ctx context.Context, name string, args ...string) (code int, err error) {
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr

	err = cmd.Run()
	if err == nil {
		return 0, nil
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		// Child ran and exited non-zero; ExitCode() is its real status
		// (-1 if it was terminated by a signal).
		return exitErr.ExitCode(), nil
	}
	// Failed to start: bad path, permission denied, context cancelled.
	return -1, fmt.Errorf("could not run %s: %w", name, err)
}
```

Propagating the child's code to your own process lets shells and CI scripts react correctly: `os.Exit(code)` at the top level makes your wrapper transparent. Folding it to 1 makes every failure look identical.

Reference: [pkg.go.dev — os/exec.ExitError](https://pkg.go.dev/os/exec#ExitError) · [pkg.go.dev — os.ProcessState.ExitCode](https://pkg.go.dev/os#ProcessState.ExitCode)
