---
title: Validate Input Early with Descriptive Messages
impact: MEDIUM-HIGH
impactDescription: prevents invalid data from propagating
tags: prompt, validation, error, ux, clack
---

## Validate Input Early with Descriptive Messages

Validate user input immediately with clear, actionable error messages. Tell users exactly what's wrong and how to fix it.

**Incorrect (vague validation):**

```typescript
const name = await p.text({
  message: 'Project name?',
  validate: (value) => {
    if (!value || value.length < 2 || /[^a-z0-9-]/.test(value)) {
      return 'Invalid name'  // Unhelpful
    }
  }
})
```

**Correct (specific, actionable messages):**

```typescript
const name = await p.text({
  message: 'Project name?',
  placeholder: 'my-awesome-app',
  validate: (value) => {
    if (!value) {
      return 'Project name is required'
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters'
    }
    if (value.length > 50) {
      return 'Name must be 50 characters or less'
    }
    if (/^[0-9]/.test(value)) {
      return 'Name cannot start with a number'
    }
    if (/[^a-z0-9-]/.test(value)) {
      return 'Use only lowercase letters, numbers, and hyphens'
    }
    if (existsSync(value)) {
      return `Directory "${value}" already exists`
    }
  }
})
```

**Path validation example:**

```typescript
const outputDir = await p.text({
  message: 'Output directory?',
  placeholder: './dist',
  validate: (value) => {
    if (!value) return 'Output directory is required'

    const resolved = resolve(value)

    if (!value.startsWith('./') && !value.startsWith('/')) {
      return 'Use relative (./path) or absolute (/path) path'
    }

    try {
      const stat = statSync(dirname(resolved))
      if (!stat.isDirectory()) {
        return `Parent "${dirname(value)}" is not a directory`
      }
    } catch {
      return `Parent directory "${dirname(value)}" does not exist`
    }
  }
})
```

**Benefits:**
- Users understand exactly what to fix
- Prevents downstream errors from bad data
- Reduces frustration from repeated attempts

Reference: [clig.dev - Error Handling](https://clig.dev/#errors)
