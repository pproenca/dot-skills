---
title: Guard Expensive Debug Argument Computation Behind Level Check
impact: LOW-MEDIUM
impactDescription: prevents 1-10us of wasted computation per debug call in hot paths
tags: log, debug, guard, performance
---

## Guard Expensive Debug Argument Computation Behind Level Check

The `ngx_log_debug` macros already check `log->log_level` before formatting — when debug is disabled, they short-circuit. However, the macro arguments are **evaluated before the macro call**. If an argument involves a function call or computation (formatting a complex struct, computing a hash, walking a list), that work executes unconditionally — even when the result is discarded. Wrap expensive argument computation in a level check so the work is skipped entirely when debug is disabled.

**Incorrect (expensive function call evaluated even when debug is disabled):**

```c
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl;

    for (cl = in; cl; cl = cl->next) {
        /* BAD: ngx_http_mymodule_dump_buf() runs on every buffer even
         * when debug is off — the macro short-circuits the format,
         * but the function call already happened (~5us per call) */
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                        "mymodule filter: %s",
                        ngx_http_mymodule_dump_buf(r->pool, cl->buf));
    }

    return ngx_http_next_body_filter(r, in);
}
```

**Correct (skips expensive computation when debug is disabled):**

```c
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl;
    ngx_log_t    *log;

    log = r->connection->log;

    for (cl = in; cl; cl = cl->next) {
        /* only compute the dump string when debug is actually enabled */
        if (log->log_level & NGX_LOG_DEBUG_HTTP) {
            ngx_log_debug1(NGX_LOG_DEBUG_HTTP, log, 0,
                            "mymodule filter: %s",
                            ngx_http_mymodule_dump_buf(r->pool, cl->buf));
        }
    }

    return ngx_http_next_body_filter(r, in);
}
```

**When NOT to use this pattern:**
- Simple scalar arguments (`%p`, `%uz`, `%d`) — the macro's built-in check is sufficient
- Outside hot paths — the overhead of a function call is negligible for infrequent debug logging
