---
title: Avoid Blocking on stdin When a TTY Is Attached
impact: HIGH
impactDescription: prevents indefinite hangs when no pipe is provided
tags: interact, stdin, hang, piped-input
---

## Avoid Blocking on stdin When a TTY Is Attached

A CLI that reads stdin unconditionally will hang forever when invoked without a pipe: `mycli import` with no `< file.json` sits waiting for input the user never sends. Agents trying to discover the CLI see a frozen process and kill it after a timeout, losing the turn. Either require a file argument, OR check `isTTY` before attempting to read — if stdin is a TTY, print usage and exit instead of blocking.

**Incorrect (reads stdin regardless of whether anything is piped):**

```javascript
#!/usr/bin/env node
const fs = require('fs');

async function main() {
  // Hangs forever if run as `mycli import` with no pipe
  const data = await fs.promises.readFile('/dev/stdin', 'utf8');
  const records = JSON.parse(data);
  await importRecords(records);
}

main();
```

**Correct (detect TTY, print usage instead of blocking):**

```javascript
#!/usr/bin/env node
const fs = require('fs');

async function main() {
  const fileArg = process.argv[2];
  if (fileArg && fileArg !== '-') {
    return importRecords(JSON.parse(await fs.promises.readFile(fileArg, 'utf8')));
  }
  if (process.stdin.isTTY) {
    console.error('Error: no input provided.');
    console.error('  mycli import data.json');
    console.error('  cat data.json | mycli import -');
    process.exit(2);
  }
  const data = await fs.promises.readFile('/dev/stdin', 'utf8');
  await importRecords(JSON.parse(data));
}

main();
```

**When NOT to use this pattern:**
- Tools explicitly designed to read from stdin (e.g., `jq`, `grep`) can block on stdin as their primary mode — but they print usage to stderr when invoked interactively without a pipe.

Reference: [clig.dev — Handle missing stdin gracefully](https://clig.dev/#the-basics)
