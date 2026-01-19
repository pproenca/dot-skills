---
title: Write Descriptive Package Metadata
impact: LOW
impactDescription: 3-5x better search ranking in registry
tags: pkg, metadata, description, keywords
---

## Write Descriptive Package Metadata

Write clear descriptions and keywords in codemod.yaml. Good metadata helps users find your codemod in registry search.

**Incorrect (minimal metadata):**

```yaml
# codemod.yaml - unhelpful
schema_version: "1.0"
name: my-codemod
version: "1.0.0"
# No description, author, keywords
# Users can't tell what it does
```

**Correct (comprehensive metadata):**

```yaml
# codemod.yaml - discoverable
schema_version: "1.0"
name: "@myorg/react-18-to-19"
version: "1.0.0"
description: |
  Migrates React 18 applications to React 19.
  Handles: useEffect cleanup, Suspense boundaries,
  Server Components imports, and deprecated API removal.
author: "Team Name <team@example.com>"
license: "MIT"
category: "migration"

targets:
  languages:
    - TypeScript
    - JavaScript
  frameworks:
    - React

keywords:
  - upgrade
  - breaking-change
  - v18-to-v19
  - react
  - server-components
  - suspense

repository:
  url: "https://github.com/myorg/codemods"
  directory: "packages/react-18-to-19"
```

**Keyword best practices:**
- Include version tags: `v18-to-v19`
- Include transformation type: `upgrade`, `migration`
- Include framework name: `react`, `nextjs`
- Include specific features: `server-components`, `suspense`

**Registry discoverability:**

```bash
# Good keywords enable search
npx codemod search "react 19 upgrade"
# Finds: @myorg/react-18-to-19

npx codemod search "server components migration"
# Also finds: @myorg/react-18-to-19
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)
