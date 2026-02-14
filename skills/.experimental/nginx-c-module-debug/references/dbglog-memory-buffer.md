---
title: Use Memory Buffer Logging to Capture Debug Output Without Disk I/O
impact: MEDIUM-HIGH
impactDescription: captures debug log with <1% performance overhead
tags: dbglog, memory-buffer, cyclic-buffer, performance
---

## Use Memory Buffer Logging to Capture Debug Output Without Disk I/O

Writing debug logs to disk introduces significant I/O overhead and can change timing behavior, hiding race conditions and making Heisenbugs disappear. Memory buffer logging (`error_log memory:SIZE debug`) writes to a cyclic in-memory buffer with negligible overhead. The buffer wraps around when full, always retaining the most recent messages. Extract the buffer content via GDB after a crash or on-demand from a running process. This is the preferred approach for debugging timing-sensitive issues.

**Incorrect (using file-based debug logging when investigating timing-sensitive bugs):**

```c
/*
 * Scenario: intermittent race condition between upstream
 * response handling and client disconnect. Happens once
 * every ~10,000 requests under load.
 *
 * nginx.conf:
 *   error_log /var/log/nginx/debug.log debug;
 *
 * Problem: disk I/O from debug logging adds 50-200μs per
 * log line. Under load, this changes the timing enough
 * that the race condition never triggers. You're debugging
 * for hours with debug enabled but the bug vanishes.
 *
 * Additional problems:
 * - Debug log grows at 500MB+/min under load
 * - write() syscalls contend with sendfile() for I/O bandwidth
 * - Log rotation under debug load risks losing the crash trace
 */

static void
ngx_http_mymodule_upstream_read(ngx_http_request_t *r)
{
    /* These debug calls each trigger a write() syscall */
    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: upstream read handler entered");

    /* The I/O delay from the debug log above changes the
     * window between this check and the actual read below,
     * preventing the race from occurring */
    if (r->connection->error) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: client already disconnected");
        return;
    }

    /* ... rest of handler ... */
}
```

**Correct (using memory buffer logging to preserve timing while capturing debug output):**

```nginx
# nginx.conf — memory buffer logging (no disk I/O)
# The cyclic buffer keeps the most recent 32MB of debug output.
# Overhead is a memcpy to the buffer — no syscalls, no disk.
error_log memory:32m debug;
```

```bash
# Extract the memory buffer from a running or crashed process
# using GDB. The buffer is stored in log->wdata (set by
# ngx_log_memory_writer during initialization).

# Method 1: Attach to running worker and dump buffer
$ gdb -batch -p $(pgrep -f 'nginx: worker') \
    -ex 'set $log = ngx_cycle->log' \
    -ex 'while $log && $log->writer != ngx_log_memory_writer' \
    -ex 'set $log = $log->next' \
    -ex 'end' \
    -ex 'set $buf = (ngx_log_memory_buf_t *) $log->wdata' \
    -ex 'dump binary memory /tmp/nginx-debug.log $buf->start $buf->end'

# Method 2: From a core dump after a crash
$ gdb /usr/local/nginx/sbin/nginx /tmp/core.12345
(gdb) set $log = ngx_cycle->log
(gdb) while $log && $log->writer != ngx_log_memory_writer
 > set $log = $log->next
 > end
(gdb) set $buf = (ngx_log_memory_buf_t *) $log->wdata
(gdb) dump binary memory /tmp/crash-debug.log $buf->start $buf->end
(gdb) quit

# View the extracted log (may contain binary zeros at the
# wrap point — filter with tr or strings)
$ strings /tmp/crash-debug.log | tail -500
```

Reference: [nginx Debugging Log — Logging to a Cyclic Memory Buffer](https://nginx.org/en/docs/debugging_log.html#memory)
