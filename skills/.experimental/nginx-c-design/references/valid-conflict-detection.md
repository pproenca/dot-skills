---
title: Detect Conflicting Directives at Merge Time
impact: MEDIUM
impactDescription: prevents runtime logic errors from mutually exclusive settings
tags: valid, conflict, merge, mutually-exclusive
---

## Detect Conflicting Directives at Merge Time

Some directives are mutually exclusive (e.g., you cannot enable both caching and pass-through). Detect these conflicts in `merge_loc_conf` and emit a clear error. If left undetected, the runtime behavior depends on which code path runs first — a race condition in configuration that produces intermittent, hard-to-debug failures.

**Incorrect (silently accepts conflicting directives — undefined runtime behavior):**

```c
static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_value(conf->cache, prev->cache, 0);
    ngx_conf_merge_value(conf->pass_through, prev->pass_through, 0);

    /* BUG: both cache and pass_through can be "on" at the same time —
     * handler checks cache first on some requests, pass_through first
     * on others depending on internal state, producing inconsistent
     * behavior that is nearly impossible to reproduce */

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);

    return NGX_CONF_OK;
}
```

**Correct (detects the conflict at merge time — admin sees clear error during nginx -t):**

```c
static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_value(conf->cache, prev->cache, 0);
    ngx_conf_merge_value(conf->pass_through, prev->pass_through, 0);

    /* detect mutually exclusive directives before any request is served */
    if (conf->cache && conf->pass_through) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"mymod_cache\" and \"mymod_pass_through\" are "
                           "mutually exclusive — disable one of them");
        return NGX_CONF_ERROR;
    }

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);

    return NGX_CONF_OK;
}
```
