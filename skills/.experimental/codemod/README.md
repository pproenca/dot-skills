# Codemod Best Practices

Best practices for writing efficient, safe, and maintainable code transformations with Codemod (JSSG, ast-grep, workflows).

## Overview

This skill provides 48 rules across 11 categories to help you write better codemods:

| Impact | Categories |
|--------|------------|
| CRITICAL | AST Understanding, Pattern Efficiency, Parsing Strategy |
| HIGH | Node Traversal, Semantic Analysis |
| MEDIUM-HIGH | Edit Operations, Workflow Design |
| MEDIUM | Testing Strategy, State Management |
| LOW-MEDIUM/LOW | Security, Package Structure |

## Structure

```
codemod/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   └── {prefix}-*.md     # Individual rules (48 total)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

```bash
# Install dependencies (if modifying this skill)
pnpm install

# Install codemod CLI
npm install -g codemod

# Initialize a new codemod project
npx codemod init

# Build this skill (if modifying)
pnpm build

# Validate this skill
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category from `references/_sections.md`
2. Create a new file: `references/{prefix}-{description}.md`
3. Follow the template in `assets/templates/_template.md`
4. Run validation to check formatting

| Category | Prefix | When to Use |
|----------|--------|-------------|
| AST Understanding | `ast-` | AST structure, tree-sitter concepts |
| Pattern Efficiency | `pattern-` | Pattern syntax, matching optimization |
| Parsing Strategy | `parse-` | Parser selection, language handling |
| Node Traversal | `traverse-` | Navigation, search optimization |
| Semantic Analysis | `semantic-` | Cross-file analysis, symbol resolution |
| Edit Operations | `edit-` | Code modification, formatting |
| Workflow Design | `workflow-` | YAML configuration, orchestration |
| Testing Strategy | `test-` | Fixtures, validation approaches |
| State Management | `state-` | Progress tracking, resumability |
| Security | `security-` | Capabilities, permissions |
| Package Structure | `pkg-` | Metadata, organization |

## Rule File Structure

```markdown
---
title: Rule Title in Imperative Form
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "10x speedup")
tags: prefix, keyword1, keyword2
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`typescript
// Code example showing the problem
\`\`\`

**Correct (what's right):**

\`\`\`typescript
// Code example showing the solution
\`\`\`

Reference: [Link](URL)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars) from `_sections.md`
- `description`: Kebab-case description of the rule

Examples:
- `ast-explore-before-writing.md`
- `pattern-avoid-overly-generic.md`
- `workflow-use-matrix-for-parallelism.md`

## Impact Levels

| Level | Definition | Examples |
|-------|------------|----------|
| CRITICAL | Foundational issues that cascade through entire pipeline | Wrong parser, inefficient patterns |
| HIGH | Significant performance or correctness impact | Traversal optimization, semantic analysis |
| MEDIUM-HIGH | Important for reliability and maintainability | Edit batching, workflow design |
| MEDIUM | Good practices that prevent common issues | Testing, state management |
| LOW-MEDIUM | Security and safety considerations | Capabilities, input validation |
| LOW | Organization and discoverability | Package structure, metadata |

## Scripts

```bash
# Validate skill structure
node ../../scripts/validate-skill.js ./

# Build AGENTS.md from references
node ../../scripts/build-agents-md.js ./
```

## Contributing

1. Follow the rule template exactly
2. Ensure examples are production-realistic
3. Quantify impact where possible
4. Include authoritative references
5. Run validation before submitting

## Acknowledgments

Based on official Codemod documentation and community best practices:
- [Codemod Documentation](https://docs.codemod.com)
- [ast-grep Guide](https://ast-grep.github.io)
- [Martin Fowler - Codemods for API Refactoring](https://martinfowler.com/articles/codemods-api-refactoring.html)
