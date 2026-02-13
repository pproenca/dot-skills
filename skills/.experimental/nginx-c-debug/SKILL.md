---
name: nginx-c-module-debugging
description: nginx C module debugging guidelines based on the official nginx development guide. This skill should be used when debugging nginx C module crashes, memory bugs, request flow issues, or production problems. Triggers on tasks involving segfault analysis, coredump debugging, GDB inspection, memory leak detection, request phase tracing, AddressSanitizer setup, or nginx module troubleshooting.
---

# nginx.org C Module Debugging Best Practices

Comprehensive debugging guide for nginx C modules, derived from the official nginx development documentation and production debugging experience. Contains 45 rules across 8 categories, prioritized by impact to guide systematic diagnosis of crashes, memory bugs, and behavioral issues in nginx modules.

**Companion skills**: This skill complements [nginx-c-module-best-practices](../nginx-c-modules/SKILL.md) (correctness) and [nginx-c-module-perf-reliability](../nginx-c-perf/SKILL.md) (performance). This skill covers **debugging and diagnosis**.

## When to Apply

Reference these guidelines when:
- Diagnosing nginx worker crashes (segfaults, SIGABRT, SIGSEGV)
- Finding memory bugs (use-after-free, leaks, pool corruption, buffer overruns)
- Setting up GDB and core dump analysis for nginx
- Tracing request flow through phases, subrequests, and filter chains
- Instrumenting nginx modules with debug logging and dynamic tracing tools

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Crash Diagnosis & Signals | CRITICAL | `crash-` |
| 2 | Memory Bug Detection | CRITICAL | `memdbg-` |
| 3 | GDB & Core Dump Analysis | HIGH | `gdb-` |
| 4 | Request Flow Tracing | HIGH | `trace-` |
| 5 | Debug Logging Patterns | MEDIUM-HIGH | `dbglog-` |
| 6 | State & Lifecycle Debugging | MEDIUM | `state-` |
| 7 | Dynamic Tracing Tools | MEDIUM | `probe-` |
| 8 | Build & Sanitizer Configuration | LOW-MEDIUM | `build-` |

## Quick Reference

### 1. Crash Diagnosis & Signals (CRITICAL)

- [`crash-segfault-signature`](references/crash-segfault-signature.md) - Identify Segfault Crash Signature from Signal and Address
- [`crash-null-deref-pattern`](references/crash-null-deref-pattern.md) - Recognize NULL Pointer Dereference Patterns in nginx Modules
- [`crash-double-free-finalize`](references/crash-double-free-finalize.md) - Diagnose Double Finalize Crashes from Request Reference Count
- [`crash-stack-overflow`](references/crash-stack-overflow.md) - Detect Stack Overflow from Recursive Subrequest or Filter Chains
- [`crash-worker-exit-log`](references/crash-worker-exit-log.md) - Extract Crash Context from Worker Exit Log Messages
- [`crash-error-page-redirect`](references/crash-error-page-redirect.md) - Avoid Crashes from error_page Internal Redirect Context Invalidation

### 2. Memory Bug Detection (CRITICAL)

- [`memdbg-use-after-free`](references/memdbg-use-after-free.md) - Detect Use-After-Free from Pool Destruction Timing
- [`memdbg-pool-leak-pattern`](references/memdbg-pool-leak-pattern.md) - Identify Pool Memory Leak Patterns from Growing Worker RSS
- [`memdbg-slab-corruption`](references/memdbg-slab-corruption.md) - Diagnose Shared Memory Slab Corruption from Multi-Worker Crashes
- [`memdbg-cleanup-handler-leak`](references/memdbg-cleanup-handler-leak.md) - Detect Resource Leaks from Missing Pool Cleanup Handlers
- [`memdbg-buffer-overrun`](references/memdbg-buffer-overrun.md) - Find Buffer Overrun from ngx_pnalloc Size Miscalculation
- [`memdbg-temp-pool-misuse`](references/memdbg-temp-pool-misuse.md) - Avoid Storing Long-Lived Pointers in Temporary Pools
- [`memdbg-valgrind-pool-trace`](references/memdbg-valgrind-pool-trace.md) - Use Valgrind Pool-Level Tracing to Find Leaked Allocations

### 3. GDB & Core Dump Analysis (HIGH)

- [`gdb-coredump-setup`](references/gdb-coredump-setup.md) - Configure Core Dump Generation for nginx Worker Crashes
- [`gdb-attach-worker`](references/gdb-attach-worker.md) - Attach GDB to a Running nginx Worker Process
- [`gdb-backtrace-read`](references/gdb-backtrace-read.md) - Read nginx Backtrace to Identify Crash Module and Phase
- [`gdb-inspect-request`](references/gdb-inspect-request.md) - Inspect ngx_http_request_t Fields in GDB for Request State
- [`gdb-memory-buffer-extract`](references/gdb-memory-buffer-extract.md) - Extract Debug Log from Memory Buffer Using GDB Script
- [`gdb-watchpoint-corruption`](references/gdb-watchpoint-corruption.md) - Use GDB Watchpoints to Catch Memory Corruption at Write Time

### 4. Request Flow Tracing (HIGH)

- [`trace-phase-handler-flow`](references/trace-phase-handler-flow.md) - Trace Request Through HTTP Phase Handlers
- [`trace-subrequest-tree`](references/trace-subrequest-tree.md) - Map Subrequest Parent-Child Relationships for Debugging
- [`trace-filter-chain-order`](references/trace-filter-chain-order.md) - Trace Filter Chain Execution Order and Data Flow
- [`trace-upstream-callback-seq`](references/trace-upstream-callback-seq.md) - Trace Upstream Callback Sequence for Proxy Debugging
- [`trace-event-handler-chain`](references/trace-event-handler-chain.md) - Trace Event Handler Execution for Connection Debugging
- [`trace-config-inheritance`](references/trace-config-inheritance.md) - Trace Configuration Inheritance Through Server and Location Blocks

### 5. Debug Logging Patterns (MEDIUM-HIGH)

- [`dbglog-debug-mask`](references/dbglog-debug-mask.md) - Use Correct Debug Mask for Targeted Log Filtering
- [`dbglog-debug-connection`](references/dbglog-debug-connection.md) - Use debug_connection to Isolate Single-Client Debug Output
- [`dbglog-memory-buffer`](references/dbglog-memory-buffer.md) - Use Memory Buffer Logging to Capture Debug Output Without Disk I/O
- [`dbglog-log-action-string`](references/dbglog-log-action-string.md) - Set Log Action String for Context in Error Messages
- [`dbglog-format-ngx-str`](references/dbglog-format-ngx-str.md) - Format ngx_str_t Correctly in Debug Log Messages

### 6. State & Lifecycle Debugging (MEDIUM)

- [`state-connection-lifecycle`](references/state-connection-lifecycle.md) - Track Connection State Transitions for Lifecycle Debugging
- [`state-upstream-state-machine`](references/state-upstream-state-machine.md) - Debug Upstream Module State by Logging Transition Points
- [`state-timer-leak`](references/state-timer-leak.md) - Detect Timer Leaks from Events Not Removed Before Pool Destruction
- [`state-event-flag-debug`](references/state-event-flag-debug.md) - Inspect Event Flags to Debug Unexpected Handler Invocation
- [`state-request-count-track`](references/state-request-count-track.md) - Track Request Reference Count to Debug Premature Destruction

### 7. Dynamic Tracing Tools (MEDIUM)

- [`probe-strace-syscall`](references/probe-strace-syscall.md) - Use strace to Trace System Call Patterns in nginx Workers
- [`probe-dtrace-request`](references/probe-dtrace-request.md) - Trace Request Processing with DTrace pid Provider
- [`probe-systemtap-pool`](references/probe-systemtap-pool.md) - Trace Memory Pool Allocations with SystemTap
- [`probe-ebpf-latency`](references/probe-ebpf-latency.md) - Measure Per-Function Latency with eBPF Probes
- [`probe-strace-fd-leak`](references/probe-strace-fd-leak.md) - Detect File Descriptor Leaks with strace and /proc

### 8. Build & Sanitizer Configuration (LOW-MEDIUM)

- [`build-debug-flags`](references/build-debug-flags.md) - Compile nginx with Full Debug Symbols and No Optimization
- [`build-asan-configure`](references/build-asan-configure.md) - Build nginx with AddressSanitizer for Memory Error Detection
- [`build-single-process`](references/build-single-process.md) - Use Single-Process Mode for Simplified Debugging
- [`build-valgrind-suppressions`](references/build-valgrind-suppressions.md) - Use nginx Valgrind Suppressions to Reduce False Positives
- [`build-debug-palloc`](references/build-debug-palloc.md) - Enable NGX_DEBUG_PALLOC for Fine-Grained Pool Allocation Tracking

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
