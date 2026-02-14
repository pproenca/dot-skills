---
title: Trace Configuration Inheritance Through Server and Location Blocks
impact: HIGH
impactDescription: finds silent config merge bugs — 3-level inheritance (http/server/location) masks 80%+ of merge errors
tags: trace, configuration, merge, inheritance
---

## Trace Configuration Inheritance Through Server and Location Blocks

Configuration values cascade from http to server to location through merge callbacks (`merge_loc_conf`, `merge_srv_conf`). When a directive appears to have no effect, the root cause is almost always a merge bug. The most common mistake is initializing a field to `0` instead of `NGX_CONF_UNSET` (or `NGX_CONF_UNSET_PTR` for pointers), which causes the merge callback to interpret the zero value as an explicit user setting and skip inheriting the parent's value. Without tracing, this produces silently wrong configuration that is extremely difficult to diagnose.

**Incorrect (field initialized to 0 instead of NGX_CONF_UNSET, merge silently fails):**

```c
/*
 * nginx.conf:
 *   http {
 *       my_timeout 30s;         <-- set at http level
 *       server {
 *                                <-- NOT set at server level
 *           location /api {
 *                                <-- NOT set at location level
 *           }
 *       }
 *   }
 *
 * Expected: location /api inherits my_timeout=30s from http block.
 * Actual:   location /api gets my_timeout=0 (broken inheritance).
 */

typedef struct {
    ngx_msec_t  timeout;   /* BUG: defaults to 0 (zero-init) */
    ngx_flag_t  enable;    /* BUG: defaults to 0, not NGX_CONF_UNSET */
} my_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    my_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(my_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /*
     * pcalloc zeros everything. timeout=0 and enable=0.
     * The merge callback sees 0 and thinks "user set this
     * to 0 explicitly" — skips inheriting the parent value.
     */
    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf,
    void *parent, void *child)
{
    my_loc_conf_t  *prev = parent;
    my_loc_conf_t  *conf = child;

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);
    ngx_conf_merge_value(conf->enable, prev->enable, 0);

    /*
     * ngx_conf_merge_msec_value expands to:
     *   if (conf->timeout == NGX_CONF_UNSET_MSEC) {
     *       conf->timeout = prev->timeout;  OR  default;
     *   }
     *
     * But conf->timeout is 0, not NGX_CONF_UNSET_MSEC,
     * so the merge is SKIPPED. timeout stays 0.
     */
    return NGX_CONF_OK;
}
```

**Correct (using NGX_CONF_UNSET initialization and tracing the merge chain):**

```c
typedef struct {
    ngx_msec_t  timeout;
    ngx_flag_t  enable;
} my_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    my_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(my_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* Initialize to UNSET so merge knows "not configured here" */
    conf->timeout = NGX_CONF_UNSET_MSEC;
    conf->enable = NGX_CONF_UNSET;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf,
    void *parent, void *child)
{
    my_loc_conf_t  *prev = parent;
    my_loc_conf_t  *conf = child;

    /*
     * Trace the merge chain: log each field's value before
     * and after the merge to diagnose inheritance issues.
     */
    ngx_conf_log_error(NGX_LOG_DEBUG, cf, 0,
                       "mymodule merge: timeout "
                       "prev=%M, conf=%M (before merge)",
                       prev->timeout, conf->timeout);

    ngx_conf_log_error(NGX_LOG_DEBUG, cf, 0,
                       "mymodule merge: enable "
                       "prev=%i, conf=%i (before merge)",
                       prev->enable, conf->enable);

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);
    ngx_conf_merge_value(conf->enable, prev->enable, 0);

    ngx_conf_log_error(NGX_LOG_DEBUG, cf, 0,
                       "mymodule merge result: "
                       "timeout=%M, enable=%i",
                       conf->timeout, conf->enable);

    return NGX_CONF_OK;
}

/*
 * Debug log output during configuration parsing:
 *
 * For the http{} block (parent=defaults, child=http):
 *   mymodule merge: timeout prev=-1, conf=30000 (before merge)
 *   mymodule merge: enable prev=-1, conf=-1 (before merge)
 *   mymodule merge result: timeout=30000, enable=0
 *
 * For server{} block (parent=http, child=server):
 *   mymodule merge: timeout prev=30000, conf=-1 (before merge)
 *   mymodule merge: enable prev=0, conf=-1 (before merge)
 *   mymodule merge result: timeout=30000, enable=0
 *        ^^^ conf was UNSET (-1), so it inherited prev's 30000
 *
 * For location /api (parent=server, child=location):
 *   mymodule merge: timeout prev=30000, conf=-1 (before merge)
 *   mymodule merge result: timeout=30000, enable=0
 *        ^^^ correctly inherited 30000 through the chain
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
