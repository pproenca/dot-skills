---
title: Support Single-Process Mode for Debugging
impact: LOW-MEDIUM
impactDescription: enables gdb/valgrind attachment without multi-process complexity
tags: worker, debug, single-process, valgrind
---

## Support Single-Process Mode for Debugging

Running nginx with `master_process off` and `worker_processes 1` collapses the master+worker architecture into a single process, making it possible to attach gdb or run under valgrind without chasing fork()ed PIDs. Module code that assumes multi-process operation -- using shared memory zones for inter-worker IPC, or skipping initialization because "the master will handle it" -- crashes or deadlocks in single-process mode, making debugging impossible precisely when it is most needed.

**Incorrect (assumes shared memory zone exists for inter-process communication):**

```c
static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_shm_zone_t                *shm_zone;
    ngx_http_mymodule_shm_data_t  *shm;

    /* BUG: in single-process mode (master_process off), the shared
     * memory zone init callback may behave differently — and the
     * module unconditionally dereferences shm->stats without checking
     * if it was properly initialized */
    shm_zone = ngx_http_mymodule_shm_zone;
    shm = shm_zone->data;

    /* BUG: uses atomic lock meant for multi-worker contention —
     * in single-process mode this is unnecessary overhead that
     * complicates valgrind/helgrind analysis with false positives */
    ngx_shmtx_lock(&shm->stats->mutex);
    shm->stats->worker_start_count++;
    ngx_shmtx_unlock(&shm->stats->mutex);

    return NGX_OK;
}
```

**Correct (works in both single-process and multi-process modes):**

```c
static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_core_conf_t               *ccf;
    ngx_shm_zone_t                *shm_zone;
    ngx_http_mymodule_shm_data_t  *shm;

    ccf = (ngx_core_conf_t *) ngx_get_conf(cycle->conf_ctx,
                                            ngx_core_module);

    shm_zone = ngx_http_mymodule_shm_zone;
    if (shm_zone == NULL || shm_zone->data == NULL) {
        /* shared zone not configured — operate in local-only mode,
         * which is common during valgrind/gdb debugging sessions */
        ngx_log_error(NGX_LOG_NOTICE, cycle->log, 0,
                      "mymodule: no shared zone, using process-local stats");
        ngx_http_mymodule_use_local_stats = 1;
        return NGX_OK;
    }

    shm = shm_zone->data;

    if (ccf->master == 0 || ccf->worker_processes <= 1) {
        /* single-process mode — skip atomic locking to keep
         * valgrind/helgrind output clean and avoid unnecessary
         * contention overhead on a single worker */
        shm->stats->worker_start_count++;
    } else {
        ngx_shmtx_lock(&shm->stats->mutex);
        shm->stats->worker_start_count++;
        ngx_shmtx_unlock(&shm->stats->mutex);
    }

    return NGX_OK;
}
```

**Note:** Check `ccf->master` (0 when `master_process off`) and `ccf->worker_processes` to detect single-process mode. Modules should provide a local-only fallback path that avoids shared memory and locks, ensuring clean valgrind output. This also makes unit testing the module in isolation much simpler.
