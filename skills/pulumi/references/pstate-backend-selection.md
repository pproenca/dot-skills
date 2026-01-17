---
title: Use Managed Backend for Production Stacks
impact: CRITICAL
impactDescription: 10-50× faster state operations vs self-managed
tags: pstate, backend, pulumi-cloud, performance
---

## Use Managed Backend for Production Stacks

Pulumi Cloud provides transactional checkpointing, concurrent state locking, and optimized diff-based syncing. Self-managed backends require additional operational overhead and lack these optimizations.

**Incorrect (self-managed S3 backend without optimization):**

```yaml
# Pulumi.yaml
name: production-infrastructure
runtime: nodejs
backend:
  url: s3://my-state-bucket/pulumi-state
# No concurrent locking, full state uploads on every operation
# Team members can corrupt state with simultaneous updates
```

**Correct (Pulumi Cloud with automatic optimization):**

```yaml
# Pulumi.yaml
name: production-infrastructure
runtime: nodejs
# Default backend uses Pulumi Cloud
# Automatic diff-based uploads, concurrent locking, audit history
```

**When NOT to use managed backend:**
- Air-gapped environments with no internet access
- Strict data residency requirements prohibiting external storage
- Organizations with existing state management infrastructure (PostgreSQL backend)

Reference: [State and Backends](https://www.pulumi.com/docs/iac/concepts/state-and-backends/)
