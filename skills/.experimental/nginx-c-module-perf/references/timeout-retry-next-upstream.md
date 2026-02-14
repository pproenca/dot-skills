---
title: Configure next_upstream Mask for Retriable Failures
impact: MEDIUM
impactDescription: enables automatic failover for transient errors without retrying non-idempotent failures
tags: timeout, retry, upstream, failover
---

## Configure next_upstream Mask for Retriable Failures

The `next_upstream` bitmask on `ngx_http_upstream_conf_t` controls which failures trigger automatic retry on the next peer. The default (`NGX_HTTP_UPSTREAM_FT_ERROR | NGX_HTTP_UPSTREAM_FT_TIMEOUT`) retries on connection errors and timeouts, but a module that blindly adds `NGX_HTTP_UPSTREAM_FT_HTTP_500` or uses an overly broad mask will retry POST/PUT requests on 500 errors -- causing duplicate writes. Explicitly configure the mask to match your upstream's idempotency guarantees.

**Incorrect (retries all failures including non-idempotent operations):**

```c
static void *
ngx_http_myproxy_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_myproxy_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_myproxy_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* BUG: retries on every possible failure — a 500 on a POST that
     * already committed will be re-sent to the next upstream peer */
    conf->upstream.next_upstream = NGX_HTTP_UPSTREAM_FT_ERROR
                                 | NGX_HTTP_UPSTREAM_FT_TIMEOUT
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_500
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_502
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_503
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_504;

    conf->upstream.next_upstream_tries = 0;  /* unlimited retries */

    return conf;
}
```

**Correct (limits retries to safe, transient failures with bounded attempts):**

```c
static void *
ngx_http_myproxy_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_myproxy_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_myproxy_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->upstream.next_upstream = NGX_CONF_BITMASK_SET;
    conf->upstream.next_upstream_tries = NGX_CONF_UNSET_UINT;
    conf->upstream.next_upstream_timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_myproxy_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_myproxy_loc_conf_t  *prev = parent;
    ngx_http_myproxy_loc_conf_t  *conf = child;

    /* retry only on connection-level failures and 502/503 (peer down);
     * never retry on 500 (application error) or 504 (upstream timeout
     * that may have already committed a side effect) */
    ngx_conf_merge_bitmask_value(conf->upstream.next_upstream,
                                 prev->upstream.next_upstream,
                                 NGX_HTTP_UPSTREAM_FT_ERROR
                                 | NGX_HTTP_UPSTREAM_FT_TIMEOUT
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_502
                                 | NGX_HTTP_UPSTREAM_FT_HTTP_503);

    /* bound total retry attempts and cumulative retry time */
    ngx_conf_merge_uint_value(conf->upstream.next_upstream_tries,
                              prev->upstream.next_upstream_tries, 2);

    ngx_conf_merge_msec_value(conf->upstream.next_upstream_timeout,
                              prev->upstream.next_upstream_timeout, 10000);

    return NGX_CONF_OK;
}
```
