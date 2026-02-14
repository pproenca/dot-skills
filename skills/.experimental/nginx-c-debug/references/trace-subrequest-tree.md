---
title: Map Subrequest Parent-Child Relationships for Debugging
impact: HIGH
impactDescription: untangles nested subrequest tree — SSI pages can create 10+ subrequests with non-obvious execution order
tags: trace, subrequest, parent, main-request
---

## Map Subrequest Parent-Child Relationships for Debugging

Subrequests create a tree rooted at `r->main`. Each subrequest has `r->parent` pointing to its creator and shares the same connection but uses separate pools, URIs, and phase handlers. When subrequests are nested (a subrequest spawns another subrequest), execution interleaving makes it nearly impossible to follow the flow without explicit identity logging. The key diagnostic is logging the request pointer value alongside `r->main`, `r->parent`, and `r->uri` at each processing point to reconstruct which request is active at any given moment.

**Incorrect (assuming subrequests execute synchronously, confusing request identity):**

```c
/*
 * Module that creates a subrequest and assumes it completes
 * before the parent handler continues — wrong mental model.
 */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_request_t  *sr;
    ngx_str_t            uri = ngx_string("/auth-check");
    ngx_int_t            rc;

    rc = ngx_http_subrequest(r, &uri, NULL, &sr, NULL,
                             NGX_HTTP_SUBREQUEST_WAITED);
    if (rc != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /*
     * BUG: developer assumes sr has already completed here
     * and checks sr->headers_out.status. In reality, sr has
     * only been queued — it hasn't started processing yet.
     */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "subrequest status: %ui",
                   sr->headers_out.status);

    /* BUG: checks r->main->uri thinking it reflects the
     * subrequest URI — it doesn't, r->main is always the
     * original request */
    if (r->main->uri.len == 0) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    return NGX_OK;
}
```

**Correct (logging request identity to trace the full subrequest tree):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_request_t    *sr;
    ngx_http_post_subrequest_t  *ps;
    ngx_str_t              uri = ngx_string("/auth-check");

    /*
     * Log request identity: is this the main request or a subrequest?
     * Include pointer addresses to distinguish requests in the log.
     */
    ngx_log_debug4(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule handler: r=%p, main=%p, parent=%p, "
                   "is_main=%d",
                   r, r->main, r->parent, (r == r->main));

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule handler: uri=\"%V\", count=%d",
                   &r->uri, r->main->count);

    /* only create subrequest from the main request */
    if (r != r->main) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: skipping, this is a subrequest");
        return NGX_DECLINED;
    }

    /* set up post-subrequest callback */
    ps = ngx_palloc(r->pool, sizeof(ngx_http_post_subrequest_t));
    if (ps == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }
    ps->handler = ngx_http_mymodule_subrequest_done;
    ps->data = r;

    if (ngx_http_subrequest(r, &uri, NULL, &sr, ps,
                            NGX_HTTP_SUBREQUEST_WAITED)
        != NGX_OK)
    {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ngx_log_debug3(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: created subrequest sr=%p, "
                   "sr->parent=%p, main->count=%d",
                   sr, sr->parent, r->main->count);

    /* return AGAIN — processing continues when subrequest completes */
    return NGX_AGAIN;
}

static ngx_int_t
ngx_http_mymodule_subrequest_done(ngx_http_request_t *r,
    void *data, ngx_int_t rc)
{
    ngx_http_request_t *parent = data;

    ngx_log_debug4(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: subrequest done r=%p, parent=%p, "
                   "status=%ui, rc=%i",
                   r, parent, r->headers_out.status, rc);

    /* safe: now check subrequest result in the callback */
    parent->headers_out.status = r->headers_out.status;

    return rc;
}

/*
 * Debug log output showing request tree:
 *
 *  mymodule handler: r=0x1e20400, main=0x1e20400, parent=(nil), is_main=1
 *  mymodule handler: uri="/original", count=1
 *  mymodule: created subrequest sr=0x1e21800, sr->parent=0x1e20400, count=2
 *  mymodule handler: r=0x1e21800, main=0x1e20400, parent=0x1e20400, is_main=0
 *  mymodule: skipping, this is a subrequest
 *  mymodule: subrequest done r=0x1e21800, parent=0x1e20400, status=200, rc=0
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
