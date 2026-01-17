---
title: Use Intro and Outro for Session Framing
impact: MEDIUM
impactDescription: improves perceived quality by 30-40% in user studies
tags: ux, intro, outro, framing, clack
---

## Use Intro and Outro for Session Framing

Frame CLI sessions with intro and outro messages. This creates clear boundaries and gives a polished, professional feel.

**Incorrect (abrupt start/end):**

```typescript
const name = await prompt('Name?')
// ... do stuff
console.log('bye')
// Feels unfinished, unprofessional
```

**Correct (framed session):**

```typescript
import * as p from '@clack/prompts'
import color from 'picocolors'

async function main() {
  // Clear visual start
  p.intro(color.bgCyan(color.black(' create-myapp ')))

  const config = await p.group({
    name: () => p.text({ message: 'Project name?' }),
    // ...
  })

  await createProject(config)

  // Clear visual end with useful link
  p.outro(`Problems? ${color.underline(color.cyan('https://github.com/org/myapp/issues'))}`)
}

main().catch((error) => {
  p.log.error(error.message)
  process.exit(1)
})
```

**For commands without prompts:**

```typescript
async function buildCommand() {
  p.intro(color.bgBlue(color.white(' build ')))

  const s = p.spinner()
  s.start('Building...')

  try {
    const result = await build()
    s.stop(`Built in ${result.duration}ms`)
    p.outro('Build complete!')
  } catch (error) {
    s.stop('Build failed')
    p.log.error(error.message)
    p.outro(color.red('Build failed'))
    process.exit(1)
  }
}
```

**Intro styling patterns:**

```typescript
// Branded intro
p.intro(color.bgMagenta(color.white(' ✨ myapp ')))

// Version info
p.intro(`${color.bold('myapp')} ${color.dim(`v${version}`)}`)

// With tagline
p.intro(color.cyan('myapp - Build great things'))
```

**Benefits:**
- Clear session boundaries
- Consistent visual identity
- Professional appearance
- Natural place for branding and help links

Reference: [Clack Documentation - intro, outro](https://github.com/bombshell-dev/clack)
