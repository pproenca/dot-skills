---
title: Replace Arrow-Key Menus with Flag-Selected Choices
impact: CRITICAL
impactDescription: prevents blocking on inputs agents cannot produce
tags: interact, menus, choices, non-interactive
---

## Replace Arrow-Key Menus with Flag-Selected Choices

Arrow-key selection widgets (inquirer's `list` type, `enquirer.Select`, `promptui.Select`, blessed, terminal TUIs) require raw-mode keystrokes that agents cannot synthesize. The fix is: every menu choice must ALSO be reachable through a flag value, and the menu must appear only behind an explicit `--interactive` opt-in — not implicitly on missing flags. This aligns with [`input-no-prompt-fallback`](input-no-prompt-fallback.md): tmux and pty harnesses report `isTTY === true` even when no human is watching, so TTY detection alone is not enough to gate a menu safely.

**Incorrect (region selection is menu-only):**

```typescript
import inquirer from 'inquirer';

async function selectRegion(): Promise<string> {
  // Agent cannot send arrow-key input to this prompt
  const { region } = await inquirer.prompt({
    name: 'region',
    type: 'list',
    message: 'Pick a region:',
    choices: ['us-east-1', 'eu-west-1', 'ap-southeast-2'],
  });
  return region;
}
```

**Correct (flag is authoritative; menu only behind explicit --interactive):**

```typescript
import inquirer from 'inquirer';

const VALID_REGIONS = ['us-east-1', 'eu-west-1', 'ap-southeast-2'];

async function selectRegion(
  flagValue: string | undefined,
  interactive: boolean,
): Promise<string> {
  if (flagValue) {
    if (!VALID_REGIONS.includes(flagValue)) {
      throw new Error(
        `Invalid region '${flagValue}'. Valid: ${VALID_REGIONS.join(', ')}`
      );
    }
    return flagValue;
  }
  if (!interactive || !process.stdin.isTTY) {
    throw new Error(
      `--region is required.\n` +
      `  Valid values: ${VALID_REGIONS.join(', ')}\n` +
      `  mycli deploy --region us-east-1\n` +
      `  mycli deploy --interactive   # pick from a menu at a TTY`
    );
  }
  const { region } = await inquirer.prompt({
    name: 'region',
    type: 'list',
    choices: VALID_REGIONS,
  });
  return region;
}
```

Reference: [clig.dev — Interactivity fallback](https://clig.dev/#interactivity)
