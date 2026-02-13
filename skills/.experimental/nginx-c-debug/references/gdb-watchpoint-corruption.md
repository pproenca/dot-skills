---
title: Use GDB Watchpoints to Catch Memory Corruption at Write Time
impact: HIGH
impactDescription: catches corruption at the exact instruction that writes bad data
tags: gdb, watchpoint, memory-corruption, hardware-breakpoint
---

## Use GDB Watchpoints to Catch Memory Corruption at Write Time

When a struct field contains a corrupted value but the crash only manifests later when the value is read, the crash site is the symptom, not the cause. A GDB hardware watchpoint on the memory address of the corrupted field breaks execution at the exact instruction that writes the bad data, even if the write comes from a completely unrelated function or module. Hardware watchpoints are implemented by the CPU debug registers (limited to 4 on x86-64), so they have zero performance impact and do not slow down execution.

**Incorrect (setting breakpoints at the read site where the crash occurs):**

```bash
# Crash backtrace shows:
# #0  ngx_http_mymodule_send_response (r=0x...) at my_module.c:145
#
# (gdb) frame 0
# (gdb) print ctx->buffer_size
# $1 = -559038737   (0xDEADBEEF — clearly corrupted)

# BAD: set breakpoints where the corrupted value is READ
(gdb) break my_module.c:145
(gdb) continue

# When it breaks, ctx->buffer_size is already corrupted.
# The corruption happened earlier in the request lifecycle.
# We can see THAT it's corrupted, but not WHO corrupted it.

# Developer tries adding more breakpoints at every function
# that touches ctx, spending hours on trial and error:
(gdb) break my_module.c:80
(gdb) break my_module.c:95
(gdb) break my_module.c:110
# ... this doesn't scale and misses cross-module corruption
```

**Correct (using a hardware watchpoint to catch the exact corruption write):**

```bash
# Step 1: From coredump or live session, find the address of
# the corrupted field
(gdb) print &ctx->buffer_size
# $1 = (size_t *) 0x7f2a3c004a18

(gdb) print ctx->buffer_size
# $2 = 3735928559   (0xDEADBEEF — corrupted)

# Step 2: Restart nginx in single-process mode and attach GDB
# nginx.conf: master_process off; worker_processes 1; daemon off;
$ gdb --args /usr/local/nginx/sbin/nginx -c /etc/nginx/debug.conf

# Step 3: Set a breakpoint at context creation to get ctx address
(gdb) break ngx_http_mymodule_handler
(gdb) run

# When handler fires, get the live ctx address
(gdb) print ctx
# $3 = (my_ctx_t *) 0x7f2a3c008200

# Step 4: Set hardware watchpoint on the field
(gdb) watch *(size_t *)&ctx->buffer_size
# Hardware watchpoint 2: *(size_t *)&ctx->buffer_size
(gdb) continue

# Step 5: GDB stops at the EXACT write instruction
# Hardware watchpoint 2: *(size_t *)&ctx->buffer_size
# Old value = 8192
# New value = 3735928559
# ngx_http_other_module_cleanup (data=0x...) at other_module.c:203
# 203     ngx_memset(pool_block, 0xDEAD, block_size);
#
# ROOT CAUSE FOUND: another module's cleanup handler is
# overwriting memory that our ctx occupies — a use-after-free
# because ctx was allocated from a pool that was destroyed.

(gdb) bt
# Full backtrace shows exactly how we got here
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
