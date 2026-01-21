---
title: Use Graceful Degradation for Non-Critical Operations
impact: MEDIUM
impactDescription: Logging errors instead of propagating keeps systems running when subsystems fail
tags: err, graceful, degradation, logging, resilience
---

## Use Graceful Degradation for Non-Critical Operations

For non-critical data collection or optional features, log the error and continue with default values rather than propagating the failure.

**Incorrect (problematic pattern):**

```rust
// All failures propagate - one subsystem brings down everything
fn collect_system_stats() -> Result<SystemStats> {
    let cpu = read_cpu_stats()?;        // Required
    let memory = read_memory_stats()?;  // Required
    let gpu = read_gpu_stats()?;        // Optional - fails if no GPU
    let ethtool = read_ethtool()?;      // Optional - fails if no permission

    Ok(SystemStats { cpu, memory, gpu, ethtool })
}

// If GPU reading fails, entire collection fails - bad!
```

**Correct (recommended pattern):**

```rust
use slog::{error, Logger};

fn collect_system_stats(logger: &Logger) -> Result<SystemStats> {
    // Required - propagate errors
    let cpu = read_cpu_stats()?;
    let memory = read_memory_stats()?;

    // Optional - log and use None
    let gpu = match read_gpu_stats() {
        Ok(stats) => Some(stats),
        Err(e) => {
            error!(logger, "Failed to read GPU stats: {:#}", e);
            None
        }
    };

    let ethtool = match read_ethtool() {
        Ok(stats) => Some(stats),
        Err(e) => {
            error!(logger, "Failed to read ethtool stats: {:#}", e);
            None
        }
    };

    // Optional with default
    let kernel_version = read_kernel_version()
        .map_err(|e| error!(logger, "Failed to read kernel version: {:#}", e))
        .ok();

    Ok(SystemStats {
        cpu,
        memory,
        gpu,
        ethtool,
        kernel_version,
    })
}
```

```rust
// Helper pattern for optional collection
fn try_collect<T, F>(logger: &Logger, name: &str, f: F) -> Option<T>
where
    F: FnOnce() -> Result<T>,
{
    match f() {
        Ok(value) => Some(value),
        Err(e) => {
            error!(logger, "Failed to collect {}: {:#}", name, e);
            None
        }
    }
}

// Usage
let gpu = try_collect(&logger, "GPU stats", read_gpu_stats);
```

**When NOT to use:**
- Critical operations where failure should stop execution
- Errors that indicate data corruption or security issues
