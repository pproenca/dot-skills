---
title: Write Correct config Build Script for Module Compilation
impact: HIGH
impactDescription: prevents module from failing to compile or load
tags: conf, build, config, compilation
---

## Write Correct config Build Script for Module Compilation

Every nginx C module requires a `config` shell script in its root directory. This script tells the nginx build system how to compile and link the module. The script format differs between static modules (compiled into the nginx binary) and dynamic modules (compiled as `.so` shared objects loaded at runtime). A missing or malformed `config` script causes silent build failures or modules that compile but cannot be loaded.

**Incorrect (missing required variables for dynamic module support):**

```bash
# config — only works with static compilation
ngx_addon_name=ngx_http_mymodule_module
HTTP_MODULES="$HTTP_MODULES ngx_http_mymodule_module"
NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/ngx_http_mymodule_module.c"

# BUG: --add-dynamic-module will fail — missing ngx_module_type,
# ngx_module_name, ngx_module_srcs, and . auto/module
```

**Correct (supports both static and dynamic module compilation):**

```bash
# config — works with both --add-module and --add-dynamic-module
ngx_addon_name=ngx_http_mymodule_module

if test -n "$ngx_module_link"; then
    # nginx 1.9.11+ dynamic module support
    ngx_module_type=HTTP
    ngx_module_name=ngx_http_mymodule_module
    ngx_module_srcs="$ngx_addon_dir/ngx_http_mymodule_module.c"

    . auto/module
else
    # legacy static module support
    HTTP_MODULES="$HTTP_MODULES ngx_http_mymodule_module"
    NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/ngx_http_mymodule_module.c"
fi
```

**Note:** For dynamic modules, the compiled `.so` file is loaded with `load_module modules/ngx_http_mymodule_module.so;` in `nginx.conf`. Use `ngx_module_type=HTTP` for HTTP modules, `STREAM` for stream modules, or `HTTP_FILTER` for filter modules. If your module has multiple source files, list them all in `ngx_module_srcs` separated by spaces. Add external library dependencies via `ngx_module_libs="-lssl -lcrypto"`.

Reference: [nginx Development Guide — Building](https://nginx.org/en/docs/dev/development_guide.html)
