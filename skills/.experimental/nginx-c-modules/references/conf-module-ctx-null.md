---
title: Set Unused Module Context Callbacks to NULL
impact: MEDIUM
impactDescription: prevents silent bugs from omitted callback slots
tags: conf, module-context, callbacks, initialization
---

## Set Unused Module Context Callbacks to NULL

The `ngx_http_module_t` structure has eight callback slots covering preconfiguration, postconfiguration, and create/merge for main, server, and location config. Unused slots must be explicitly set to `NULL`. While C zero-initializes trailing omitted fields in aggregate initializers, relying on this makes the struct fragile — reordering callbacks or adding a new slot silently leaves a function pointer unset, and the omission is invisible during review.

**Incorrect (partially initialized — intent unclear, error-prone on refactoring):**

```c
static ngx_http_module_t ngx_http_mymodule_module_ctx = {
    NULL,                                  /* preconfiguration */
    ngx_http_mymodule_postconfiguration,   /* postconfiguration */
    NULL,                                  /* create main configuration */
    NULL,                                  /* init main configuration */
    NULL,                                  /* create server configuration */
    NULL,                                  /* merge server configuration */
    ngx_http_mymodule_create_loc_conf      /* create location configuration */
    /* merge_loc_conf slot omitted — C zero-initializes trailing fields,
     * but the missing slot is invisible to reviewers and breaks silently
     * if callbacks are reordered or a new one is needed */
};
```

**Correct (all eight callbacks explicitly declared):**

```c
static ngx_http_module_t ngx_http_mymodule_module_ctx = {
    NULL,                                  /* preconfiguration */
    ngx_http_mymodule_postconfiguration,   /* postconfiguration */
    NULL,                                  /* create main configuration */
    NULL,                                  /* init main configuration */
    NULL,                                  /* create server configuration */
    NULL,                                  /* merge server configuration */
    ngx_http_mymodule_create_loc_conf,     /* create location configuration */
    ngx_http_mymodule_merge_loc_conf       /* merge location configuration */
};
```

**Note:** In C, trailing omitted initializers in aggregate types are zero-initialized only when the struct is defined with an initializer list. However, relying on this is fragile — explicitly listing all eight slots documents intent and prevents mistakes when callbacks are reordered.
