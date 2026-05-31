# Go

**Version 0.1.0**  
dot-skills  
May 2026

---

## Abstract

Distilled patterns for Go CLIs that manage processes and concurrent workloads — daemons, supervisors, job runners, deploy tools. Targets Go 1.22+ on Unix-like systems and corrects the specific standard-library defaults that go wrong in this domain: catching SIGTERM (not just Ctrl-C) via signal.NotifyContext, killing children gracefully with exec.Cmd Cancel/WaitDelay before SIGKILL, signalling whole process groups so grandchildren don't orphan, avoiding os/exec pipe deadlocks, bounding concurrency with errgroup so a goroutine-per-task doesn't become a process-per-task, threading context for cancellation, funnelling exit through run() error so defers run, choosing stdlib flag vs cobra and wiring ExecuteContext, and supervising state (signal-0 liveness, atomic PID files, zombie reaping, structured slog). Each rule names the wrong default it corrects, shows one canonical example, and cites the primary source.

---

## Table of Contents

1. [Signals & Graceful Shutdown](references/_sections.md#1-signals-&-graceful-shutdown)
   - 1.1 [Bind a context to SIGINT and SIGTERM with signal.NotifyContext](references/sig-notify-context-for-shutdown.md)
   - 1.2 [Let a second signal force-quit a wedged shutdown](references/sig-second-signal-force-quit.md)
2. [Child Processes](references/_sections.md#2-child-processes)
   - 2.1 [Cancel a child with SIGTERM before SIGKILL using Cancel and WaitDelay](references/exec-cancel-sigterm-before-kill.md)
   - 2.2 [Capture child output with Output, not a pipe you read after Wait](references/exec-pipes-without-deadlock.md)
   - 2.3 [Kill the process group, not just the direct child](references/exec-kill-process-group.md)
   - 2.4 [Read the child's real exit code from exec.ExitError](references/exec-exit-code-from-exiterror.md)
   - 2.5 [Use exec.CommandContext so a child dies with its context](references/exec-commandcontext-binds-lifetime.md)
3. [Concurrency & Workloads](references/_sections.md#3-concurrency-&-workloads)
   - 3.1 [Bound concurrency instead of one goroutine per task](references/work-bound-concurrency.md)
   - 3.2 [Give every goroutine a cancellation path so it cannot leak](references/work-every-goroutine-has-exit.md)
   - 3.3 [Only the sender closes a channel, exactly once](references/work-sender-closes-channel.md)
   - 3.4 [Use errgroup for fan-out with cancel-on-first-error](references/work-errgroup-fan-out.md)
4. [Context Propagation](references/_sections.md#4-context-propagation)
   - 4.1 [Always defer cancel() from WithCancel, WithTimeout, and WithDeadline](references/ctx-defer-cancel.md)
   - 4.2 [Make blocking waits cancellable instead of time.Sleep](references/ctx-cancellable-wait.md)
   - 4.3 [Pass context as an explicit argument, never store it in a struct](references/ctx-explicit-argument.md)
5. [Errors & Exit Codes](references/_sections.md#5-errors-&-exit-codes)
   - 5.1 [Aggregate failures across workloads with errors.Join](references/err-join-aggregate-workloads.md)
   - 5.2 [Funnel main through a run() error so deferred cleanup runs](references/err-run-function-for-deferred-cleanup.md)
6. [CLI Framework & Flags](references/_sections.md#6-cli-framework-&-flags)
   - 6.1 [Choose stdlib flag or cobra by the command surface, not by habit](references/cli-flag-vs-cobra-by-shape.md)
   - 6.2 [Return errors from RunE; never os.Exit inside a command](references/cli-rune-return-errors.md)
   - 6.3 [Use a FlagSet per subcommand when staying on the stdlib](references/cli-stdlib-subcommand-pattern.md)
   - 6.4 [Wire the signal-bound context into cobra with ExecuteContext](references/cli-execute-context-wires-signals.md)
7. [Process State & Supervision](references/_sections.md#7-process-state-&-supervision)
   - 7.1 [Create the PID or lock file atomically with O_CREATE and O_EXCL](references/state-atomic-pidfile.md)
   - 7.2 [Log process-state transitions as structured slog records](references/state-structured-slog-transitions.md)
   - 7.3 [Probe liveness with signal 0 — os.FindProcess lies on Unix](references/state-signal-zero-liveness.md)
   - 7.4 [Wait on every child you start so it doesn't become a zombie](references/state-reap-children-wait.md)

---

## References

1. [https://pkg.go.dev/os/signal#NotifyContext](https://pkg.go.dev/os/signal#NotifyContext)
2. [https://pkg.go.dev/os/exec](https://pkg.go.dev/os/exec)
3. [https://pkg.go.dev/golang.org/x/sync/errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup)
4. [https://pkg.go.dev/context](https://pkg.go.dev/context)
5. [https://pkg.go.dev/log/slog](https://pkg.go.dev/log/slog)
6. [https://go.dev/blog/pipelines](https://go.dev/blog/pipelines)
7. [https://cobra.dev/](https://cobra.dev/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |