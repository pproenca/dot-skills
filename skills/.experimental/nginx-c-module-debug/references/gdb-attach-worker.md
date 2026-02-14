---
title: Attach GDB to a Running nginx Worker Process
impact: HIGH
impactDescription: enables live debugging — attaching to wrong process (master) wastes 100% of debugging time
tags: gdb, attach, worker, live-debugging
---

## Attach GDB to a Running nginx Worker Process

Attaching GDB to a specific worker PID enables live debugging of hangs, infinite loops, or incorrect behavior in real time. The critical distinction is that the master process does not handle requests; only worker processes do. During development, use single-process mode (`master_process off; worker_processes 1;`) to simplify attaching. In multi-worker setups, identify which worker handles the problematic connection before attaching.

**Incorrect (attaching to the master process, which never processes requests):**

```bash
# Find nginx PIDs
$ ps aux | grep nginx
root      3201  ...  nginx: master process /usr/local/nginx/sbin/nginx
www-data  3202  ...  nginx: worker process
www-data  3203  ...  nginx: worker process

# BAD: attaching to the master PID
$ gdb -p 3201

# (gdb) bt
# #0  sigsuspend () at ...
# #1  ngx_master_process_cycle ()
#
# The master is blocked in sigsuspend() waiting for signals.
# It never processes HTTP requests, so you will never see
# your module's handler code in the backtrace.
# Setting breakpoints on your handler will never trigger.

# (gdb) break ngx_http_mymodule_handler
# Breakpoint 1 at 0x...
# ... (nothing happens, master doesn't call handlers)
```

**Correct (attaching to the worker that handles the connection):**

```bash
# Step 1: Use single-process mode for development
# nginx.conf:
#   master_process off;
#   worker_processes 1;
#   daemon off;

# Step 2: Find the worker PID (not master)
$ ps aux | grep 'nginx: worker'
www-data  3202  ...  nginx: worker process
www-data  3203  ...  nginx: worker process

# Step 3: For multi-worker, find which worker handles
# your test connection (check connection count or use
# a single worker during debugging)
$ gdb -p 3202

# Step 4: Set breakpoints on your module's functions
(gdb) break ngx_http_mymodule_handler
(gdb) continue

# Step 5: Send the test request from another terminal
# $ curl http://localhost/test

# GDB breaks at your handler:
# Breakpoint 1, ngx_http_mymodule_handler (r=0x...)
(gdb) print (char *)r->uri.data
# $1 = "/test"

# Step 6: When done, detach cleanly (don't kill the worker)
(gdb) detach
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
