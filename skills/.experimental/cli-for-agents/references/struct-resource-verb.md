---
title: Use a Consistent Resource-Verb Command Shape
impact: MEDIUM
impactDescription: prevents re-reading help for every new subcommand
tags: struct, consistency, shape, subcommands
---

## Use a Consistent Resource-Verb Command Shape

Once an agent learns `mycli service list`, it should be able to guess `mycli deploy list`, `mycli config list`, and `mycli secret list` without re-reading `--help`. Consistent `resource verb` (or the equivalent `verb resource`) structure lets agents generalize one subcommand's shape to all of them — saving tokens, reducing latency, and avoiding guessing-induced errors. Kubernetes (`kubectl get/describe/delete/apply <resource>`), Heroku, and gh all follow this pattern.

**Incorrect (each subcommand invents its own shape):**

```text
mycli list-services                 # verb-resource with dash
mycli config-get KEY                # verb-resource for config
mycli deploy rollback               # resource-verb for deploys
mycli rm-secret NAME                # abbreviated verb-resource
mycli logs tail --service api       # singular-plural inconsistency
```

**Correct (uniform resource-verb structure across all commands):**

```text
mycli service list
mycli service get <name>
mycli service delete <name>

mycli config list
mycli config get <key>
mycli config set <key> <value>

mycli deploy list
mycli deploy rollback <id>

mycli secret list
mycli secret delete <name>

mycli logs tail --service api
```

**Implementation (commander.js nested commands):**

```typescript
import { Command } from 'commander';

const program = new Command('mycli');

const service = program.command('service');
service.command('list').action(listServices);
service.command('get <name>').action(getService);
service.command('delete <name>').action(deleteService);

const config = program.command('config');
config.command('list').action(listConfig);
config.command('get <key>').action(getConfig);
config.command('set <key> <value>').action(setConfig);

program.parse();
```

**Benefits:**
- Agents learn one pattern and apply it across all resources
- New commands slot into the existing shape, no special-casing
- Tab-completion and `--help` are predictable at every level

Reference: [Heroku CLI Style Guide — Naming conventions](https://devcenter.heroku.com/articles/cli-style-guide#naming)
