---
title: Accept Secrets Through stdin or File, Never as Flag Values
impact: HIGH
impactDescription: prevents secret leakage into ps output, shell history, and logs
tags: input, secrets, security, stdin
---

## Accept Secrets Through stdin or File, Never as Flag Values

A secret passed as `--token=sk_live_abc123` leaks into the process table (`ps auxf`), shell history (`~/.bash_history`), systemd journal, shell prompts, error logs, and sometimes CI/CD run logs. Secrets must come from either stdin (`echo $TOKEN | mycli login --token-stdin`) or a file (`--token-file ~/.mycli/token`). Never accept secrets as flag values — not even with a warning — because agents will follow the `--help` example and leak them.

**Incorrect (token flag visible in ps and history):**

```typescript
import { Command } from 'commander';

new Command()
  .name('login')
  .requiredOption('--token <token>', 'API token')
  .action(async ({ token }) => {
    // `ps auxf` shows: mycli login --token sk_live_abc123
    // `history` shows: mycli login --token sk_live_abc123
    await saveCredentials(token);
  })
  .parseAsync();
```

**Correct (read from stdin or a file; flag value never accepted):**

```typescript
import { Command } from 'commander';
import { readFile } from 'node:fs/promises';

async function readStdin(): Promise<string> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) chunks.push(chunk as Buffer);
  return Buffer.concat(chunks).toString('utf8').trim();
}

new Command()
  .name('login')
  .option('--token-stdin', 'read token from stdin')
  .option('--token-file <path>', 'read token from file')
  .action(async ({ tokenStdin, tokenFile }) => {
    let token: string;
    if (tokenStdin) {
      token = await readStdin();
    } else if (tokenFile) {
      token = (await readFile(tokenFile, 'utf8')).trim();
    } else {
      console.error('Error: pass --token-stdin or --token-file <path>.');
      console.error('  echo "$TOKEN" | mycli login --token-stdin');
      console.error('  mycli login --token-file ~/.mycli/token');
      process.exit(2);
    }
    if (!token) {
      console.error('Error: token is empty.');
      process.exit(2);
    }
    await saveCredentials(token);
  })
  .parseAsync();
```

**Benefits:**
- Nothing sensitive appears in `ps`, history, or logs
- Follows the same pattern as `docker login --password-stdin`, `gh auth login --with-token`
- File-based secrets can be managed by the OS secret store or a secrets manager

Reference: [clig.dev — Never require secrets on the command line](https://clig.dev/#configuration)
