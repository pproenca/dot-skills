---
title: Include Unit Suffixes in Field Names
impact: LOW
impactDescription: Unit suffixes prevent unit confusion bugs and make code self-documenting
tags: name, fields, units, suffixes
---

## Include Unit Suffixes in Field Names

Fields representing measurements include unit suffixes like `_usec`, `_secs`, `_ms`, `_bytes` to prevent unit confusion.

**Incorrect (problematic pattern):**

```rust
pub struct CpuStat {
    pub user: Option<u64>,          // Microseconds? Nanoseconds? Percent?
    pub system: Option<u64>,        // Same confusion
    pub idle: Option<u64>,
}

pub struct NetworkStat {
    pub rx: Option<u64>,            // Bytes? Packets? Bits?
    pub tx: Option<u64>,
}

pub struct ProcessInfo {
    pub uptime: Option<u64>,        // Seconds? Milliseconds?
    pub memory: Option<u64>,        // Bytes? Kilobytes? Pages?
}
```

**Correct (recommended pattern):**

```rust
pub struct CpuStat {
    pub user_usec: Option<u64>,     // Clear: microseconds
    pub system_usec: Option<u64>,
    pub idle_usec: Option<u64>,
}

pub struct NetworkStat {
    pub rx_bytes: Option<u64>,      // Clear: bytes
    pub tx_bytes: Option<u64>,
    pub rx_packets: Option<u64>,    // Clear: packet count
    pub tx_packets: Option<u64>,
}

pub struct ProcessInfo {
    pub uptime_secs: Option<u64>,          // Clear: seconds
    pub boot_time_epoch_secs: Option<u64>, // Epoch seconds
    pub memory_bytes: Option<u64>,         // Clear: bytes
    pub rss_pages: Option<u64>,            // Clear: memory pages
}
```

**Common unit suffixes:**
| Suffix | Unit | Example |
|--------|------|---------|
| `_usec` | Microseconds | `cpu_time_usec` |
| `_ms` | Milliseconds | `latency_ms` |
| `_secs` | Seconds | `uptime_secs` |
| `_bytes` | Bytes | `memory_bytes` |
| `_kb` | Kilobytes | `disk_usage_kb` |
| `_pages` | Memory pages | `rss_pages` |
| `_count` | Count/quantity | `error_count` |
| `_pct` | Percentage | `cpu_usage_pct` |

**When NOT to use:**
- When the type already encodes the unit (e.g., `Duration`, custom unit types)
- When the field name unambiguously implies the unit
