---
title: Move blocking work out of async fns — spawn_blocking or async primitives
tags: conc, async, blocking, tokio
---

## Move blocking work out of async fns — spawn_blocking or async primitives

`std::thread::sleep`, `std::fs::read`, a synchronous DB driver, or a long CPU crunch inside an `async fn` is thread-per-request thinking on a runtime that isn't one: tokio multiplexes many tasks onto a few worker threads, so one blocked task freezes *every* task scheduled on that worker — the service doesn't slow down, whole connections stall. The fix is per kind of work: an async equivalent when one exists (`tokio::time::sleep`, `tokio::fs`, an async driver), `spawn_blocking` for irreducibly synchronous calls, and a dedicated compute path (see `conc-blocking-pool-over-async-cpu-fanout`) for CPU-bound loops.

**Incorrect (one task blocks a worker thread for everyone):**

```rust
async fn export_report(db_path: &Path) -> Result<Report, ExportError> {
    std::thread::sleep(Duration::from_secs(1));          // parks the worker
    let bytes = std::fs::read(db_path)?;                 // blocking syscall
    Ok(parse_report(&bytes))
}
```

**Correct (the worker stays free to run other tasks):**

```rust
async fn export_report(db_path: &Path) -> Result<Report, ExportError> {
    tokio::time::sleep(Duration::from_secs(1)).await;
    let bytes = tokio::fs::read(db_path).await?;
    let report = tokio::task::spawn_blocking(move || parse_report(&bytes))
        .await
        .map_err(|_| ExportError::ParserPanicked)?;
    Ok(report)
}
```

The rule of thumb from the tokio maintainers: an async fn should not spend more than ~10–100µs between `.await`s without yielding. If a call has no `.await` and takes longer, it belongs behind `spawn_blocking`.

Reference: [Alice Ryhl — Async: What is blocking?](https://ryhl.io/blog/async-what-is-blocking/)
