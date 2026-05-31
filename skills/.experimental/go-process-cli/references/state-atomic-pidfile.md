---
title: Create the PID or lock file atomically with O_CREATE and O_EXCL
tags: state, pidfile, locking, race
---

## Create the PID or lock file atomically with O_CREATE and O_EXCL

The "single instance" guard is usually written as *check then create*: `if _, err := os.Stat(pidFile); os.IsNotExist(err) { write(pidFile) }`. That is a time-of-check/time-of-use race — two copies of the daemon launched together both pass the `Stat`, both write, and both run. The atomic primitive is `os.OpenFile` with `O_CREATE|O_EXCL`: the kernel guarantees the create-only-if-absent is a single uninterruptible operation, so exactly one process wins and the loser gets `EEXIST`.

```go
func acquirePIDFile(path string) (*os.File, error) {
	// O_EXCL makes this fail if the file already exists — atomically.
	f, err := os.OpenFile(path, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0o644)
	if errors.Is(err, os.ErrExist) {
		// Someone holds it — but is that process still alive?
		if pid, _ := readPID(path); !isAlive(pid) {
			os.Remove(path) // stale file from a crash; retry once
			return acquirePIDFile(path)
		}
		return nil, fmt.Errorf("already running (pidfile %s)", path)
	}
	if err != nil {
		return nil, err
	}
	fmt.Fprintf(f, "%d\n", os.Getpid())
	return f, nil // caller defers f.Close() + os.Remove(path)
}
```

A crash leaves a stale PID file, so the `EEXIST` branch must distinguish "another instance is genuinely running" from "leftover from a process that died" using a [signal-0 liveness check](state-signal-zero-liveness.md). For multi-writer coordination beyond start-up exclusion, prefer an advisory lock (`flock`) which the kernel releases automatically on process exit — no stale-file cleanup needed.

Reference: [pkg.go.dev — os.OpenFile](https://pkg.go.dev/os#OpenFile)
