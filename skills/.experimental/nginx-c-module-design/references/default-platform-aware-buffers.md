---
title: Use Platform-Aware Buffer Size Defaults
impact: MEDIUM
impactDescription: "prevents 2-4x I/O penalty from partial-page reads on ARM64 and SPARC platforms"
tags: default, buffer, platform, pagesize
---

## Use Platform-Aware Buffer Size Defaults

Buffer size defaults should adapt to the platform's memory page size rather than being a fixed constant. Pattern from nginx: many buffer defaults are documented as `4k|8k` (page-size dependent). Use `ngx_pagesize` at config time to align buffer allocations to the platform, avoiding partial-page I/O penalties.

**Incorrect (hardcoded 4096 buffer size on all platforms):**

```c
typedef struct {
    size_t  buffer_size;
    size_t  read_buffer_size;
} ngx_http_mymodule_loc_conf_t;

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* BUG: hardcoded 4096 — on platforms with 8k or 16k pages
     * (ARM64 Linux, many BSDs), this causes partial-page reads
     * and wastes a full page per allocation anyway */
    ngx_conf_merge_size_value(conf->buffer_size,
                              prev->buffer_size, 4096);

    /* BUG: 8192 is correct on some platforms, wrong on others */
    ngx_conf_merge_size_value(conf->read_buffer_size,
                              prev->read_buffer_size, 8192);

    return NGX_CONF_OK;
}
```

**Correct (using ngx_pagesize to set platform-aligned default buffer sizes):**

```c
typedef struct {
    size_t  buffer_size;
    size_t  read_buffer_size;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->buffer_size = NGX_CONF_UNSET_SIZE;
    conf->read_buffer_size = NGX_CONF_UNSET_SIZE;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* one page — 4k on x86, 8k on SPARC, 16k on ARM64 with 16k pages;
     * matches nginx convention for single-buffer defaults */
    ngx_conf_merge_size_value(conf->buffer_size,
                              prev->buffer_size, ngx_pagesize);

    /* two pages — suitable for read-ahead buffers that benefit from
     * larger I/O, still page-aligned on every platform */
    ngx_conf_merge_size_value(conf->read_buffer_size,
                              prev->read_buffer_size,
                              2 * ngx_pagesize);

    return NGX_CONF_OK;
}
```
