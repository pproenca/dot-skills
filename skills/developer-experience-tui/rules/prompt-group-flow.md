---
title: Use Clack group() for Multi-Step Prompts
impact: MEDIUM-HIGH
impactDescription: enables sequential prompts with shared state
tags: prompt, group, clack, flow, sequential
---

## Use Clack group() for Multi-Step Prompts

Use `p.group()` to chain related prompts together. Each prompt can access previous answers, and cancellation is handled automatically.

**Incorrect (manual chaining):**

```typescript
import * as p from '@clack/prompts'

const name = await p.text({ message: 'Project name?' })
if (p.isCancel(name)) process.exit(0)

const type = await p.select({
  message: 'Project type?',
  options: [{ value: 'ts', label: 'TypeScript' }]
})
if (p.isCancel(type)) process.exit(0)

const install = await p.confirm({ message: 'Install deps?' })
if (p.isCancel(install)) process.exit(0)
// Repetitive cancellation handling
```

**Correct (grouped prompts):**

```typescript
import * as p from '@clack/prompts'

const config = await p.group(
  {
    name: () => p.text({
      message: 'Project name?',
      placeholder: 'my-app',
      validate: (value) => {
        if (!value) return 'Name is required'
        if (!/^[a-z0-9-]+$/.test(value)) return 'Use lowercase letters, numbers, hyphens'
      }
    }),

    type: ({ results }) => p.select({
      message: `Select type for "${results.name}"`,
      initialValue: 'ts',
      options: [
        { value: 'ts', label: 'TypeScript', hint: 'recommended' },
        { value: 'js', label: 'JavaScript' }
      ]
    }),

    features: () => p.multiselect({
      message: 'Additional features?',
      required: false,
      options: [
        { value: 'eslint', label: 'ESLint' },
        { value: 'prettier', label: 'Prettier' }
      ]
    }),

    install: () => p.confirm({
      message: 'Install dependencies?',
      initialValue: true
    })
  },
  {
    onCancel: () => {
      p.cancel('Setup cancelled.')
      process.exit(0)
    }
  }
)

// All results typed and available
console.log(config.name, config.type, config.features, config.install)
```

**Benefits:**
- Single cancellation handler for all prompts
- Previous results available via `{ results }`
- Fully typed result object
- Clear visual flow with consistent styling

**When NOT to use this pattern:**
- For a single standalone prompt where grouping adds no value
- When prompt flow is highly dynamic (e.g., skip prompts based on complex runtime conditions)
- When you need to persist partial progress between sessions or retry failed steps

Reference: [Clack Documentation - group](https://github.com/bombshell-dev/clack)
