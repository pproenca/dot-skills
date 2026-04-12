---
title: Avoid Catch-All Handlers for Unknown Subcommands
impact: MEDIUM
impactDescription: prevents locking in support for every typo forever
tags: struct, subcommands, unknown, suggestions
---

## Avoid Catch-All Handlers for Unknown Subcommands

If `mycli foo` quietly falls through to some default handler when `foo` isn't a known subcommand, you've accidentally promised to keep that behavior working forever. You've also made error messages ambiguous — did the agent mean to run `foo` or typo `food`? The right behavior is: fail immediately on unknown subcommands with a "did you mean..." suggestion. This lets you add new subcommands without worrying about collision, and gives agents a fast, unambiguous fix.

**Incorrect (unknown subcommands silently fall through to a default):**

```typescript
import { Command } from 'commander';

const program = new Command('mycli');
program.command('service <op>').action(handleService);
program.command('logs').action(handleLogs);

program
  .action((cmd) => {
    // Catch-all: agent typos `mycli deplpy` → this runs the default "apply"
    console.log('applying default config...');
    applyDefault();
  })
  .parseAsync();
```

**Correct (unknown subcommand errors with a suggestion):**

```typescript
import { Command } from 'commander';
import { closest } from 'fastest-levenshtein';

const program = new Command('mycli');
program.command('service <op>').action(handleService);
program.command('logs').action(handleLogs);
program.command('deploy').action(handleDeploy);

program.exitOverride();

try {
  await program.parseAsync();
} catch (err: any) {
  if (err.code === 'commander.unknownCommand') {
    const attempted = process.argv[2];
    const known = ['service', 'logs', 'deploy'];
    const suggestion = closest(attempted, known);
    console.error(`Error: unknown command '${attempted}'.`);
    console.error(`  Did you mean '${suggestion}'?`);
    console.error(`  mycli --help`);
    process.exit(2);
  }
  throw err;
}
```

**Benefits:**
- New subcommands can be added without worrying about masking existing behavior
- Typos get a one-line fix instead of a surprise side effect
- `exit code 2` tells the agent "don't retry — fix the command"

Reference: [clig.dev — Never add catch-all subcommands](https://clig.dev/#future-proofing)
