---
title: Enable Checkpoint Skipping for Large Production Stacks
impact: CRITICAL
impactDescription: up to 20× faster deployments
tags: pstate, checkpoints, performance, large-stacks
---

## Enable Checkpoint Skipping for Large Production Stacks

Pulumi saves state snapshots at every operation step for fault tolerance. For large stacks (1000+ resources), this creates significant overhead. Use journaling mode or checkpoint skipping for production stacks with proper recovery procedures.

**Incorrect (default checkpointing on large stack):**

```bash
# Every resource operation triggers full state upload
pulumi up
# Stack with 5000 resources takes 40+ minutes
# Most time spent on state persistence, not resource provisioning
```

**Correct (checkpoint skipping for large stacks):**

```bash
# Skip intermediate checkpoints, save only final state
export PULUMI_SKIP_CHECKPOINTS=true
pulumi up
# Same stack completes in 2-5 minutes
```

**When NOT to skip checkpoints:**
- Development or staging environments where recovery is simple
- Stacks with frequent failures requiring mid-operation recovery
- When you lack a backup strategy for state corruption

Reference: [Speeding up Pulumi Operations by up to 20x](https://www.pulumi.com/blog/journaling/)
