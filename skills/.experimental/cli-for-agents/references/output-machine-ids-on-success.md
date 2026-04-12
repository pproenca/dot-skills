---
title: Return Chainable Values on Success, Not Just "Done"
impact: MEDIUM-HIGH
impactDescription: prevents round-trip lookups for IDs/URLs of just-created resources
tags: output, ids, chaining, success
---

## Return Chainable Values on Success, Not Just "Done"

"Done ✓" is decorative — it tells the agent nothing it can pass to the next command. On every state-changing operation (create, deploy, start), return the values the agent is most likely to need next: IDs, URLs, durations, counts. This turns a command from a dead-end into a workflow step that feeds naturally into its successors, without requiring a follow-up "where did it go?" lookup.

**Incorrect (success output is a single word):**

```typescript
import { Command } from 'commander';

new Command()
  .name('deploy')
  .requiredOption('--env <env>')
  .requiredOption('--tag <tag>')
  .action(async ({ env, tag }) => {
    const result = await api.deploy(env, tag);
    console.log('Done.');
    // Agent: "done with what? where is it? how do I verify?"
  })
  .parseAsync();
```

**Correct (success output includes every chainable value):**

```typescript
import { Command } from 'commander';

new Command()
  .name('deploy')
  .requiredOption('--env <env>')
  .requiredOption('--tag <tag>')
  .option('--json', 'output as JSON')
  .action(async ({ env, tag, json }) => {
    const start = Date.now();
    const result = await api.deploy(env, tag);
    const duration = Date.now() - start;

    if (json) {
      console.log(JSON.stringify({
        deploy_id: result.id,
        url: result.url,
        env,
        tag,
        duration_ms: duration,
      }));
      return;
    }
    console.log(`deployed ${tag} to ${env}`);
    console.log(`deploy_id: ${result.id}`);
    console.log(`url:       ${result.url}`);
    console.log(`duration:  ${(duration / 1000).toFixed(1)}s`);
    console.log('');
    console.log(`Next: mycli deploy verify --id ${result.id}`);
  })
  .parseAsync();
```

**Benefits:**
- Agent extracts `deploy_id` from the first command and uses it in the second
- JSON mode supports `$(mycli deploy --json | jq -r .deploy_id)` chaining
- "Next:" hint teaches the most likely follow-up command

Reference: [clig.dev — If you change state, tell the user](https://clig.dev/#output)
