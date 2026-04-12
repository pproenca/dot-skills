---
title: Require Typing the Resource Name for Irreversible Actions
impact: HIGH
impactDescription: prevents muscle-memory past safe-by-default y/N prompts
tags: safe, confirmation, severe, irreversible
---

## Require Typing the Resource Name for Irreversible Actions

`y/N` prompts are easy to muscle-memory past, and easy for an agent to accidentally satisfy with a badly-parameterized `--yes` flag. For severe, irreversible actions — delete production database, drop table, destroy cluster — require the caller to type (or pass via `--confirm=`) the resource name. This escalates friction to match blast radius and makes accidental confirmation nearly impossible.

**Incorrect (simple yes/no for a production-db drop):**

```typescript
import { Command } from 'commander';
import inquirer from 'inquirer';

new Command()
  .name('db:drop')
  .requiredOption('--database <name>')
  .action(async ({ database }) => {
    const { ok } = await inquirer.prompt({
      name: 'ok', type: 'confirm', message: `Drop ${database}?`,
    });
    if (ok) await dropDatabase(database);
  })
  .parseAsync();
```

**Correct (require typing the database name, verified against --database):**

```typescript
import { Command } from 'commander';
import inquirer from 'inquirer';

new Command()
  .name('db:drop')
  .requiredOption('--database <name>', 'database to drop')
  .option('--confirm <name>', 'must match --database for severe actions')
  .action(async ({ database, confirm }) => {
    if (confirm !== database) {
      if (!process.stdin.isTTY) {
        console.error(`Error: --confirm='${database}' is required to drop '${database}'.`);
        console.error(`  mycli db:drop --database ${database} --confirm ${database}`);
        process.exit(2);
      }
      const { typed } = await inquirer.prompt({
        name: 'typed', type: 'input',
        message: `Type the database name to confirm drop:`,
      });
      if (typed !== database) {
        console.error('Aborted: name did not match.');
        process.exit(1);
      }
    }
    await dropDatabase(database);
  })
  .parseAsync();
```

**When NOT to use this pattern:**
- Routine writes (create, update, small-file delete) are safer with a simple `--yes`
- Read-only commands never need confirmation at all

Reference: [clig.dev — Severe actions require typing the resource name](https://clig.dev/#robustness)
