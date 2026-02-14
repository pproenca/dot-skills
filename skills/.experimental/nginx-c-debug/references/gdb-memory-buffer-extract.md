---
title: Extract Debug Log from Memory Buffer Using GDB Script
impact: HIGH
impactDescription: recovers last 32MB+ of debug trace from crashed worker coredump
tags: gdb, memory-buffer, debug-log, extraction
---

## Extract Debug Log from Memory Buffer Using GDB Script

When using `error_log memory:32m debug;`, nginx writes the debug log to a cyclic memory buffer within the worker process. This buffer survives in the coredump even after a crash, providing the complete debug trace leading up to the failure. File-based debug logging at the `debug` level imposes a 5-10x performance penalty and fills disk rapidly under load, making it unsuitable for production. Memory buffer logging has near-zero overhead and captures the same information, recoverable post-crash via a GDB script.

**Incorrect (using file-based debug logging in production, destroying performance):**

```c
/*
 * nginx.conf — file-based debug logging
 *
 * Under production load (10,000+ req/s), this configuration:
 * - Reduces throughput by 5-10x due to synchronous disk writes
 * - Generates 1-10 GB/hour of log data
 * - Fills disk and causes cascading failures
 * - May not even capture the crash if disk becomes full
 */

error_log /var/log/nginx/debug.log debug;

worker_processes  4;

events {
    worker_connections  4096;
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
 * Result under load:
 *   $ du -sh /var/log/nginx/debug.log
 *   4.2G    /var/log/nginx/debug.log   (after 30 minutes)
 *   $ nginx -s reload  → disk full, reload fails
 */
```

**Correct (memory buffer logging with GDB extraction script):**

```c
/*
 * nginx.conf — memory buffer debug logging (near-zero overhead)
 */
error_log memory:32m debug;

worker_processes  1;
working_directory /var/coredumps;
worker_rlimit_core 500m;

events {
    worker_connections  4096;
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
 * After a crash, extract the debug log from the coredump:
 *
 * Save this as extract_debug_log.gdb:
 */

/*
 * set $log = ngx_cycle->log
 * while $log
 *   if $log->writer == ngx_log_memory_writer
 *     set $buf = (ngx_log_memory_buf_t *) $log->wdata
 *     set $start = $buf->start
 *     set $pos = $buf->pos
 *     set $end = $buf->end
 *
 *     # Dump from write position to end (older entries)
 *     if $pos < $end
 *       dump binary memory /tmp/debug_tail.log $pos $end
 *     end
 *     # Dump from start to write position (newer entries)
 *     dump binary memory /tmp/debug_head.log $start $pos
 *
 *     printf "Extracted debug log to /tmp/debug_head.log"
 *     printf " and /tmp/debug_tail.log\n"
 *     printf "Concatenate: cat tail head > full_debug.log\n"
 *   end
 *   set $log = $log->next
 * end
 */

/* Usage:
 * $ gdb /usr/local/nginx/sbin/nginx /var/coredumps/core.nginx.4827
 * (gdb) source extract_debug_log.gdb
 * $ cat /tmp/debug_tail.log /tmp/debug_head.log > full_debug.log
 * $ grep 'http request\|upstream\|finalize' full_debug.log
 */
```

Reference: [nginx Debugging Guide](https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/)
