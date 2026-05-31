---
title: Probe liveness with signal 0 — os.FindProcess lies on Unix
tags: state, process, liveness, signals
---

## Probe liveness with signal 0 — os.FindProcess lies on Unix

`os.FindProcess` on Unix *always* succeeds — it never checks whether the PID is alive, it just wraps the number. So `proc, err := os.FindProcess(pid); err == nil` tells you nothing; the returned `*os.Process` is equally non-nil for a running process, a dead one, and a PID that was recycled to a different program. To actually test liveness, send signal `0`: the kernel performs all the permission and existence checks for a real signal but delivers nothing. `nil` means the process exists and you may signal it; `ESRCH` means it's gone; `EPERM` means it exists but belongs to another user.

```go
func isAlive(pid int) bool {
	proc, err := os.FindProcess(pid)
	if err != nil {
		return false // effectively never happens on Unix
	}
	err = proc.Signal(syscall.Signal(0)) // probe, delivers nothing
	switch {
	case err == nil:
		return true // exists and signalable
	case errors.Is(err, syscall.EPERM):
		return true // exists but owned by another user
	default: // ESRCH and friends
		return false
	}
}
```

This matters most when reading a PID from a stale PID file: the number may now belong to an unrelated process, so "the PID exists" is not "my process is running." Treat signal-0 liveness as necessary but not sufficient — confirm identity (PID file age, a control socket, a cmdline check) before acting on a recycled PID.

Reference: [pkg.go.dev — os.FindProcess](https://pkg.go.dev/os#FindProcess)
