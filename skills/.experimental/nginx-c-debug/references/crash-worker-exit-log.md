---
title: Extract Crash Context from Worker Exit Log Messages
impact: CRITICAL
impactDescription: provides crash location without coredump
tags: crash, worker, exit, error-log, signal
---

## Extract Crash Context from Worker Exit Log Messages

When a worker process crashes, the master process logs `worker process PID exited on signal N`. This message alone identifies the crash type (signal 11 = SIGSEGV, signal 6 = SIGABRT) but not the location. The critical technique is to correlate the exit signal with the last debug log entries written before the crash. These entries reveal the request URI, the processing phase, and the module active at crash time. Enabling `debug_connection` for the offending client IP captures a complete per-request trace without flooding the log for all traffic.

**Incorrect (looking only at the exit message and guessing the crash location):**

```c
/*
 * Error log shows only:
 *   2024/01/15 10:23:45 [alert] 1234#0: worker process 5678
 *                       exited on signal 11
 *
 * BAD approach: no debug logging enabled, no way to know
 * which request or module was active when the crash occurred.
 *
 * nginx.conf has only:
 */

/* error_log logs/error.log error; */

/*
 * At "error" level, nginx only logs severe errors.
 * The last lines before the crash show nothing about the
 * request being processed — the developer has no context
 * and must try to reproduce blindly.
 */
```

**Correct (correlating exit signal with targeted debug log entries to identify crash context):**

```c
/*
 * Step 1: Enable debug logging for the problem client only.
 *
 * nginx.conf:
 *   error_log logs/error.log error;
 *
 *   events {
 *       debug_connection 192.168.1.50;
 *   }
 *
 * Step 2: Reproduce the crash. The log now shows:
 *
 *   10:23:45 [debug] 5678#0: *42 http request "/api/data?"
 *   10:23:45 [debug] 5678#0: *42 rewrite phase: 0
 *   10:23:45 [debug] 5678#0: *42 access phase: 1
 *   10:23:45 [debug] 5678#0: *42 content phase: 2
 *   10:23:45 [debug] 5678#0: *42 http mymodule handler
 *   10:23:45 [debug] 5678#0: *42 mymodule: fetching ctx
 *   10:23:45 [alert] 1234#0: worker process 5678
 *                    exited on signal 11
 *
 * Step 3: The last debug entry before the crash tells us:
 *   - Request: /api/data (connection 42)
 *   - Phase: content phase
 *   - Module: mymodule, inside "fetching ctx" logic
 *   - Signal 11: SIGSEGV — likely NULL deref after get_ctx
 *
 * Step 4: Add targeted debug logging in the module:
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: handler entry, uri=\"%V\"", &r->uri);

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: ctx=%p", ctx);

    if (ctx == NULL) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "mymodule: NULL ctx for \"%V\"", &r->uri);
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: ctx->state=%d", ctx->state);

    return NGX_OK;
}
```

Reference: [Debugging nginx](https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/)
