---
title: Build Custom Prompts with @clack/core
impact: MEDIUM
impactDescription: enables specialized input patterns
tags: prompt, custom, core, clack, render
---

## Build Custom Prompts with @clack/core

Use `@clack/core` to create custom prompts with full control over rendering and behavior when built-in prompts don't fit your needs.

**Incorrect (hardcoded string concatenation):**

```typescript
import * as readline from 'readline'

async function getEmail(): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  })

  return new Promise((resolve) => {
    rl.question('Enter your email: ', (answer) => {
      rl.close()
      resolve(answer)
    })
  })
  // No validation, no cursor handling, no state management
  // No visual feedback for errors or cancellation
}
```

**Correct (custom prompt with @clack/core):**

```typescript
import { TextPrompt, isCancel } from '@clack/core'
import color from 'picocolors'

const emailPrompt = new TextPrompt({
  validate: (value) => {
    if (!value) return 'Email is required'
    if (!value.includes('@')) return 'Must be a valid email'
  },

  render() {
    const title = `${color.cyan('?')} ${color.bold('Enter your email')}:`
    const input = this.valueWithCursor || color.dim('user@example.com')

    switch (this.state) {
      case 'error':
        return `${title}\n${color.yellow(input)}\n${color.red(`✖ ${this.error}`)}`

      case 'submit':
        return `${title} ${color.green(this.value)}`

      case 'cancel':
        return `${title} ${color.strikethrough(color.dim(this.value || ''))}`

      default:
        return `${title}\n${color.cyan(input)}`
    }
  }
})

const email = await emailPrompt.prompt()

if (isCancel(email)) {
  console.log('Cancelled')
  process.exit(0)
}
```

**When to use custom prompts:**
- Autocomplete/fuzzy search inputs
- Date/time pickers
- Multi-step wizards with custom navigation
- Domain-specific input formats

Reference: [Clack Core Documentation](https://github.com/bombshell-dev/clack/tree/main/packages/core)
