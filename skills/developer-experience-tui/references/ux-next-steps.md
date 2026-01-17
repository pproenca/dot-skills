---
title: Show Next Steps After Completion
impact: MEDIUM
impactDescription: reduces support requests by providing clear guidance
tags: ux, onboarding, guidance, workflow, help
---

## Show Next Steps After Completion

After completing an operation, show users what to do next. Guide them through the workflow with concrete commands.

**Incorrect (no guidance):**

```typescript
import * as p from '@clack/prompts'

async function createProject(name: string) {
  await scaffoldProject(name)
  p.outro('Done!')
  // User left wondering what to do next
}
```

**Correct (clear next steps):**

```typescript
import * as p from '@clack/prompts'
import color from 'picocolors'

async function createProject(name: string) {
  await scaffoldProject(name)

  const steps = [
    `cd ${name}`,
    'npm install',
    'npm run dev'
  ].join('\n')

  p.note(steps, 'Next steps')

  p.outro(
    `Problems? ${color.underline(color.cyan('https://docs.example.com/getting-started'))}`
  )
}
```

**Conditional next steps:**

```typescript
async function setupComplete(config: ProjectConfig) {
  const steps: string[] = [`cd ${config.name}`]

  if (!config.installedDeps) {
    steps.push('npm install')
  }

  if (config.hasDatabase) {
    steps.push('npm run db:setup')
  }

  steps.push('npm run dev')

  p.note(steps.join('\n'), 'Next steps')

  if (config.hasDatabase) {
    p.log.info('Database setup requires Docker running')
  }

  p.outro(`View docs: ${color.cyan('https://docs.example.com')}`)
}
```

**With contextual help:**

```typescript
function showCompletionHelp(command: string) {
  const helpMap: Record<string, string[]> = {
    'init': ['Run `mycli dev` to start development', 'Edit config.json to customize'],
    'build': ['Find output in ./dist', 'Run `mycli deploy` to publish'],
    'deploy': ['View at https://your-app.example.com', 'Run `mycli logs` to monitor']
  }

  const steps = helpMap[command]
  if (steps) {
    p.note(steps.join('\n'), 'What now?')
  }
}
```

Reference: [clig.dev - Output](https://clig.dev/#output)
