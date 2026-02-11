---
title: Use Descriptive Suffixes for Type Specialization
impact: MEDIUM
impactDescription: Semantic suffixes communicate type purpose without reading implementation
tags: name, types, suffixes, semantic
---

## Use Descriptive Suffixes for Type Specialization

Structs use consistent suffixes like Reader, Writer, Builder, Options, State, Error to communicate their role.

**Incorrect (problematic pattern):**

```rust
struct ProcRead { ... }           // Unclear: is it a verb or noun?
struct StoreWrite { ... }         // Ambiguous
struct CollectorOpts { ... }      // Inconsistent abbreviation
struct CgroupSt { ... }           // Cryptic abbreviation
```

**Correct (recommended pattern):**

```rust
// Role-based suffixes
struct ProcReader { ... }         // Reads from procfs
struct StoreWriter { ... }        // Writes to store
struct ExitstatDriver { ... }     // Drives/orchestrates exitstat

// Configuration
struct CollectorOptions { ... }   // Options for Collector
struct RenderConfig { ... }       // Configuration for rendering

// Data containers
struct CpuStat { ... }           // Statistics data
struct MemInfo { ... }           // Information/metadata
struct PidMap { ... }            // Map/collection type

// State management
struct MainViewState { ... }      // UI state
struct ProcessZoomState { ... }   // Zoom state

// Errors
struct TcError { ... }           // Traffic control errors
struct EthtoolError { ... }      // Ethtool-specific errors
```

**Common suffix patterns:**
| Suffix | Purpose | Example |
|--------|---------|---------|
| Reader | Reads data from source | `ProcReader`, `NetReader` |
| Writer | Writes data to destination | `StoreWriter` |
| Builder | Constructs complex objects | `RenderConfigBuilder` |
| Options | Configuration parameters | `CollectorOptions` |
| Config | Configuration settings | `RenderConfig` |
| State | Mutable state container | `ViewState` |
| Info | Metadata/information | `PidInfo`, `MemInfo` |
| Stat | Statistics/measurements | `CpuStat`, `DiskStat` |
| Map | Collection mapping | `PidMap`, `NetMap` |
| Error | Error type | `TcError` |
