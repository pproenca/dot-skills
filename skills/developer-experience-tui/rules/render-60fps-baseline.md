---
title: Target 60fps for Smooth Animation
impact: CRITICAL
impactDescription: 16ms frame budget for perceived smoothness
tags: render, animation, framerate, performance, timing
---

## Target 60fps for Smooth Animation

Use 60fps (16.67ms per frame) as the baseline for terminal animations. Higher rates provide no perceivable benefit while wasting resources.

**Incorrect (uncapped or too-fast updates):**

```typescript
function animateSpinner() {
  const frames = ['|', '/', '-', '\\']
  let i = 0

  // Too fast - wastes CPU, no visual benefit
  setInterval(() => {
    process.stdout.write(`\r${frames[i++ % 4]}`)
  }, 1)  // 1000fps - excessive
}
```

**Correct (60fps target):**

```typescript
function animateSpinner() {
  const frames = ['|', '/', '-', '\\']
  let i = 0
  const FRAME_MS = 16  // ~60fps

  setInterval(() => {
    process.stdout.write(`\r${frames[i++ % 4]}`)
  }, FRAME_MS)
}
```

**With Ink (automatic frame management):**

```tsx
import { render, Text, Box } from 'ink'
import { useEffect, useState } from 'react'

function Spinner() {
  const [frame, setFrame] = useState(0)
  const frames = ['|', '/', '-', '\\']

  useEffect(() => {
    const timer = setInterval(() => {
      setFrame(f => (f + 1) % frames.length)
    }, 80)  // 12.5fps is sufficient for spinner
    return () => clearInterval(timer)
  }, [])

  return <Text>{frames[frame]}</Text>
}
```

**Note:** Not all animations need 60fps. Spinners work well at 10-15fps. Reserve 60fps for smooth motion like progress bars or cursor movement.

Reference: [Textualize Blog - 7 Things Building a TUI Framework](https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/)
