# WXT Browser Extensions Best Practices Skill

A comprehensive performance optimization guide for WXT browser extension development, containing 49 rules across 8 categories. Updated for WXT v0.20+.

## Overview/Structure

```
wxt-browser-extensions/
├── SKILL.md              # Entry point with quick reference
├── README.md             # This file
├── metadata.json         # Version, org, references
├── references/
│   ├── _sections.md      # Category definitions
│   ├── svc-*.md          # Service Worker Lifecycle (6 rules)
│   ├── inject-*.md       # Content Script Injection (7 rules)
│   ├── msg-*.md          # Messaging Architecture (6 rules)
│   ├── store-*.md        # Storage Patterns (6 rules)
│   ├── bundle-*.md       # Bundle Optimization (5 rules)
│   ├── manifest-*.md     # Manifest Configuration (5 rules)
│   ├── ui-*.md           # UI Performance (6 rules)
│   └── ts-*.md           # TypeScript Patterns (8 rules)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building

```bash
pnpm build
```

### Validation

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on the rule's focus area
2. Create a new file in `references/` with the category prefix
3. Use the template in `assets/templates/_template.md`
4. Add an entry to SKILL.md under the appropriate category

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `svc-` | Service Worker Lifecycle | CRITICAL |
| `inject-` | Content Script Injection | CRITICAL |
| `msg-` | Messaging Architecture | HIGH |
| `store-` | Storage Patterns | HIGH |
| `bundle-` | Bundle Optimization | MEDIUM-HIGH |
| `manifest-` | Manifest Configuration | MEDIUM |
| `ui-` | UI Performance | MEDIUM |
| `ts-` | TypeScript Patterns | LOW-MEDIUM |

## Rule File Structure

Each rule file must include:

```markdown
---
title: Rule Title (imperative verb form)
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: category-prefix, technique, related-concepts
---

## Rule Title

Brief explanation (1-3 sentences) of WHY this matters.

**Incorrect (description of problem):**

\`\`\`typescript
// Code showing anti-pattern
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Code showing correct pattern
\`\`\`

Reference: [Source](https://example.com)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars)
- `description`: Kebab-case description of the rule

Examples:
- `svc-register-listeners-synchronously.md`
- `inject-use-main-function.md`
- `msg-return-true-for-async.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Major performance issues, data loss risks, or broken functionality |
| HIGH | Significant performance impact or reliability issues |
| MEDIUM-HIGH | Noticeable performance or maintenance benefits |
| MEDIUM | Moderate improvements or best practices |
| LOW-MEDIUM | Minor optimizations or code quality improvements |
| LOW | Micro-optimizations or stylistic preferences |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm validate` | Validate skill structure and content |
| `pnpm build` | Generate AGENTS.md from rules |

## Contributing

1. Follow the rule template exactly
2. Ensure impact descriptions are quantified
3. Include both incorrect and correct code examples
4. Use production-realistic code (no foo/bar/baz)
5. Run validation before submitting

## Acknowledgments

- [WXT Documentation](https://wxt.dev)
- [Chrome Extensions Documentation](https://developer.chrome.com/docs/extensions/)
- [webext-core](https://webext-core.aklinker1.io/)
