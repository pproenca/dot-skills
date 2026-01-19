---
title: Minimize Requested Capabilities
impact: LOW-MEDIUM
impactDescription: reduces attack surface for untrusted codemods
tags: security, capabilities, permissions, least-privilege
---

## Minimize Requested Capabilities

JSSG uses deny-by-default security. Only request capabilities your codemod actually needs. Each capability expands the attack surface.

**Incorrect (requesting all capabilities):**

```yaml
# codemod.yaml - over-permissioned
schema_version: "1.0"
name: simple-rename
capabilities:
  - fs           # Not needed for simple AST transform
  - fetch        # Not needed
  - child_process # Definitely not needed!
```

```typescript
// Transform doesn't use any capabilities
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "oldName" }
  });
  const edits = matches.map(m => m.replace("newName"));
  return root.commitEdits(edits);
};
```

**Correct (minimal capabilities):**

```yaml
# codemod.yaml - least-privilege
schema_version: "1.0"
name: simple-rename
# No capabilities needed for pure AST transforms
# capabilities: []  (implicit)
```

```yaml
# codemod.yaml - only what's needed
schema_version: "1.0"
name: config-migrator
capabilities:
  - fs  # Only fs, needed to read config file
# No fetch or child_process
```

**When each capability is needed:**
- `fs` - Reading config files, writing reports
- `fetch` - Downloading schemas, API validation
- `child_process` - Running external tools (rare)

**CLI equivalent:**

```bash
# Only enable specific capability
npx codemod jssg run ./transform.ts ./src --allow-fs
# NOT: --allow-fs --allow-fetch --allow-child-process
```

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)
