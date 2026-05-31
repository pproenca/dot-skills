---
title: Wait on every child you start so it doesn't become a zombie
tags: state, subprocess, zombie, reaping
---

## Wait on every child you start so it doesn't become a zombie

On Unix, a child that exits is not gone — the kernel keeps its exit status in the process table as a *zombie* until the parent calls `wait`. Start children with `cmd.Start()` and never call `cmd.Wait()` (or `Run`/`Output`, which call it for you) and zombies accumulate one per finished child, eventually exhausting the PID table so the supervisor can no longer fork anything. `Wait` reaps the entry and, equally important, releases the goroutines and file descriptors the `os/exec` machinery allocated for that child. Every `Start` needs a matching `Wait`.

```go
func supervise(ctx context.Context, spec Spec) error {
	cmd := exec.CommandContext(ctx, spec.Bin, spec.Args...)
	if err := cmd.Start(); err != nil {
		return err
	}
	slog.Info("started", "name", spec.Name, "pid", cmd.Process.Pid)

	// Always reap: Wait collects the exit status and frees resources.
	err := cmd.Wait()
	slog.Info("exited", "name", spec.Name, "code", cmd.ProcessState.ExitCode())
	return err
}
```

If you start a child and return without waiting (fire-and-forget), spawn a goroutine whose sole job is `cmd.Wait()` — the reap must happen *somewhere*. The one case you don't manage directly is a child that outlives the parent: when the supervisor itself exits, its orphaned children are re-parented to PID 1 (init), which reaps them.

Reference: [pkg.go.dev — os/exec.Cmd.Wait](https://pkg.go.dev/os/exec#Cmd.Wait)
