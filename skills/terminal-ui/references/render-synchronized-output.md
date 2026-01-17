---
title: Use Synchronized Output Protocol for Animations
impact: CRITICAL
impactDescription: eliminates 100% of mid-frame flicker
tags: render, sync, animation, protocol, decset
---

## Use Synchronized Output Protocol for Animations

Use the Synchronized Output protocol (DECSET 2026) to signal frame boundaries. The terminal batches all updates between begin/end markers for flicker-free rendering.

**Incorrect (no synchronization, terminal may show partial frames):**

```typescript
function renderFrame(frame: string) {
  process.stdout.write('\x1b[H')  // Move to top-left
  process.stdout.write(frame)
  // Terminal may refresh mid-frame
}
```

**Correct (synchronized frame boundaries):**

```typescript
const SYNC_START = '\x1b[?2026h'  // Begin synchronized update
const SYNC_END = '\x1b[?2026l'    // End synchronized update

function renderFrame(frame: string) {
  process.stdout.write(SYNC_START)
  process.stdout.write('\x1b[H')
  process.stdout.write(frame)
  process.stdout.write(SYNC_END)
  // Terminal waits until SYNC_END to display
}
```

**Note:** This protocol is supported by most modern terminals (kitty, WezTerm, iTerm2, Windows Terminal). Unsupported terminals safely ignore the sequences.

**When NOT to use this pattern:**
- For single, non-animated updates where overhead isn't justified
- When targeting very old terminal emulators that may misbehave

Reference: [WezTerm Escape Sequences](https://wezfurlong.org/wezterm/escape-sequences.html)
