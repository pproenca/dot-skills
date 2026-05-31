---
title: Kill the process group, not just the direct child
tags: exec, subprocess, process-group, signals
---

## Kill the process group, not just the direct child

Signalling `cmd.Process` reaches only the process you spawned. But CLIs routinely run `sh -c "..."`, `make`, `npm run`, or any wrapper that forks its own children — and those grandchildren survive when you kill the parent, becoming orphans that still hold ports and files. The Unix answer is to put the child in its own **process group** with `Setpgid`, then signal the whole group by sending to the negated PID. A negative PID means "every process in this group."

```go
func runScript(ctx context.Context, script string) error {
	cmd := exec.Command("sh", "-c", script)
	// Put the child in a new process group so we can signal its whole tree.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

	if err := cmd.Start(); err != nil {
		return err
	}
	pgid := cmd.Process.Pid // equals the group id because of Setpgid

	go func() {
		<-ctx.Done()
		// Negative pid = signal the entire process group, grandchildren included.
		_ = syscall.Kill(-pgid, syscall.SIGTERM)
	}()

	return cmd.Wait()
}
```

Use this *instead of* relying on `CommandContext`'s killer when the child spawns its own children — the context killer signals only the direct child, leaving the group behind. (The negative PID survives Go's `int`→`uintptr` conversion inside `syscall.Kill`; the kernel reads it back as a process group. `Setpgid` and group signalling are Unix-specific — on Windows you'd use a Job Object.)

Reference: [pkg.go.dev — syscall.SysProcAttr](https://pkg.go.dev/syscall#SysProcAttr) · [pkg.go.dev — syscall.Kill](https://pkg.go.dev/syscall#Kill)
