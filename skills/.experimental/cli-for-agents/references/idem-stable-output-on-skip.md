---
title: Return the Same Output Shape Whether Acting or Skipping
impact: MEDIUM
impactDescription: prevents downstream parser branching on did-anything-happen
tags: idem, output, stable, parsing
---

## Return the Same Output Shape Whether Acting or Skipping

When `deploy` creates a new deployment, it returns `{id, url, env, tag}`. When the same command is a no-op because the desired state is already present, it should return the SAME fields — populated from the existing resource — not a different "nothing to do" shape. Agents parsing the output can then use `.id` and `.url` in the next command without branching on "did something happen this time?"

**Incorrect (different output shape for "already applied"):**

```javascript
#!/usr/bin/env node
const { Command } = require('commander');

new Command()
  .name('apply')
  .requiredOption('--name <name>')
  .option('--json', 'output as JSON')
  .action(async ({ name, json }) => {
    const existing = await api.find(name);
    if (existing) {
      // Shape A: just a message
      if (json) console.log(JSON.stringify({ skipped: true }));
      else console.log(`${name} already exists — skipped`);
      return;
    }
    const created = await api.create(name);
    // Shape B: the real record
    if (json) console.log(JSON.stringify({ id: created.id, url: created.url }));
    else console.log(`created ${name}: ${created.id}`);
  })
  .parseAsync();

// Agent: `mycli apply --json | jq -r .id` → null on the second run
```

**Correct (same fields either way; `changed` signals which branch ran):**

```javascript
#!/usr/bin/env node
const { Command } = require('commander');

new Command()
  .name('apply')
  .requiredOption('--name <name>')
  .option('--json', 'output as JSON')
  .action(async ({ name, json }) => {
    const existing = await api.find(name);
    const resource = existing ?? await api.create(name);
    const changed = !existing;

    if (json) {
      console.log(JSON.stringify({
        id: resource.id,
        url: resource.url,
        name: resource.name,
        changed,
      }));
    } else {
      console.log(`${changed ? 'created' : 'unchanged'} ${name}`);
      console.log(`id:  ${resource.id}`);
      console.log(`url: ${resource.url}`);
    }
  })
  .parseAsync();

// Agent: `mycli apply --json | jq -r .id` → real ID on every run
```

**Benefits:**
- Downstream commands work on both first and subsequent runs
- `changed: true|false` lets agents still branch on "did work happen" when needed
- Matches Terraform/Ansible's `changed` convention

Reference: [Ansible — Check mode and changed return values](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html)
