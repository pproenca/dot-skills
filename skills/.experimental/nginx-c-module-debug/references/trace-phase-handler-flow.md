---
title: Trace Request Through HTTP Phase Handlers
impact: HIGH
impactDescription: maps request flow through 11 HTTP phases — identifies which phase skips or misroutes the request
tags: trace, phase, handler, request-flow
---

## Trace Request Through HTTP Phase Handlers

nginx processes each HTTP request through a fixed sequence of 11 phases: POST_READ, SERVER_REWRITE, FIND_CONFIG, REWRITE, POST_REWRITE, PREACCESS, ACCESS, POST_ACCESS, PRECONTENT, CONTENT, and LOG. A module's handler registers in one specific phase and returns a code that determines the phase engine's routing decision. Without tracing the phase index and return code, you cannot tell whether your handler was skipped, ran in the wrong phase, or returned a code that short-circuited subsequent handlers.

**Incorrect (logging only inside the module handler, missing surrounding phase context):**

```c
/*
 * Handler registered in the ACCESS phase.
 * Only logs when it runs — no visibility into phases
 * that ran before/after, or why this handler was skipped.
 */
static ngx_int_t
ngx_http_mymodule_access_handler(ngx_http_request_t *r)
{
    my_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* Only log here — if this handler is never reached,
     * there is zero debug output */
    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: access handler called");

    if (!conf->enable) {
        return NGX_DECLINED;
    }

    /*
     * BUG: returns NGX_OK thinking it means "success."
     * In an ACCESS phase checker, NGX_OK tells the phase
     * engine to skip remaining access handlers AND proceed.
     * But the developer wanted NGX_DECLINED to let other
     * access handlers run. No phase tracing = no clue.
     */
    return NGX_OK;
}
```

**Correct (tracing phase index and return code to map the full flow):**

```c
static ngx_int_t
ngx_http_mymodule_access_handler(ngx_http_request_t *r)
{
    my_conf_t  *conf;
    ngx_int_t   rc;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /*
     * Log the phase handler index at entry — this shows exactly
     * where in the handler array this handler sits and whether
     * it runs in the expected order relative to other modules.
     */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: access handler ENTER, "
                   "phase_handler=%ui, uri=\"%V\"",
                   r->phase_handler, &r->uri);

    if (!conf->enable) {
        rc = NGX_DECLINED;

        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: access handler EXIT rc=%i "
                       "(DECLINED, module disabled)", rc);
        return rc;
    }

    rc = validate_request(r, conf);

    /*
     * Log the return code with its meaning for the phase engine:
     *   NGX_OK       — access granted, skip remaining access handlers
     *   NGX_DECLINED — pass to next handler in this phase
     *   NGX_AGAIN    — pause, wait for async completion
     *   NGX_HTTP_FORBIDDEN — deny access immediately
     */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: access handler EXIT rc=%i, "
                   "phase_handler=%ui",
                   rc, r->phase_handler);

    return rc;
}

/*
 * Debug log output with phase tracing:
 *
 *  [debug] *1 rewrite phase: 2
 *  [debug] *1 http script regex: "/api/(.*)"
 *  [debug] *1 mymodule: access handler ENTER, phase_handler=7, uri="/api/data"
 *  [debug] *1 mymodule: access handler EXIT rc=-5, phase_handler=7
 *  [debug] *1 access phase: 8
 *  [debug] *1 access phase: 9
 *  [debug] *1 content phase: 11
 *
 *  The trace shows handler 7 returned -5 (NGX_DECLINED), so the
 *  phase engine moved to handler 8. Full flow is visible.
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
