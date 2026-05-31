---
name: go-process-cli
description: Write Go CLIs that manage processes and workloads — daemons, supervisors, job runners, deploy tools, anything that spawns or controls other processes. Use when writing, reviewing, or refactoring Go that handles OS signals, runs children via os/exec, fans out concurrent work, threads context for cancellation, returns exit codes, or builds a flag/cobra command surface. Covers the footguns the standard library makes easy to hit — SIGTERM vs Ctrl-C, SIGKILL-by-default children, orphaned process groups, pipe deadlocks, goroutine leaks, zombie reaping, and os.FindProcess lying about liveness. Triggers whenever the task touches process lifecycle, graceful shutdown, subprocess control, or concurrent workload supervision in Go — even if not named.
---

# Go Process-Management CLIs

> Make Go command-line tools that spawn, supervise, and shut down processes correctly — the part the stdlib makes easy to get subtly wrong.

## When to Apply

Reach for this skill when building or reviewing a Go CLI whose job is to *control other processes or concurrent workloads*: a daemon, a process supervisor, a job/worker runner, a deploy or migration tool, a test harness that shells out, or any program that must stop cleanly when an orchestrator says so. It targets **Go 1.22+** on **Unix-like systems** (Linux, macOS); a few rules note where Windows differs. It assumes you already know Go — it only corrects the specific defaults that go wrong in this domain.

## Categories

| # | Category | Prefix | What it covers |
|---|----------|--------|----------------|
| 1 | Signals & Graceful Shutdown | `sig` | Binding a context to SIGINT/SIGTERM; second-signal force-quit |
| 2 | Child Processes | `exec` | `os/exec` lifetime, graceful kill, process groups, pipes, exit codes |
| 3 | Concurrency & Workloads | `work` | errgroup fan-out, bounded concurrency, goroutine-leak discipline, channel ownership |
| 4 | Context Propagation | `ctx` | Explicit context args, `defer cancel()`, cancellable waits |
| 5 | Errors & Exit Codes | `err` | `run() error` for deferred cleanup, aggregating failures |
| 6 | CLI Framework & Flags | `cli` | stdlib `flag` vs cobra, `ExecuteContext`, `RunE`, subcommand patterns |
| 7 | Process State & Supervision | `state` | Liveness probes, atomic PID files, zombie reaping, structured logs |

## Quick Reference

The defaults this skill exists to correct:

- **`signal.NotifyContext(ctx, SIGINT, SIGTERM)`** — not a channel that only watches Ctrl-C. Orchestrators send SIGTERM.
- **`exec.CommandContext` + `cmd.Cancel`/`cmd.WaitDelay`** — plain `CommandContext` SIGKILLs children with no cleanup.
- **`Setpgid` + `kill(-pgid)`** — signalling the direct child orphans grandchildren (`sh -c`, `make`, `npm`).
- **`cmd.Output()`** for capture — reading a pipe after `Wait()` deadlocks.
- **`errgroup.WithContext` + `SetLimit(n)`** — a goroutine per task means a *process* per task: PID/FD exhaustion.
- **`ctx` as an argument** — never a struct field; **`defer cancel()`** on every derived context.
- **`select { case <-ticker.C: case <-ctx.Done(): }`** — `time.Sleep` makes shutdown wait out the interval.
- **`main → run() error → os.Exit(1)`** — `log.Fatal`/`os.Exit` deep in code skip every `defer`.
- **`proc.Signal(syscall.Signal(0))`** — `os.FindProcess` always succeeds on Unix; it never proves liveness.
- **`os.OpenFile(O_CREATE|O_EXCL)`** for PID files — check-then-create is a race; **`cmd.Wait()`** every child or it zombifies.

## How to Use

1. Identify which category your task falls under (see table above).
2. Read the relevant rule files in `references/` — each is a focused, self-contained pattern naming the wrong default it corrects.
3. Apply the pattern; follow the `Reference` link in each rule for the authoritative source.

Rules cross-link (e.g. graceful shutdown ties signals → context → child-process kill → cleanup), so follow the links when a task spans categories.

When extending this skill, copy `assets/templates/_template.md`: WHY first, one canonical example with realistic names, a foil only if the wrong way is a genuine trap.

## Source Authority

Every rule cites primary sources — the Go standard library reference on pkg.go.dev, the official Go blog (go.dev/blog), and the cobra documentation — chosen because they are maintainer-authored and version-current. No content farms, listicles, or undated tutorials.

## Related Skills

- `radical-simplification` — when a supervisor design has accreted accidental complexity.
- `unix-cli` / `cli-for-agents` — broader CLI ergonomics beyond process management.
