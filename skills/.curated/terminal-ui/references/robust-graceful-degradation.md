---
title: Degrade Gracefully for Limited Terminals
impact: LOW-MEDIUM
impactDescription: maintains usability in 100% of terminal environments
tags: robust, degradation, compatibility, ssh, terminal
---

## Degrade Gracefully for Limited Terminals

Detect terminal capabilities and fall back gracefully. Support SSH sessions, minimal terminals, and screen readers.

**Incorrect (assumes full capabilities):**

```typescript
function render() {
  // Assumes true color support
  console.log('\x1b[38;2;255;128;0mOrange text\x1b[0m')

  // Assumes Unicode support
  console.log('Status: ✔ Complete')

  // Assumes wide terminal
  console.log('='.repeat(120))
}
// Broken on minimal terminals, SSH, screen readers
```

**Correct (capability detection):**

```typescript
interface TermCapabilities {
  colors: 0 | 16 | 256 | 16777216
  unicode: boolean
  width: number
}

function detectCapabilities(): TermCapabilities {
  const colorTerm = process.env.COLORTERM
  const term = process.env.TERM || ''

  let colors: TermCapabilities['colors'] = 0

  if (colorTerm === 'truecolor' || colorTerm === '24bit') {
    colors = 16777216
  } else if (term.includes('256color')) {
    colors = 256
  } else if (term && term !== 'dumb') {
    colors = 16
  }

  // Detect Unicode support (heuristic)
  const lang = process.env.LANG || ''
  const unicode = lang.toLowerCase().includes('utf')

  const width = process.stdout.columns || 80

  return { colors, unicode, width }
}

const caps = detectCapabilities()

function statusIcon(success: boolean): string {
  if (caps.unicode) {
    return success ? '✔' : '✖'
  }
  return success ? '[OK]' : '[FAIL]'
}

function colorize(text: string, color: string): string {
  if (caps.colors === 0) return text
  if (caps.colors >= 16) {
    const codes: Record<string, string> = {
      red: '\x1b[31m',
      green: '\x1b[32m',
      yellow: '\x1b[33m',
      reset: '\x1b[0m'
    }
    return `${codes[color]}${text}${codes.reset}`
  }
  return text
}

function renderLine(text: string): string {
  const maxWidth = Math.min(caps.width, 80)
  return text.slice(0, maxWidth)
}
```

**Screen reader support:**

```typescript
// Detect screen reader mode
const isScreenReader = Boolean(
  process.env.TERM_PROGRAM === 'Apple_Terminal' && process.env.TERM_PROGRAM_VERSION
  // Add other screen reader detection heuristics
)

if (isScreenReader) {
  // Use descriptive text instead of visual indicators
  // Avoid animations and rapid updates
  // Provide complete text instead of abbreviations
}
```

**SSH considerations:**

```typescript
const isSSH = Boolean(process.env.SSH_CLIENT || process.env.SSH_TTY)

if (isSSH) {
  // Reduce animation frequency (latency)
  // Use simpler color schemes
  // Increase timeouts
}
```

Reference: [clig.dev - Output](https://clig.dev/#output)
