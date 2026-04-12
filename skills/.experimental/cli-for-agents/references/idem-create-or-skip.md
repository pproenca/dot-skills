---
title: Make Create Commands Skip When Target Already Exists
impact: MEDIUM-HIGH
impactDescription: prevents race conditions and wrapper if-exists checks
tags: idem, create, exists, retry
---

## Make Create Commands Skip When Target Already Exists

A `create` command that errors on "already exists" forces the caller into one of two bad patterns: (a) wrap every call with try/catch and ignore the error — which also swallows real errors, or (b) first check if the resource exists and then create — which is racy. The cleanest design is to make create idempotent by default (or via an explicit `--if-not-exists` flag that agents reach for). Kubernetes `apply`, Terraform `create_before_destroy`, and `useradd -f` all follow this pattern.

**Incorrect (create errors when resource already exists):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# mycli user:create alice --role admin
curl -fsS -X POST https://api.example.com/users \
  -d '{"name":"alice","role":"admin"}' \
  -H 'Content-Type: application/json'

# Retry after a network blip → HTTP 409 "already exists" → exit 1
```

**Correct (create is idempotent; second run prints "already exists"):**

```bash
#!/usr/bin/env bash
set -euo pipefail

NAME=$1
ROLE=$2

existing=$(curl -fsS "https://api.example.com/users/${NAME}" 2>/dev/null || true)
if [[ -n $existing ]]; then
  existing_role=$(echo "$existing" | jq -r '.role')
  if [[ $existing_role == "$ROLE" ]]; then
    echo "user ${NAME} already exists with role ${ROLE}"
    exit 0
  fi
  echo "Error: user ${NAME} exists with different role '${existing_role}'." >&2
  echo "  mycli user:update ${NAME} --role ${ROLE}" >&2
  exit 2
fi

curl -fsS -X POST https://api.example.com/users \
  -d "{\"name\":\"${NAME}\",\"role\":\"${ROLE}\"}" \
  -H 'Content-Type: application/json'
echo "user ${NAME} created with role ${ROLE}"
```

**Benefits:**
- Retry on transient failure is always safe
- Same-config re-run is a no-op (not a duplicate, not an error)
- Different-config re-run errors with a concrete fix instead of silent drift

**When NOT to use this pattern:**
- When duplicate resources are semantically valid (e.g., "create log entry") — accept and explain explicitly via a different verb like `append`

Reference: [clig.dev — Make operations idempotent](https://clig.dev/#robustness)
