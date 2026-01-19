---
title: Validate External Inputs Before Use
impact: LOW-MEDIUM
impactDescription: prevents injection attacks from malicious input
tags: security, validation, input, sanitization
---

## Validate External Inputs Before Use

When codemods accept external input (parameters, config files), validate before use. Untrusted input can cause injection attacks.

**Incorrect (unsanitized parameter use):**

```typescript
const transform: Transform<TSX> = async (root, options) => {
  const targetModule = options.params?.module;

  // Direct use of user input in pattern - dangerous!
  const matches = root.findAll({
    rule: { pattern: `import { $$$NAMES } from "${targetModule}"` }
  });

  // User input in shell command - injection vulnerability!
  const { execSync } = await import("child_process");
  execSync(`npm info ${targetModule}`);  // Dangerous!

  return null;
};
```

**Correct (validated inputs):**

```typescript
const transform: Transform<TSX> = async (root, options) => {
  const targetModule = options.params?.module;

  // Validate module name format
  if (!targetModule || !/^[@a-z0-9\-\/]+$/i.test(targetModule)) {
    console.error(`Invalid module name: ${targetModule}`);
    return null;
  }

  // Safe to use in pattern after validation
  const matches = root.findAll({
    rule: { pattern: `import { $$$NAMES } from "${targetModule}"` }
  });

  // Escape for shell if needed
  const safeModule = targetModule.replace(/[^a-zA-Z0-9@\/-]/g, "");
  const { execSync } = await import("child_process");
  execSync(`npm info "${safeModule}"`);  // Quoted and sanitized

  return null;
};
```

**Input validation patterns:**
- Module names: `/^[@a-z0-9\-\/]+$/i`
- File paths: Resolve and check within project root
- Identifiers: `/^[a-zA-Z_][a-zA-Z0-9_]*$/`
- Always escape shell arguments

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)
