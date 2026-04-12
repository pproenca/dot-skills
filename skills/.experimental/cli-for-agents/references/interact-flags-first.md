---
title: Express Every Input as a Flag First
impact: CRITICAL
impactDescription: prevents indefinite hangs in headless environments
tags: interact, flags, non-interactive, automation
---

## Express Every Input as a Flag First

Agents cannot answer prompts, pick from arrow-key menus, or send keystrokes to a running process. A CLI that collects its primary inputs through interactive questions is fundamentally unusable headlessly — no amount of downstream quality matters. Flags-first design means: every input is a flag, missing required flags error immediately with a fix, and interactive prompts only appear behind an explicit `--interactive` opt-in (see [`input-no-prompt-fallback`](input-no-prompt-fallback.md)) — never as an implicit fallback.

**Incorrect (inquirer prompts are the only way to pass input):**

```typescript
import { Command } from 'commander';
import inquirer from 'inquirer';

new Command()
  .name('deploy')
  .action(async () => {
    // Agent runs `deploy` and hangs forever on this prompt
    const { env, tag } = await inquirer.prompt([
      { name: 'env', type: 'list', choices: ['staging', 'production'] },
      { name: 'tag', type: 'input', message: 'Image tag?' },
    ]);
    await runDeploy(env, tag);
  })
  .parseAsync();
```

**Correct (flags are required; errors are actionable; no implicit prompt):**

```typescript
import { Command } from 'commander';

const program = new Command()
  .name('deploy')
  .requiredOption('--env <env>', 'target environment (staging|production)')
  .requiredOption('--tag <tag>', 'image tag to deploy')
  .action(async ({ env, tag }) => {
    await runDeploy(env, tag);
  });

program.exitOverride((err) => {
  if (err.code === 'commander.missingMandatoryOptionValue') {
    console.error(`Error: ${err.message}`);
    console.error('  deploy --env staging --tag v1.2.3');
    console.error('  deploy --env production --tag $(mycli build --output tag-only)');
    process.exit(2);
  }
  throw err;
});

await program.parseAsync();
```

**When NOT to use this pattern:**
- REPLs and shells (`python`, `bash`, `irb`) whose primary purpose IS interactive input
- Scaffolding wizards invoked explicitly for their wizardness (`npm init`, `create-react-app`)
- TUI editors and dashboards (`htop`, `vim`) where keyboard input is the feature
- In all three cases, the tool should still accept flags for scripted use (`npm init -y`, `vim -c :q`) but interactive input is the primary mode by design

Reference: [clig.dev — Interactivity](https://clig.dev/#interactivity)
