---
title: Never Fall Back to a Prompt When a Flag Is Missing
impact: MEDIUM-HIGH
impactDescription: prevents silent hangs when TTY detection misfires
tags: input, no-prompt, fail-fast, tty
---

## Never Fall Back to a Prompt When a Flag Is Missing

TTY detection is imperfect — tmux, VS Code terminals, pty harnesses, and some CI runners all present as TTYs even when no human is watching. A CLI that falls back to a prompt on missing flags "because it looks interactive" can hang agents forever. The universally safe rule: if a required flag is missing AND the caller has not explicitly opted into prompts (via a flag like `--interactive`), error immediately with an example. Prompts must be explicitly opt-in, never implicit.

**Incorrect (prompt fallback triggered by TTY detection alone):**

```typescript
import { Command } from 'commander';
import inquirer from 'inquirer';

new Command()
  .name('deploy')
  .option('--env <env>')
  .action(async ({ env }) => {
    // BUG: tmux and VS Code terminals both report isTTY=true;
    // agent hangs here forever
    if (!env && process.stdin.isTTY) {
      const answers = await inquirer.prompt([
        { name: 'env', type: 'input', message: 'Environment?' },
      ]);
      env = answers.env;
    }
    await runDeploy(env);
  })
  .parseAsync();
```

**Correct (prompt fallback requires explicit --interactive opt-in):**

```typescript
import { Command } from 'commander';
import inquirer from 'inquirer';

new Command()
  .name('deploy')
  .option('--env <env>')
  .option('--interactive', 'prompt for missing values (TTY only)')
  .action(async ({ env, interactive }) => {
    if (!env) {
      if (interactive && process.stdin.isTTY) {
        const answers = await inquirer.prompt([
          { name: 'env', type: 'input', message: 'Environment?' },
        ]);
        env = answers.env;
      } else {
        console.error('Error: --env is required.');
        console.error('  deploy --env staging');
        console.error('  deploy --interactive   (then answer prompts)');
        process.exit(2);
      }
    }
    await runDeploy(env);
  })
  .parseAsync();
```

**Benefits:**
- Default path never hangs, regardless of TTY detection accuracy
- `--interactive` is a clear, searchable signal in logs and history
- Error message teaches the fix without re-reading `--help`

Reference: [clig.dev — Do not create implicit interactive behaviour](https://clig.dev/#interactivity)
