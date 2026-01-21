# Chrome Extensions Best Practices

A comprehensive performance optimization guide for Chrome Extensions (Manifest V3), designed for AI agents and LLMs.

## Overview

This skill contains 40+ rules across 8 categories, prioritized by impact from critical (service worker lifecycle, content script optimization) to incremental (API usage patterns).

### Structure

```
chrome-extensions/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── sw-*.md           # Service worker rules
│   ├── content-*.md      # Content script rules
│   ├── msg-*.md          # Message passing rules
│   ├── storage-*.md      # Storage operation rules
│   ├── net-*.md          # Network & permissions rules
│   ├── mem-*.md          # Memory management rules
│   ├── ui-*.md           # UI performance rules
│   └── api-*.md          # API usage pattern rules
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Installation

```bash
# Clone the skills repository
git clone <repository-url>
cd chrome-extensions

# Install dependencies (if any validation scripts are used)
pnpm install
```

### Build

```bash
# Build the AGENTS.md compiled document
pnpm build
```

### Validate

```bash
# Validate skill structure and content
pnpm validate
```

## Creating a New Rule

1. Identify the appropriate category from `references/_sections.md`
2. Create a new file using the naming pattern: `{prefix}-{description}.md`
3. Use the template from `assets/templates/_template.md`
4. Add the rule to the quick reference in `SKILL.md`
5. Rebuild `AGENTS.md`

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Service Worker Lifecycle | `sw-` | CRITICAL |
| Content Script Optimization | `content-` | CRITICAL |
| Message Passing Efficiency | `msg-` | HIGH |
| Storage Operations | `storage-` | HIGH |
| Network & Permissions | `net-` | MEDIUM-HIGH |
| Memory Management | `mem-` | MEDIUM |
| UI Performance | `ui-` | MEDIUM |
| API Usage Patterns | `api-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (problem description):**

\`\`\`javascript
// Bad code example
\`\`\`

**Correct (solution description):**

\`\`\`javascript
// Good code example
\`\`\`

Reference: [Source Title](URL)
```

## File Naming Convention

Rule files use the pattern: `{prefix}-{description}.md`

- **prefix**: Category identifier (3-8 lowercase characters)
- **description**: Kebab-case description of the rule

Examples:
- `sw-persist-state-storage.md`
- `content-use-specific-matches.md`
- `msg-debounce-frequent-events.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Fundamental issues causing major performance problems |
| HIGH | Significant impact, should be addressed in most cases |
| MEDIUM-HIGH | Notable impact, recommended to address |
| MEDIUM | Moderate impact, worth considering |
| LOW-MEDIUM | Minor impact, nice to have |
| LOW | Minimal impact, edge case optimizations |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compile all rules into AGENTS.md |
| `pnpm validate` | Validate skill structure and content |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify rules following the template
4. Run validation
5. Submit a pull request

### Guidelines

- Each rule must have incorrect AND correct code examples
- Impact must be quantified where possible
- First tag must be the category prefix
- Code examples should be production-realistic
- Use imperative mood in titles ("Use X" not "Using X")

## Acknowledgments

Based on official documentation from:
- [Chrome Extensions Documentation](https://developer.chrome.com/docs/extensions/)
- [Manifest V3 Migration Guide](https://developer.chrome.com/docs/extensions/develop/migrate)
- [Chrome Developer Blog](https://developer.chrome.com/blog)
