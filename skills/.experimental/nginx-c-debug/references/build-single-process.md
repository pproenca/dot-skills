---
title: Use Single-Process Mode for Simplified Debugging
impact: LOW-MEDIUM
impactDescription: eliminates master/worker split — 1 process to attach GDB to instead of N workers
tags: build, single-process, master-off, debugging
---

## Use Single-Process Mode for Simplified Debugging

Multi-process nginx makes debugging harder: you must identify the right worker, attach GDB to it, and signals from the master can interfere. Set `master_process off;` and `worker_processes 1;` in nginx.conf to run everything in a single process. GDB attaches directly, breakpoints work without race conditions, and there is no master process sending signals.

**Incorrect (debugging with default multi-worker config, must chase PIDs and signals):**

```c
/*
 * nginx.conf — default multi-process configuration.
 *
 * worker_processes auto;   (spawns N workers)
 * daemon on;               (backgrounds the process)
 *
 * Debugging this requires multiple steps:
 *
 * Step 1: find the correct worker PID
 *   $ ps aux | grep 'nginx: worker'
 *   www-data 4827 ... nginx: worker process
 *   www-data 4828 ... nginx: worker process
 *   www-data 4829 ... nginx: worker process
 *   www-data 4830 ... nginx: worker process
 *   (which one handles your test request?)
 *
 * Step 2: attach GDB to one worker
 *   $ sudo gdb -p 4827
 *   (gdb) break ngx_http_mymodule_handler
 *   (gdb) continue
 *   (request hits worker 4829 instead — wrong PID)
 *
 * Step 3: master sends SIGCHLD/SIGALRM that interrupts GDB
 *   Program received signal SIGCHLD, Child exited.
 *   (gdb) continue
 *   Program received signal SIGALRM, Alarm clock.
 *   (gdb) continue
 *   (constant signal interruptions break debugging flow)
 *
 * Step 4: if you set follow-fork-mode child, GDB
 *   detaches from master and may miss the fork entirely.
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    /* breakpoint never triggers because request goes
     * to a different worker process */
    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: handler entry");

    return NGX_DECLINED;
}
```

**Correct (single-process mode for direct GDB attachment):**

```c
/*
 * nginx.conf — single-process debug configuration:
 *
 * master_process off;      # no master: single process only
 * worker_processes 1;      # one worker (redundant but explicit)
 * daemon off;              # stay in foreground for GDB/valgrind
 * error_log /dev/stderr debug;  # debug log to terminal
 *
 * events {
 *     worker_connections 64;   # low limit is fine for debugging
 * }
 *
 * http {
 *     access_log off;         # reduce noise during debug sessions
 *     server {
 *         listen 8080;
 *         location /test {
 *             mymodule;
 *         }
 *     }
 * }
 *
 * Launch under GDB directly — no PID hunting, no signal noise:
 *
 *   $ gdb --args ./objs/nginx -c /path/to/debug.conf
 *   (gdb) break ngx_http_mymodule_handler
 *   (gdb) run
 *   (every request hits this single process)
 *
 * Or launch under Valgrind:
 *
 *   $ valgrind --leak-check=full \
 *       ./objs/nginx -c /path/to/debug.conf
 *   (all allocations tracked in one process)
 *
 * Or launch under ASan (just run the ASan-compiled binary):
 *
 *   $ ASAN_OPTIONS="abort_on_error=1" \
 *       ./objs/nginx -c /path/to/debug.conf
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    /* breakpoint always triggers — single process handles all requests */
    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: handler entry");

    return NGX_DECLINED;
}
```

Reference: [nginx Debugging Guide](https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/)
