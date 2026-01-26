# Vite Best Practices Skill

Comprehensive performance optimization guidelines for Vite applications, designed for AI agents and LLMs.

## Overview

This skill contains **42 rules** across **8 categories**, covering the complete Vite execution lifecycle from development server startup to production builds.

## Categories

| # | Category | Impact | Rules | Focus |
|---|----------|--------|-------|-------|
| 1 | Dependency Pre-bundling | CRITICAL | 6 | optimizeDeps configuration, caching |
| 2 | Plugin Performance | CRITICAL | 5 | Hook optimization, auditing |
| 3 | Bundle Optimization | CRITICAL | 7 | Code splitting, tree-shaking |
| 4 | Import Resolution | HIGH | 5 | Barrel files, extensions, aliases |
| 5 | Build Configuration | HIGH | 6 | Targets, minification, output |
| 6 | Development Server | MEDIUM-HIGH | 5 | Warmup, caching, OS config |
| 7 | CSS Optimization | MEDIUM | 4 | Lightning CSS, modules |
| 8 | Advanced Patterns | LOW-MEDIUM | 4 | SSR, env vars, profiling |

## Getting Started

```bash
# Install dependencies
pnpm install

# Build AGENTS.md from references
pnpm build

# Validate skill structure and content
pnpm validate
```

## Creating a New Rule

1. Create a new file in `references/` with the category prefix
2. Follow the template in `assets/templates/_template.md`
3. Run `pnpm validate` to check for errors
4. Run `pnpm build` to regenerate AGENTS.md

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool
---

## Rule Title

Why this matters (1-3 sentences).

**Incorrect (what's wrong):**
\`\`\`javascript
// Bad code example
\`\`\`

**Correct (what's right):**
\`\`\`javascript
// Good code example
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Rule files use the pattern: `{category-prefix}-{slug}.md`

| Prefix | Category |
|--------|----------|
| `deps-` | Dependency Pre-bundling |
| `plugin-` | Plugin Performance |
| `bundle-` | Bundle Optimization |
| `import-` | Import Resolution |
| `build-` | Build Configuration |
| `dev-` | Development Server |
| `css-` | CSS Optimization |
| `advanced-` | Advanced Patterns |

## Impact Levels

| Level | Description | Examples |
|-------|-------------|----------|
| CRITICAL | Multiplicative performance impact | Waterfalls, pre-bundling |
| HIGH | Significant measurable improvement | Build targets, chunk splitting |
| MEDIUM-HIGH | Noticeable improvement | Server warmup, CSS splitting |
| MEDIUM | Moderate improvement | CSS modules, Lightning CSS |
| LOW-MEDIUM | Incremental improvement | Profiling, library mode |
| LOW | Edge case optimization | Specific scenarios |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Build AGENTS.md from references |
| `pnpm validate` | Validate skill structure and content |

## Contributing

1. Follow the rule file structure exactly
2. Include both **Incorrect** and **Correct** examples
3. Quantify impact where possible (e.g., "2-10× improvement")
4. Use imperative titles ("Use X", "Avoid Y")
5. Reference authoritative sources

## Sources

- [Vite Performance Guide](https://vite.dev/guide/performance)
- [Vite Build Options](https://vite.dev/config/build-options)
- [Vite Dependency Pre-bundling](https://vite.dev/guide/dep-pre-bundling)
- [Lightning CSS](https://lightningcss.dev/docs.html)

## Version

- **Version:** 0.1.0
- **Date:** January 2026
- **Technology:** Vite 6.x
