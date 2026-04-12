---
title: Design Multi-Step Commands for Crash-Only Recovery
impact: MEDIUM-HIGH
impactDescription: prevents stuck-state requiring manual intervention
tags: safe, crash-only, resume, multi-step
---

## Design Multi-Step Commands for Crash-Only Recovery

A multi-step command (copy files, run migrations, deploy) that partially fails and then needs a manual `mycli reset` before retry is a trap for agents — they will retry blindly and get the same error forever. Design for crash-only recovery: either the next invocation can resume from wherever the last one left off, OR it can safely start over from scratch without user intervention. Never require a manual cleanup between runs.

**Incorrect (partial failure leaves a lock file that blocks retries):**

```bash
#!/usr/bin/env bash
set -euo pipefail

LOCK=/var/run/mycli-deploy.lock
if [[ -f $LOCK ]]; then
  echo "Error: deploy in progress (lock file exists)" >&2
  echo "Run 'mycli deploy unlock' to recover" >&2
  exit 1
fi
touch "$LOCK"
step_1_copy_files
step_2_run_migration        # fails here
step_3_restart_service
rm -f "$LOCK"
```

**Correct (lock file uses PID; stale locks are ignored on retry):**

```bash
#!/usr/bin/env bash
set -euo pipefail

LOCK=/var/run/mycli-deploy.lock

# If lock exists but owner is dead, clear it — the previous run crashed
if [[ -f $LOCK ]]; then
  pid=$(cat "$LOCK")
  if kill -0 "$pid" 2>/dev/null; then
    echo "Error: deploy $pid already running" >&2
    exit 2
  fi
  echo "Clearing stale lock from dead pid $pid" >&2
  rm -f "$LOCK"
fi

echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# Each step is idempotent, so retrying from scratch is safe
step_1_copy_files       # uses rsync, overwrite-safe
step_2_run_migration    # checks "migration already applied" and skips
step_3_restart_service  # safe to call on a running service
```

**Benefits:**
- Agent can retry after any failure without human intervention
- Stale locks never block indefinitely — they clear on next run
- Each step checks desired state, so re-running is a no-op when already done

Reference: [clig.dev — Crash-only design](https://clig.dev/#robustness)
