---
name: nginx-c-module-perf-reliability
description: nginx C module performance optimization and reliability guidelines based on the official nginx development guide. This skill should be used when optimizing nginx C modules for throughput, latency, memory efficiency, and operational resilience. Triggers on tasks involving buffer optimization, connection tuning, shared memory contention, error recovery, timeout strategy, caching implementation, worker process tuning, or logging performance in nginx C modules.
---

# nginx.org C Module Performance & Reliability Best Practices

Comprehensive performance optimization and reliability guide for nginx C modules, derived from the official nginx development documentation and production engineering experience. Contains 43 rules across 8 categories, prioritized by impact to guide automated optimization and resilience improvements.

**Companion skill**: This skill complements [nginx-c-module-best-practices](../nginx-c-modules/SKILL.md) which covers correctness (memory safety, request lifecycle, configuration). This skill covers **performance optimization and operational reliability**.

## When to Apply

Reference these guidelines when:
- Optimizing nginx C module throughput and latency
- Reducing buffer copies and enabling zero-copy I/O paths
- Tuning connection pooling and socket options
- Minimizing shared memory lock contention across workers
- Implementing graceful error recovery and fallback responses
- Configuring upstream timeouts and retry strategies
- Building in-module response caches with shared memory
- Tuning worker process behavior under load

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Buffer & Zero-Copy I/O | CRITICAL | `buf-` |
| 2 | Connection Efficiency | CRITICAL | `conn-` |
| 3 | Lock Contention & Atomics | HIGH | `lock-` |
| 4 | Error Recovery & Resilience | HIGH | `err-` |
| 5 | Timeout & Retry Strategy | MEDIUM-HIGH | `timeout-` |
| 6 | Response Caching | MEDIUM | `cache-` |
| 7 | Worker & Process Tuning | MEDIUM | `worker-` |
| 8 | Logging & Metrics | LOW-MEDIUM | `log-` |

## Quick Reference

### 1. Buffer & Zero-Copy I/O (CRITICAL)

- [`buf-chain-reuse`](references/buf-chain-reuse.md) - Reuse Buffer Chain Links Instead of Allocating New Ones
- [`buf-file-sendfile`](references/buf-file-sendfile.md) - Use File Buffers for Static Content Instead of Reading into Memory
- [`buf-avoid-copy`](references/buf-avoid-copy.md) - Avoid Copying Buffers When Passing Through Filter Chain
- [`buf-coalesce-small`](references/buf-coalesce-small.md) - Coalesce Small Buffers Before Output
- [`buf-shadow-reference`](references/buf-shadow-reference.md) - Use Shadow Buffers for Derived Data Instead of Full Copies
- [`buf-recycled-flag`](references/buf-recycled-flag.md) - Mark Buffers as Recycled for Upstream Response Reuse

### 2. Connection Efficiency (CRITICAL)

- [`conn-reusable-queue`](references/conn-reusable-queue.md) - Mark Idle Connections as Reusable for Pool Recovery
- [`conn-drain-pressure`](references/conn-drain-pressure.md) - Handle Connection Drain Under Memory Pressure
- [`conn-tcp-nodelay`](references/conn-tcp-nodelay.md) - Control TCP_NODELAY for Latency-Sensitive Responses
- [`conn-prealloc-pool`](references/conn-prealloc-pool.md) - Size Connection Pool to Avoid Runtime Reallocation
- [`conn-close-linger`](references/conn-close-linger.md) - Use Lingering Close for Graceful Connection Shutdown
- [`conn-ssl-session-reuse`](references/conn-ssl-session-reuse.md) - Enable SSL Session Caching in Upstream Connections

### 3. Lock Contention & Atomics (HIGH)

- [`lock-minimize-critical`](references/lock-minimize-critical.md) - Minimize Critical Section Duration in Shared Memory
- [`lock-atomic-counters`](references/lock-atomic-counters.md) - Use Atomic Operations for Simple Counters Instead of Mutex
- [`lock-trylock-fallback`](references/lock-trylock-fallback.md) - Use ngx_shmtx_trylock with Fallback to Avoid Worker Stalls
- [`lock-per-worker-aggregate`](references/lock-per-worker-aggregate.md) - Aggregate Per-Worker Counters to Reduce Shared Memory Access
- [`lock-alloc-outside`](references/lock-alloc-outside.md) - Perform Slab Allocation Outside Hot Path
- [`lock-rw-pattern`](references/lock-rw-pattern.md) - Use Read-Copy-Update Pattern for Read-Heavy Shared Data

### 4. Error Recovery & Resilience (HIGH)

- [`err-cache-errno`](references/err-cache-errno.md) - Cache ngx_errno Immediately to Prevent Overwrite
- [`err-fallback-response`](references/err-fallback-response.md) - Return Fallback Response When Upstream Fails
- [`err-resource-exhaustion`](references/err-resource-exhaustion.md) - Handle Pool and Slab Allocation Exhaustion Gracefully
- [`err-blocked-counter`](references/err-blocked-counter.md) - Use Blocked Counter to Prevent Premature Request Destruction
- [`err-connection-error-check`](references/err-connection-error-check.md) - Check Connection Error Flag Before I/O Operations
- [`err-log-once-pattern`](references/err-log-once-pattern.md) - Limit Repeated Error Logging to Prevent Log Storms

### 5. Timeout & Retry Strategy (MEDIUM-HIGH)

- [`timeout-upstream-phases`](references/timeout-upstream-phases.md) - Set Separate Timeouts for Connect, Send, and Read Phases
- [`timeout-retry-next-upstream`](references/timeout-retry-next-upstream.md) - Configure next_upstream Mask for Retriable Failures
- [`timeout-backoff-reconnect`](references/timeout-backoff-reconnect.md) - Use Exponential Backoff for Upstream Reconnection Attempts
- [`timeout-client-body-limit`](references/timeout-client-body-limit.md) - Set Client Body Timeout to Bound Slow-Client Resource Usage

### 6. Response Caching (MEDIUM)

- [`cache-shm-lru`](references/cache-shm-lru.md) - Implement LRU Eviction in Shared Memory Cache Zones
- [`cache-stampede-lock`](references/cache-stampede-lock.md) - Prevent Cache Stampede with Single-Flight Pattern
- [`cache-key-hash`](references/cache-key-hash.md) - Use ngx_hash for Fixed Cache Key Lookups
- [`cache-ttl-atomic`](references/cache-ttl-atomic.md) - Use Atomic Timestamp Comparison for TTL Expiry Checks
- [`cache-conditional-store`](references/cache-conditional-store.md) - Cache Only Successful Responses to Avoid Negative Cache Pollution

### 7. Worker & Process Tuning (MEDIUM)

- [`worker-accept-mutex`](references/worker-accept-mutex.md) - Understand Accept Mutex Impact on Connection Distribution
- [`worker-connection-prealloc`](references/worker-connection-prealloc.md) - Use Pre-Allocated Free List for Module Data Structures
- [`worker-graceful-shutdown`](references/worker-graceful-shutdown.md) - Handle Worker Shutdown Signal Without Data Loss
- [`worker-single-process-debug`](references/worker-single-process-debug.md) - Support Single-Process Mode for Debugging
- [`worker-cycle-conf`](references/worker-cycle-conf.md) - Access Configuration Through Cycle for Process-Level Operations

### 8. Logging & Metrics (LOW-MEDIUM)

- [`log-level-guard`](references/log-level-guard.md) - Guard Expensive Debug Argument Computation Behind Level Check
- [`log-connection-context`](references/log-connection-context.md) - Attach Module Context to Connection Log for Tracing
- [`log-shared-metrics`](references/log-shared-metrics.md) - Collect Metrics via Shared Memory Counters
- [`log-error-dedup`](references/log-error-dedup.md) - Deduplicate Repeated Error Messages with Throttling
- [`log-action-string`](references/log-action-string.md) - Set Log Action String for Operation Context

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
