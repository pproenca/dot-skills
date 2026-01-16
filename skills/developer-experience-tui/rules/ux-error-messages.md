---
title: Write Actionable Error Messages
impact: MEDIUM
impactDescription: reduces user frustration and support requests
tags: ux, errors, messages, actionable, help
---

## Write Actionable Error Messages

Error messages should explain what went wrong and how to fix it. Avoid technical jargon and always suggest next steps.

**Incorrect (unhelpful errors):**

```typescript
try {
  await connectToDatabase()
} catch (error) {
  console.error('Error:', error.message)
  // "Error: ECONNREFUSED"
  process.exit(1)
}
```

**Correct (actionable errors):**

```typescript
import * as p from '@clack/prompts'

try {
  await connectToDatabase()
} catch (error) {
  if (error.code === 'ECONNREFUSED') {
    p.log.error('Could not connect to database')
    p.log.info('Make sure the database is running:')
    p.log.message('  docker compose up -d postgres')
    p.log.message('')
    p.log.info('Or update DATABASE_URL in .env')
  } else if (error.code === 'EACCES') {
    p.log.error('Permission denied accessing database')
    p.log.info('Check your database credentials in .env')
  } else {
    p.log.error(`Database error: ${error.message}`)
    p.log.info('See logs at: ./logs/db-error.log')
  }
  process.exit(1)
}
```

**Error message template:**

```typescript
function formatError(error: AppError): void {
  // 1. What happened (in plain language)
  p.log.error(error.userMessage)

  // 2. Why it might have happened (if known)
  if (error.cause) {
    p.log.message(color.dim(`Cause: ${error.cause}`))
  }

  // 3. How to fix it
  if (error.suggestions.length > 0) {
    p.log.info('Try:')
    error.suggestions.forEach(s => p.log.message(`  • ${s}`))
  }

  // 4. Where to get help
  p.log.message('')
  p.log.message(color.dim('Need help? https://github.com/org/repo/issues'))
}
```

**Suggest typo corrections:**

```typescript
function suggestCommand(input: string, commands: string[]): string | null {
  const matches = commands.filter(cmd =>
    levenshtein(input, cmd) <= 2
  )
  return matches[0] || null
}

const suggestion = suggestCommand(userInput, availableCommands)
if (suggestion) {
  p.log.info(`Did you mean "${suggestion}"?`)
}
```

Reference: [clig.dev - Errors](https://clig.dev/#errors)
