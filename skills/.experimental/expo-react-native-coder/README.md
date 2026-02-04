# Expo React Native Coder

Comprehensive feature development guide for Expo React Native applications, designed for AI agents and LLMs. Contains 50 rules across 10 categories with production-ready code templates.

## Overview

This skill provides best practices for building Expo React Native apps, covering:

- **Project Setup**: TypeScript, environment variables, EAS configuration
- **Routing**: Expo Router file-based navigation, tabs, stacks, drawers
- **Screens**: List, detail, form, and settings screen patterns
- **Data**: API routes, local storage, state management
- **Authentication**: Protected routes, OAuth, session management
- **Deep Linking**: Custom schemes, Universal Links, App Links
- **Native UX**: Safe areas, haptics, gestures, keyboard handling
- **Forms**: Input configuration, validation, submission
- **Assets**: Images, fonts, icons, splash screens
- **Testing**: Jest unit tests, Maestro E2E, error boundaries

## Structure

```
expo-react-native-coder/
├── SKILL.md              # Quick reference entry point
├── AGENTS.md             # Complete compiled guide
├── README.md             # This file
├── metadata.json         # Version and references
├── references/
│   ├── _sections.md      # Category definitions
│   ├── setup-*.md        # Project setup rules
│   ├── route-*.md        # Routing rules
│   ├── screen-*.md       # Screen pattern rules
│   ├── data-*.md         # Data fetching rules
│   ├── auth-*.md         # Authentication rules
│   ├── link-*.md         # Deep linking rules
│   ├── ux-*.md           # Native UX rules
│   ├── form-*.md         # Form rules
│   ├── asset-*.md        # Asset rules
│   └── test-*.md         # Testing rules
└── assets/
    └── templates/
        ├── layouts/      # Layout templates
        ├── screens/      # Screen templates
        ├── components/   # Component templates
        ├── hooks/        # Hook templates
        └── _template.md  # Rule template
```

## Getting Started

1. **Install the skill** in your Claude Code or AI agent environment
2. **Reference SKILL.md** for quick lookups by category
3. **Read AGENTS.md** for comprehensive guidance
4. **Copy templates** from `assets/templates/` as starting points

### Commands

```bash
# Validate skill structure
pnpm validate

# Build AGENTS.md from references
pnpm build

# Install dependencies (for validation)
pnpm install
```

## Creating a New Rule

1. Choose the appropriate category prefix from the table below
2. Create a file in `references/` with the format `{prefix}-{description}.md`
3. Follow the template in `assets/templates/_template.md`
4. Run `pnpm build` to regenerate AGENTS.md

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Project Setup | `setup-` | CRITICAL |
| Routing & Navigation | `route-` | CRITICAL |
| Screen Patterns | `screen-` | HIGH |
| Data Fetching | `data-` | HIGH |
| Authentication | `auth-` | HIGH |
| Deep Linking | `link-` | HIGH |
| Native UX | `ux-` | MEDIUM-HIGH |
| Forms | `form-` | MEDIUM |
| Assets | `asset-` | MEDIUM |
| Testing | `test-` | MEDIUM |

## Rule File Structure

Each rule file should contain:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW
impactDescription: Brief impact description
tags: prefix, keyword1, keyword2
---

## Rule Title

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**
\`\`\`typescript
// Bad example
\`\`\`

**Correct (what's right):**
\`\`\`typescript
// Good example
\`\`\`

Reference: [Docs](https://docs.expo.dev/...)
```

## File Naming Convention

- Use the category prefix followed by a descriptive kebab-case name
- Examples: `route-tab-navigator.md`, `auth-protected-routes.md`
- The first tag in YAML frontmatter must match the prefix

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Foundation patterns that affect entire app |
| HIGH | Important patterns for common features |
| MEDIUM-HIGH | Patterns that improve UX significantly |
| MEDIUM | Good practices with moderate impact |
| LOW | Nice-to-have optimizations |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm validate` | Validates skill structure and rules |
| `pnpm build` | Regenerates AGENTS.md from references |

## Contributing

1. Follow the existing rule format
2. Include Incorrect and Correct code examples
3. Reference official Expo/React Native documentation
4. Use production-realistic code, not strawman examples
5. Quantify impact where possible

## Acknowledgments

- [Expo Documentation](https://docs.expo.dev) - Official Expo guides
- [React Native Documentation](https://reactnative.dev) - Official React Native docs
- [Callstack Agent Skills](https://github.com/callstackincubator/agent-skills) - React Native best practices
