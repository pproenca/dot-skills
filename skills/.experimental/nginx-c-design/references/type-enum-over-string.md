---
title: Use Enum Slot for Known Value Sets
impact: HIGH
impactDescription: "catches 100% of value typos at config-test time vs 0% with raw strings"
tags: type, enum, validation, parse-time
---

## Use Enum Slot for Known Value Sets

When a directive accepts one of a known set of values (like `ssl_verify_client on|off|optional|optional_no_ca`), use `ngx_conf_set_enum_slot` with an `ngx_conf_enum_t` array. This validates the value at parse time and gives a clear error on typos. Using a string slot accepts anything and defers validation to request time, or worse, never validates at all.

**Incorrect (string slot accepts typos and silently falls through):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: string slot — "agressive" typo silently accepted */
    { ngx_string("mymod_cache_strategy"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_strategy),
      NULL },

      ngx_null_command
};

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* strcmp chain on every request — typo "agressive" matches nothing,
     * silently falls to default behavior with no warning */
    if (ngx_strcmp(mlcf->cache_strategy.data, "aggressive") == 0) {
        return ngx_http_mymodule_cache_aggressive(r);
    } else if (ngx_strcmp(mlcf->cache_strategy.data, "conservative") == 0) {
        return ngx_http_mymodule_cache_conservative(r);
    } else if (ngx_strcmp(mlcf->cache_strategy.data, "off") == 0) {
        return NGX_DECLINED;
    }

    /* typos land here — no error, just wrong behavior */
    return ngx_http_mymodule_cache_conservative(r);
}
```

**Correct (enum slot validates at parse time and stores an integer constant):**

```c
#define NGX_HTTP_MYMOD_CACHE_OFF          0
#define NGX_HTTP_MYMOD_CACHE_CONSERVATIVE  1
#define NGX_HTTP_MYMOD_CACHE_AGGRESSIVE    2

static ngx_conf_enum_t ngx_http_mymodule_cache_strategies[] = {
    { ngx_string("off"),          NGX_HTTP_MYMOD_CACHE_OFF },
    { ngx_string("conservative"), NGX_HTTP_MYMOD_CACHE_CONSERVATIVE },
    { ngx_string("aggressive"),   NGX_HTTP_MYMOD_CACHE_AGGRESSIVE },
    { ngx_null_string, 0 }
};

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* parse-time validation — "agressive" typo rejected immediately */
    { ngx_string("mymod_cache_strategy"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_enum_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_strategy),
      &ngx_http_mymodule_cache_strategies },

      ngx_null_command
};

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* integer comparison — fast, no typo risk, exhaustive switch */
    switch (mlcf->cache_strategy) {

    case NGX_HTTP_MYMOD_CACHE_AGGRESSIVE:
        return ngx_http_mymodule_cache_aggressive(r);

    case NGX_HTTP_MYMOD_CACHE_CONSERVATIVE:
        return ngx_http_mymodule_cache_conservative(r);

    case NGX_HTTP_MYMOD_CACHE_OFF:
        return NGX_DECLINED;
    }

    return NGX_DECLINED;
}
```
