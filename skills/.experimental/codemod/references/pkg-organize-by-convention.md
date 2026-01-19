---
title: Organize Package by Convention
impact: LOW
impactDescription: enables tooling support and contributor onboarding
tags: pkg, structure, organization, convention
---

## Organize Package by Convention

Follow the standard codemod package structure. Consistent organization enables tooling support and helps contributors navigate.

**Incorrect (ad-hoc structure):**

```text
my-codemod/
├── transform.js        # Where are tests?
├── config.json         # Non-standard config
└── utils/              # Unclear purpose
    └── helper.js
```

**Correct (standard structure):**

```text
my-codemod/
├── codemod.yaml          # Package metadata
├── workflow.yaml         # Workflow definition
├── scripts/              # JSSG transform files
│   ├── main.ts
│   └── helpers/
│       └── patterns.ts
├── rules/                # YAML ast-grep rules
│   └── deprecated-api.yaml
├── tests/                # Test fixtures
│   ├── basic-case/
│   │   ├── input.tsx
│   │   └── expected.tsx
│   └── edge-case/
│       ├── input.tsx
│       └── expected.tsx
├── README.md             # Usage documentation
└── CHANGELOG.md          # Version history
```

**Directory purposes:**

| Directory | Purpose |
|-----------|---------|
| `scripts/` | TypeScript/JavaScript transforms (JSSG) |
| `rules/` | Declarative YAML ast-grep rules |
| `tests/` | Input/expected fixture pairs |
| Root | Metadata and documentation |

**Workflow referencing:**

```yaml
# workflow.yaml
version: "1"
nodes:
  - id: transform
    steps:
      - type: js-ast-grep
        codemod: ./scripts/main.ts  # Relative to package root

      - type: ast-grep
        rule: ./rules/deprecated-api.yaml
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)
