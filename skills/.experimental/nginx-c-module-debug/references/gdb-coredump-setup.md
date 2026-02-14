---
title: Configure Core Dump Generation for nginx Worker Crashes
impact: HIGH
impactDescription: enables post-mortem analysis — without coredumps, crash root cause is lost 100% of the time
tags: gdb, coredump, worker, configuration
---

## Configure Core Dump Generation for nginx Worker Crashes

Without proper core dump configuration, worker crashes leave no artifact for analysis and you are left guessing. Core dumps require coordinated setup across three layers: nginx.conf directives (`working_directory`, `worker_rlimit_core`), kernel core pattern (`/proc/sys/kernel/core_pattern`), and OS-level resource limits (`ulimit`). The most common failure mode is that the nginx worker runs as the `nobody` or `www-data` user and the dump directory lacks write permissions for that user, so coredumps are silently discarded.

**Incorrect (incomplete setup that silently discards coredumps):**

```c
/*
 * nginx.conf — only kernel core_pattern is set,
 * missing nginx.conf directives and directory permissions.
 *
 * The worker process has no working_directory set,
 * so it tries to write the core to '/' (no permission).
 * worker_rlimit_core is unset, defaulting to 0 (no dump).
 */

/* System setup (as root): */
/* echo '/tmp/cores/core.%e.%p' > /proc/sys/kernel/core_pattern */

/* nginx.conf — MISSING critical directives: */
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}

/*
 * Result: worker crashes with signal 11, error log says
 * "exited on signal 11" but NO coredump file is created.
 * /tmp/cores/ is empty or doesn't exist.
 */
```

**Correct (full setup across nginx.conf, kernel, and filesystem):**

```c
/*
 * Step 1: Create dump directory with correct ownership
 */
/* mkdir -p /var/coredumps                         */
/* chown www-data:www-data /var/coredumps           */
/* chmod 0700 /var/coredumps                        */

/*
 * Step 2: Set kernel core pattern and limits (as root)
 */
/* echo '/var/coredumps/core.%e.%p.%t' > /proc/sys/kernel/core_pattern */
/* echo 0 > /proc/sys/kernel/core_uses_pid                             */
/* ulimit -c unlimited                                                  */

/*
 * Step 3: nginx.conf — enable coredumps in nginx itself
 */
worker_processes  1;
working_directory /var/coredumps;    /* where worker writes the dump  */
worker_rlimit_core 500m;            /* max core size (enough for heap) */

/* Build nginx with debug symbols for useful backtraces:               */
/* ./configure --with-debug --with-cc-opt='-O0 -g'                     */

events {
    worker_connections  1024;
}

http {
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}

/*
 * Step 4: Verify after a crash
 */
/* ls -la /var/coredumps/core.nginx.*               */
/* gdb /usr/local/nginx/sbin/nginx /var/coredumps/core.nginx.4827  */
/* (gdb) bt full                                                    */
```

Reference: [nginx Debugging Guide](https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/)
