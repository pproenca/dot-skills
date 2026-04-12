---
title: Accept User-Provided Names Instead of Auto-Generating IDs
impact: MEDIUM
impactDescription: prevents orphaned duplicates from timed-out retries
tags: idem, ids, names, retry
---

## Accept User-Provided Names Instead of Auto-Generating IDs

When `create`, `deploy`, `apply`, or ANY state-changing command generates a random UUID server-side, a timed-out retry creates a second resource with a different ID — and the agent can't find the first one because it never saw the response. This is the #1 source of "ghost resources" in agent-driven ops. Accept a user-provided `--name`, `--id`, or `--idempotency-key` so that reruns target the same resource. If it already exists with the same config, the command is a no-op; if it exists with different config, you get a clear conflict error. This rule applies to `deploy` just as much as to `create` — a deploy that generates `dep_abc123` randomly will create `dep_xyz789` on retry, and the agent has no way to find the first.

**Incorrect (server generates the ID; timed-out retry orphans resources):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Agent: mycli volume:create --size 100
resp=$(curl -fsS --max-time 10 -X POST https://api.example.com/volumes \
  -d '{"size":100}' || true)

if [[ -z $resp ]]; then
  echo "timeout, retrying..." >&2
  # BUG: the first call may have succeeded; we just didn't get the response.
  # Retrying creates a second volume, and the agent can never find the first.
  resp=$(curl -fsS -X POST https://api.example.com/volumes -d '{"size":100}')
fi
echo "$resp"
```

**Correct (caller provides a stable name; second call is a no-op):**

```bash
#!/usr/bin/env bash
set -euo pipefail

NAME=$1   # e.g. "app-data-vol"
SIZE=$2

# GET by name first; creates are idempotent on name
if existing=$(curl -fsS "https://api.example.com/volumes/name/${NAME}" 2>/dev/null); then
  existing_size=$(echo "$existing" | jq -r '.size')
  if [[ $existing_size == "$SIZE" ]]; then
    echo "$existing"
    exit 0
  fi
  echo "Error: volume '${NAME}' exists with size ${existing_size}, requested ${SIZE}." >&2
  exit 2
fi

curl -fsS -X POST https://api.example.com/volumes \
  -d "{\"name\":\"${NAME}\",\"size\":${SIZE}}"
```

**Alternative (deploy command — `--idempotency-key` flag):**

The same pattern applies to every state-changing verb, especially `deploy`. A deploy
command that mints its own deployment ID turns every timed-out retry into a
double-deploy. Accept a caller-supplied `--idempotency-key` (or `--deployment-id`)
and make the same key always map to the same rollout.

```typescript
import { Command } from 'commander';
import { randomUUID } from 'crypto';

new Command()
  .name('deploy')
  .requiredOption('--service <name>')
  .requiredOption('--env <env>')
  .requiredOption('--tag <tag>')
  .option('--idempotency-key <key>', 'caller-supplied key for retry safety')
  .action(async ({ service, env, tag, idempotencyKey }) => {
    // If caller didn't pass a key, derive one deterministically from the
    // input parameters. Retries with the same inputs hit the same deploy.
    const key = idempotencyKey ?? `${service}:${env}:${tag}`;

    // API honors Idempotency-Key on POST per RFC draft-ietf-httpapi-idempotency
    const result = await api.deploy({ service, env, tag }, {
      headers: { 'Idempotency-Key': key },
    });

    console.log(JSON.stringify({
      deploy_id: result.id,       // same on retry
      idempotency_key: key,       // echoed so the caller can audit
      changed: result.changed,    // true first time, false on retry
      url: result.url,
    }));
  })
  .parseAsync();
```

**Benefits:**
- Timed-out retries target the same resource or deploy, not a new one
- No orphaned duplicates to clean up after flaky network conditions
- Client-chosen names/keys are also easier for agents to reference in later commands
- The pattern works for `create`, `deploy`, `apply`, `upload`, `send` — any state-changing verb

Reference: [AWS — Idempotent API requests with client tokens](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/Run_Instance_Idempotency.html) and [IETF draft — Idempotency-Key HTTP header](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/)
