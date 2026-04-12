---
title: Exit Fast on Missing Required Flags
impact: HIGH
impactDescription: prevents wasted wall-clock on every retry
tags: err, validation, fail-fast, required-flags
---

## Exit Fast on Missing Required Flags

Validation of required flags must happen at argument-parse time, before any setup runs. A CLI that spends 20 seconds pulling credentials and building a deploy plan, then errors out with "missing --tag," burns that 20 seconds on every agent retry. Flag validation is free; runtime setup is not. Fail at parse, not at execution.

**Incorrect (validation happens mid-way through execution):**

```typescript
import { Command } from 'commander';

new Command()
  .name('deploy')
  .option('--env <env>')
  .option('--tag <tag>')
  .action(async ({ env, tag }) => {
    // Expensive setup runs before --tag is even checked
    const creds = await fetchCredentials(env);         // 8s
    const plan = await buildDeployPlan(env, creds);    // 12s
    if (!tag) {
      throw new Error('missing tag');                   // too late
    }
    await executeDeploy(plan, tag);
  })
  .parseAsync();
```

**Correct (requiredOption fails immediately during parse):**

```typescript
import { Command } from 'commander';

new Command()
  .name('deploy')
  .requiredOption('--env <env>', 'target environment')
  .requiredOption('--tag <tag>', 'image tag to deploy')
  .action(async ({ env, tag }) => {
    // Parser already guaranteed env and tag are set
    const creds = await fetchCredentials(env);
    const plan = await buildDeployPlan(env, creds);
    await executeDeploy(plan, tag);
  })
  .exitOverride((err) => {
    if (err.code === 'commander.missingMandatoryOptionValue') {
      console.error(`Error: ${err.message}`);
      console.error('  deploy --env staging --tag v1.2.3');
      process.exit(2);
    }
    throw err;
  })
  .parseAsync();
```

Reference: [clig.dev — Errors should be actionable](https://clig.dev/#errors)
