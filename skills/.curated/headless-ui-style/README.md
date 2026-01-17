# Headless UI Style Skill

Style guidelines for building headless React component libraries, extracted from the MUI Base UI codebase.

## Overview

This skill teaches the patterns and conventions used by MUI Base UI to build unstyled, accessible React components. It covers:

- **Component Patterns** - forwardRef, render props, context providers, controlled/uncontrolled state
- **Naming Conventions** - consistent naming for components, files, types, and data attributes
- **Organization** - directory structure for compound components, barrel exports, test placement
- **Error Handling** - development warnings, cancelable events, typed event reasons
- **Style** - import patterns, prop type definitions, documentation

## Getting Started

```bash
# Install dependencies
pnpm install

# Build the skill
pnpm build

# Validate the skill
pnpm validate
```

## When to Use

Apply this skill when:
- Building a headless/unstyled component library
- Creating compound components (Accordion, Dialog, Tabs, etc.)
- Implementing accessible UI primitives with ARIA patterns
- Writing components that support render props for styling flexibility
- Building components that work in both controlled and uncontrolled modes

## Creating a New Rule

1. Create a new file in `references/` with the appropriate prefix (e.g., `comp-`, `name-`, `org-`, `err-`, `style-`)
2. Follow the template structure in `assets/templates/_template.md`
3. Include YAML frontmatter with title, impact, impactDescription, and tags
4. Provide Incorrect and Correct code examples with descriptive labels
5. Run validation to ensure the rule meets quality standards

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title Starting with Verb
impact: CRITICAL | HIGH | MEDIUM | LOW
impactDescription: quantified impact statement
tags: category, relevant, tags
---

## Rule Title Starting with Verb

Brief explanation of why this matters.

**Incorrect (reason why it's wrong):**

\`\`\`typescript
// Anti-pattern code
\`\`\`

**Correct (reason why it's right):**

\`\`\`typescript
// Recommended code
\`\`\`

**When to use:**
- Situation 1
- Situation 2
```

## File Naming Convention

- Rule files: `{prefix}-{slug}.md` (e.g., `comp-forward-ref-named.md`)
- Prefixes by category:
  - `comp-` - Component Patterns
  - `name-` - Naming Conventions
  - `org-` - Organization
  - `err-` - Error Handling
  - `style-` - Style

## Impact Levels

| Level | Description | Use When |
|-------|-------------|----------|
| **CRITICAL** | Prevents bugs or security issues | Breaking patterns that cause runtime errors |
| **HIGH** | Significant quality improvement | Patterns affecting maintainability or DX |
| **MEDIUM** | Moderate improvement | Consistency and code organization |
| **LOW** | Minor enhancement | Nice-to-have conventions |

## Scripts

- `pnpm build` - Compile AGENTS.md from rule files
- `pnpm validate` - Run validation checks on all files
- `pnpm validate --strict` - Fail on warnings too

## Contributing

1. Read existing rules to understand the style
2. Create a new rule following the template
3. Run validation to check for errors
4. Submit a pull request with your changes

## Key Patterns

### Component Structure

```typescript
'use client'

import * as React from 'react'

export const AccordionTrigger = React.forwardRef(function AccordionTrigger(
  componentProps: AccordionTrigger.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, disabled = false, ...elementProps } = componentProps
  const { open, setOpen } = useAccordionItemContext()

  const state = React.useMemo(() => ({ open, disabled }), [open, disabled])

  return useRenderElement('button', componentProps, {
    state,
    ref: forwardedRef,
    props: [elementProps],
    stateAttributesMapping,
  })
})

export namespace AccordionTrigger {
  export type Props = AccordionTriggerProps
  export type State = AccordionTriggerState
}
```

### Directory Structure

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  item/
    AccordionItem.tsx
    AccordionItemContext.ts
  trigger/
    AccordionTrigger.tsx
    stateAttributesMapping.ts
  panel/
    AccordionPanel.tsx
  index.ts
  index.parts.ts
  DataAttributes.ts
```

## Source

Extracted from [MUI Base UI](https://github.com/mui/base-ui) (packages/ directory) on 2026-01-17.

## Files

- `SKILL.md` - Entry point with quick reference
- `AGENTS.md` - Compiled comprehensive guide
- `references/` - Individual rule files
- `assets/templates/` - Templates for extending the skill
