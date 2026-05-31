# Sections

This document defines the category structure and file-name prefixes used by every rule in `references/`. Categories are ordered by importance × frequency — the decisions a process-management CLI gets wrong most often, and most expensively, come first. These rules target **Go 1.22+** on **Unix-like systems** (Linux, macOS); Windows process semantics differ where noted.

## 1. Signals & Graceful Shutdown (sig)

**Description:** How the CLI process reacts to termination requests. Binding a `context.Context` to OS signals, catching `SIGTERM` (not just Ctrl-C) so orchestrators can stop the process cleanly, and letting a second signal force-quit a wedged shutdown. This is the signature correctness concern for any long-running or supervising CLI.

## 2. Child Processes (exec)

**Description:** Spawning and supervising external processes with `os/exec`. Tying a child's lifetime to a context, terminating it gracefully before SIGKILL, killing the whole process group so grandchildren don't orphan, reading its output without deadlock, and extracting its exit code. The most footgun-dense area of the standard library for this domain.

## 3. Concurrency & Workloads (work)

**Description:** Running concurrent work safely. Using `errgroup` for fan-out with cancel-on-first-error, bounding concurrency instead of spawning a goroutine per task, giving every goroutine a cancellation path so it cannot leak, and respecting channel ownership so a close never panics.

## 4. Context Propagation (ctx)

**Description:** Threading cancellation through the program. Passing `context.Context` as an explicit argument rather than storing it, releasing the resources a derived context holds, and making blocking waits cancellable so shutdown is responsive instead of hanging on a `time.Sleep`.

## 5. Errors & Exit Codes (err)

**Description:** Turning failures into clean process exits. Funnelling all paths through a `run() error` so deferred cleanup actually runs, and aggregating failures across many workloads instead of surfacing only the first.

## 6. CLI Framework & Flags (cli)

**Description:** Structuring the command-line surface. Choosing stdlib `flag` versus cobra by the shape of the tool, wiring the signal-bound context into a cobra command tree via `ExecuteContext`, returning errors from `RunE` instead of exiting inside a command, and the canonical stdlib subcommand pattern for when a framework is overkill.

## 7. Process State & Supervision (state)

**Description:** Observing and tracking processes. Probing real liveness (`os.FindProcess` lies on Unix), creating PID/lock files atomically to prevent two instances racing, reaping children so they don't become zombies, and logging state transitions as structured `slog` records a supervisor can parse.
