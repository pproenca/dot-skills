---
title: Use File Filtering for Targeted Rules
impact: MEDIUM
impactDescription: reduces false positives and scan time
tags: org, files, ignores, globs
---

## Use File Filtering for Targeted Rules

Use `files` and `ignores` globs to apply rules only to relevant files. This reduces false positives and improves scan performance.

**Incorrect (applies to all files):**

```yaml
id: react-hooks-rules
language: tsx
rule:
  pattern: useEffect($$$ARGS)
# Runs on all .tsx files including non-React code
```

**Correct (targeted to React components):**

```yaml
id: react-hooks-rules
language: tsx
files:
  - 'src/components/**/*.tsx'
  - 'src/hooks/**/*.tsx'
ignores:
  - '**/*.test.tsx'
  - '**/*.stories.tsx'
rule:
  pattern: useEffect($$$ARGS)
```

**Glob pattern tips:**
- Paths are relative to `sgconfig.yml` location
- Don't use `./` prefix
- Use `**` for recursive matching
- Use `*` for single directory level

**Common filtering patterns:**

```yaml
# Only source files, not tests
files:
  - 'src/**/*.ts'
ignores:
  - '**/*.test.ts'
  - '**/*.spec.ts'
  - '**/__tests__/**'

# Only test files
files:
  - '**/*.test.ts'
  - '**/*.spec.ts'

# Specific directories
files:
  - 'packages/core/**/*.ts'
ignores:
  - '**/node_modules/**'
  - '**/dist/**'
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
