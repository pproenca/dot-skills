---
title: Show Progress for Operations Over 1 Second
impact: MEDIUM
impactDescription: prevents perceived hangs and user frustration
tags: ux, progress, spinner, feedback, latency
---

## Show Progress for Operations Over 1 Second

Display progress indicators for any operation taking longer than 1 second. Include animation and ETA when possible to show work is progressing.

**Incorrect (no feedback during long operation):**

```typescript
async function deploy() {
  console.log('Deploying...')
  await uploadFiles()      // 10 seconds
  await runMigrations()    // 5 seconds
  await restartServices()  // 3 seconds
  console.log('Done!')
  // User stares at "Deploying..." for 18 seconds
}
```

**Correct (progress with Clack):**

```typescript
import * as p from '@clack/prompts'

async function deploy() {
  const s = p.spinner()

  s.start('Uploading files...')
  const uploaded = await uploadFiles()
  s.message(`Uploaded ${uploaded} files, running migrations...`)
  await runMigrations()
  s.message('Restarting services...')
  await restartServices()
  s.stop('Deployment complete!')
}
```

**Correct (progress bar with Ink):**

```typescript
import { render, Box, Text } from 'ink'
import { useState, useEffect } from 'react'

function DeployProgress({ files }: { files: string[] }) {
  const [progress, setProgress] = useState(0)
  const [currentFile, setCurrentFile] = useState('')

  useEffect(() => {
    async function upload() {
      for (let i = 0; i < files.length; i++) {
        setCurrentFile(files[i])
        await uploadFile(files[i])
        setProgress(((i + 1) / files.length) * 100)
      }
    }
    upload()
  }, [files])

  const filledBlocks = Math.round(progress / 5)
  const progressBar = '█'.repeat(filledBlocks) + '░'.repeat(20 - filledBlocks)

  return (
    <Box flexDirection="column">
      <Text>Uploading: {currentFile}</Text>
      <Text color="cyan">[{progressBar}] {progress.toFixed(0)}%</Text>
    </Box>
  )
}
```

**Guidelines:**
- < 1s: No indicator needed
- 1-10s: Spinner with status message
- > 10s: Progress bar with percentage/ETA
- Always show what's happening, not just "loading"

Reference: [clig.dev - Responsiveness](https://clig.dev/#responsiveness)
