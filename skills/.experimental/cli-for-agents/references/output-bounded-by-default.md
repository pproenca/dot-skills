---
title: Bound Default Output Size with --limit and --all
impact: MEDIUM-HIGH
impactDescription: prevents agent context blowup on default list invocations
tags: output, limit, pagination, context-budget
---

## Bound Default Output Size with --limit and --all

A `list` command that returns every record by default will dump 50,000 rows into the agent's context the first time it's invoked, exhausting the context budget on a discovery call. Bound the default (e.g., `--limit 50`) and let the user opt into the full set with `--all` or an explicit larger `--limit`. Document the limit in `--help` so agents know they are seeing a truncated view and can request more when they need it. `gh`, `kubectl`, and `aws` all default to small limits for this exact reason.

**Incorrect (list returns everything by default):**

```typescript
import { Command } from 'commander';

new Command()
  .name('list')
  .option('--json', 'output as JSON')
  .action(async ({ json }) => {
    const services = await api.listAllServices(); // might be 50,000
    if (json) {
      console.log(JSON.stringify(services));
    } else {
      for (const s of services) {
        console.log(`${s.name}\t${s.status}`);
      }
    }
  })
  .parseAsync();

// Agent: `mycli list` → 50,000 rows → context budget gone
```

**Correct (default --limit 50; --all or larger --limit opts into more):**

```typescript
import { Command } from 'commander';

new Command()
  .name('list')
  .option('--limit <n>', 'max records to return (default: 50; use --all for all)', '50')
  .option('--all', 'return every record — may be large')
  .option('--json', 'output as NDJSON, one object per line')
  .action(async ({ limit, all, json }) => {
    const n = all ? Infinity : Number(limit);
    const services = await api.listServices({ limit: n });
    const truncated = !all && services.length === Number(limit);

    for (const s of services) {
      if (json) console.log(JSON.stringify(s));
      else console.log(`${s.name}\t${s.status}`);
    }
    if (truncated) {
      console.error(`(showing first ${limit}; pass --limit <n> or --all for more)`);
    }
  })
  .parseAsync();

// Agent: `mycli list` → 50 rows + truncation hint on stderr
// Agent: `mycli list --limit 500` → 500 rows
// Agent: `mycli list --all --json` → streams everything
```

**Benefits:**
- Default invocation fits in the agent's context window every time
- Truncation hint on stderr teaches the agent how to ask for more
- `--all` requires an explicit opt-in for the expensive case — no accidents
- Plays well with [`output-ndjson-streaming`](output-ndjson-streaming.md) for the `--all --json` case

**When NOT to use this pattern:**
- Commands that always return a bounded small set by design (`mycli service show`, `mycli config list`) — limits add noise without benefit
- Count commands (`mycli service count`) where a number IS the whole answer

Reference: [gh CLI — List command pagination](https://cli.github.com/manual/gh_pr_list)
