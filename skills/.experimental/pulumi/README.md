# Pulumi Best Practices

A comprehensive guide to Pulumi infrastructure as code best practices, optimized for AI agents and LLMs. This skill contains 46 rules across 8 categories, covering state management, resource graph optimization, component design, secrets handling, stack organization, lifecycle management, testing, and CI/CD automation.

## Overview

This skill provides performance and reliability guidelines for Pulumi infrastructure as code projects. Rules are prioritized by impact level and organized by the Pulumi execution lifecycle.

### Structure

```
pulumi/
├── SKILL.md              # Quick reference and navigation
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and reference information
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── state-*.md        # State management rules (CRITICAL)
    ├── graph-*.md        # Resource graph rules (CRITICAL)
    ├── comp-*.md         # Component design rules (HIGH)
    ├── secrets-*.md      # Secrets handling rules (HIGH)
    ├── stack-*.md        # Stack organization rules (MEDIUM-HIGH)
    ├── lifecycle-*.md    # Lifecycle options rules (MEDIUM)
    ├── test-*.md         # Testing rules (MEDIUM)
    └── auto-*.md         # Automation rules (LOW-MEDIUM)
```

## Getting Started

### Installation

```bash
# Install dependencies (if using build scripts)
pnpm install

# Build the AGENTS.md file
pnpm build

# Validate the skill
pnpm validate
```

### Usage

Reference rules when writing or reviewing Pulumi code:

1. Read `SKILL.md` for quick reference
2. Read individual rules in `rules/` for detailed guidance
3. Read `AGENTS.md` for the complete compiled guide

## Creating a New Rule

1. Identify the appropriate category from `rules/_sections.md`
2. Create a new file: `rules/{prefix}-{description}.md`
3. Use the standard rule template (see below)
4. Rebuild `AGENTS.md` with `pnpm build`

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `state-` | State Management and Backend | CRITICAL |
| `graph-` | Resource Graph Optimization | CRITICAL |
| `comp-` | Component Design | HIGH |
| `secrets-` | Secrets and Configuration | HIGH |
| `stack-` | Stack Organization | MEDIUM-HIGH |
| `lifecycle-` | Resource Options and Lifecycle | MEDIUM |
| `test-` | Testing and Validation | MEDIUM |
| `auto-` | Automation and CI/CD | LOW-MEDIUM |

## Rule File Structure

Each rule file follows this template:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "10-50× faster", "prevents data loss")
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this rule matters (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`typescript
// Bad code example with comments explaining the cost
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Good code example with comments explaining the benefit
\`\`\`

Reference: [Documentation Link](https://url)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (see Prefix Reference above)
- `description`: Kebab-case description of the rule

Examples:
- `state-backend-selection.md`
- `graph-parallel-resources.md`
- `comp-component-resources.md`
- `secrets-use-secret-config.md`

## Impact Levels

| Level | Description | Typical Improvement |
|-------|-------------|---------------------|
| CRITICAL | Deployment blockers, data loss risks | 10-50× or prevents failures |
| HIGH | Major performance or reliability issues | 2-10× improvement |
| MEDIUM-HIGH | Significant maintainability impact | Reduced complexity, faster reviews |
| MEDIUM | Important best practices | 20-50% improvement |
| LOW-MEDIUM | Incremental improvements | 10-20% improvement |
| LOW | Nice-to-have optimizations | Marginal gains |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Check skill against quality guidelines |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify rules following the template
4. Run `pnpm validate` to check for errors
5. Submit a pull request

### Guidelines

- Rules must include both incorrect and correct examples
- Examples should use realistic code (no `foo`, `bar`, `baz`)
- Impact must be quantified where possible
- First tag must match the category prefix
- Reference authoritative sources (Pulumi docs, engineering blogs)

## Acknowledgments

- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [Pulumi Blog](https://www.pulumi.com/blog/)
- [Pulumi Community](https://www.pulumi.com/community/)
