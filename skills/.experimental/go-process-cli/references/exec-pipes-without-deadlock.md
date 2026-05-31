---
title: Capture child output with Output, not a pipe you read after Wait
tags: exec, subprocess, io, deadlock
---

## Capture child output with Output, not a pipe you read after Wait

Two classic `os/exec` deadlocks: (1) writing to a child's stdin and reading its stdout in the same goroutine — the OS pipe buffer fills, the child blocks writing, you block writing, neither drains; (2) calling `cmd.Wait()` and *then* reading from `StdoutPipe` — `Wait` closes the pipe as soon as the child exits, so the read races the close. The docs state plainly that it is incorrect to call `Wait` before all pipe reads complete. For the common case — run a command and collect its output — `cmd.Output()` and `cmd.CombinedOutput()` drain in the background and return a fully-read buffer, sidestepping both traps.

```go
// Simple capture — no pipe management, no deadlock.
func gitHead(ctx context.Context) (string, error) {
	out, err := exec.CommandContext(ctx, "git", "rev-parse", "HEAD").Output()
	if err != nil {
		return "", fmt.Errorf("git rev-parse: %w", err)
	}
	return strings.TrimSpace(string(out)), nil
}
```

When you genuinely need streaming (tailing a long-running child's logs), read the pipe to completion *before* calling `Wait`:

```go
stdout, _ := cmd.StdoutPipe()
if err := cmd.Start(); err != nil {
	return err
}
sc := bufio.NewScanner(stdout)
for sc.Scan() { // drain fully first
	slog.Info("child", "line", sc.Text())
}
return cmd.Wait() // only after the pipe is exhausted
```

Reference: [pkg.go.dev — os/exec.Cmd.StdoutPipe](https://pkg.go.dev/os/exec#Cmd.StdoutPipe)
