---
title: Group Crates by Feature Domain
impact: MEDIUM
impactDescription: Domain-based organization creates natural boundaries and improves code discoverability
tags: org, domain, feature, architecture
---

## Group Crates by Feature Domain

Organize crates by feature domain (btrfs, cgroupfs, ethtool) rather than technical layers (controllers, services, repositories). Domain-based grouping creates natural code boundaries.

**Incorrect (problematic pattern):**

```text
project/
├── controllers/       # Technical layer grouping
│   ├── cgroup_controller.rs
│   ├── process_controller.rs
│   └── network_controller.rs
├── services/
│   ├── cgroup_service.rs
│   └── process_service.rs
└── repositories/
    ├── cgroup_repo.rs
    └── process_repo.rs
```text

**Correct (recommended pattern):**

```
project/
├── cgroupfs/          # Domain: cgroup filesystem
│   └── src/
│       ├── lib.rs
│       ├── types.rs
│       └── reader.rs
├── procfs/            # Domain: proc filesystem
│   └── src/
│       ├── lib.rs
│       ├── types.rs
│       └── reader.rs
├── ethtool/           # Domain: network interface stats
│   └── src/lib.rs
└── model/             # Cross-cutting: data models
    └── src/lib.rs
```

Each domain crate encapsulates:
- Types specific to that domain
- Reading/writing logic
- Domain-specific errors

**When NOT to use:**
- When domains are tightly coupled and share most code
- Very small projects where a single crate suffices
