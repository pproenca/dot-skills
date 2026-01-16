# Developer Experience TUI

**Version 0.1.0**  
DevEx  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive developer experience guide for building TypeScript terminal user interfaces using Ink (React for CLIs) and Clack prompts. Contains 42 rules across 8 categories, prioritized by impact from critical (rendering optimization, input handling) to incremental (robustness and compatibility). Each rule includes detailed explanations, real-world TypeScript examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Rendering & Output](#1-rendering-output) — **CRITICAL**
   - 1.1 [Batch Terminal Output in Single Write](#11-batch-terminal-output-in-single-write)
   - 1.2 [Defer ANSI Escape Code Generation to Final Output](#12-defer-ansi-escape-code-generation-to-final-output)
   - 1.3 [Overwrite Content Instead of Clear and Redraw](#13-overwrite-content-instead-of-clear-and-redraw)
   - 1.4 [Target 60fps for Smooth Animation](#14-target-60fps-for-smooth-animation)
   - 1.5 [Update Only Changed Regions](#15-update-only-changed-regions)
   - 1.6 [Use Synchronized Output Protocol for Animations](#16-use-synchronized-output-protocol-for-animations)
2. [Input & Keyboard](#2-input-keyboard) — **CRITICAL**
   - 2.1 [Always Provide Escape Routes](#21-always-provide-escape-routes)
   - 2.2 [Handle Modifier Keys Correctly](#22-handle-modifier-keys-correctly)
   - 2.3 [Provide Immediate Visual Feedback for Input](#23-provide-immediate-visual-feedback-for-input)
   - 2.4 [Use isActive Option for Focus Management](#24-use-isactive-option-for-focus-management)
   - 2.5 [Use useInput Hook for Keyboard Handling](#25-use-useinput-hook-for-keyboard-handling)
3. [Component Patterns](#3-component-patterns) — **HIGH**
   - 3.1 [Use Border Styles for Visual Structure](#31-use-border-styles-for-visual-structure)
   - 3.2 [Use Box Component with Flexbox for Layouts](#32-use-box-component-with-flexbox-for-layouts)
   - 3.3 [Use measureElement for Dynamic Sizing](#33-use-measureelement-for-dynamic-sizing)
   - 3.4 [Use Percentage Widths for Responsive Layouts](#34-use-percentage-widths-for-responsive-layouts)
   - 3.5 [Use Static Component for Log Output](#35-use-static-component-for-log-output)
   - 3.6 [Use Text Component for All Visible Content](#36-use-text-component-for-all-visible-content)
4. [State & Lifecycle](#4-state-lifecycle) — **HIGH**
   - 4.1 [Always Clean Up Effects on Unmount](#41-always-clean-up-effects-on-unmount)
   - 4.2 [Memoize Expensive Computations with useMemo](#42-memoize-expensive-computations-with-usememo)
   - 4.3 [Stabilize Callbacks with useCallback](#43-stabilize-callbacks-with-usecallback)
   - 4.4 [Use Functional State Updates to Avoid Stale Closures](#44-use-functional-state-updates-to-avoid-stale-closures)
   - 4.5 [Use useApp Hook for Application Lifecycle](#45-use-useapp-hook-for-application-lifecycle)
5. [Prompt Design](#5-prompt-design) — **MEDIUM-HIGH**
   - 5.1 [Build Custom Prompts with @clack/core](#51-build-custom-prompts-with-clackcore)
   - 5.2 [Handle Cancellation Gracefully with isCancel](#52-handle-cancellation-gracefully-with-iscancel)
   - 5.3 [Use Clack group() for Multi-Step Prompts](#53-use-clack-group-for-multi-step-prompts)
   - 5.4 [Use Spinner and Tasks for Long Operations](#54-use-spinner-and-tasks-for-long-operations)
   - 5.5 [Validate Input Early with Descriptive Messages](#55-validate-input-early-with-descriptive-messages)
6. [UX & Feedback](#6-ux-feedback) — **MEDIUM**
   - 6.1 [Show Next Steps After Completion](#61-show-next-steps-after-completion)
   - 6.2 [Show Progress for Operations Over 1 Second](#62-show-progress-for-operations-over-1-second)
   - 6.3 [Use Colors Semantically and Consistently](#63-use-colors-semantically-and-consistently)
   - 6.4 [Use Intro and Outro for Session Framing](#64-use-intro-and-outro-for-session-framing)
   - 6.5 [Write Actionable Error Messages](#65-write-actionable-error-messages)
7. [Configuration & CLI](#7-configuration-cli) — **MEDIUM**
   - 7.1 [Implement Comprehensive Help System](#71-implement-comprehensive-help-system)
   - 7.2 [Prefer Flags Over Positional Arguments](#72-prefer-flags-over-positional-arguments)
   - 7.3 [Provide Sensible Defaults for All Options](#73-provide-sensible-defaults-for-all-options)
   - 7.4 [Support Machine-Readable Output Format](#74-support-machine-readable-output-format)
   - 7.5 [Support Standard Environment Variables](#75-support-standard-environment-variables)
8. [Robustness & Compatibility](#8-robustness-compatibility) — **LOW-MEDIUM**
   - 8.1 [Always Restore Terminal State on Exit](#81-always-restore-terminal-state-on-exit)
   - 8.2 [Degrade Gracefully for Limited Terminals](#82-degrade-gracefully-for-limited-terminals)
   - 8.3 [Detect TTY and Adjust Behavior Accordingly](#83-detect-tty-and-adjust-behavior-accordingly)
   - 8.4 [Handle Process Signals Gracefully](#84-handle-process-signals-gracefully)
   - 8.5 [Use Meaningful Exit Codes](#85-use-meaningful-exit-codes)

---

## 1. Rendering & Output

**Impact: CRITICAL**

Flicker prevention, batched writes, and synchronized output are the #1 visual quality killers in terminal applications.

### 1.1 Batch Terminal Output in Single Write

**Impact: CRITICAL (eliminates partial frame flicker)**

Write new content to stdout in a single operation. Multiple sequential writes risk partial updates becoming visible, causing visual flicker.

**Incorrect (multiple writes cause flicker):**

```typescript
// Each write may render before the next one
process.stdout.write('\x1b[2J')     // Clear screen
process.stdout.write('\x1b[H')      // Move cursor
process.stdout.write('Loading...')  // Content
process.stdout.write('\n')          // Newline
// User may see blank frame between clear and content
```

**Correct (single batched write):**

```typescript
const output = [
  '\x1b[2J',     // Clear screen
  '\x1b[H',      // Move cursor
  'Loading...',  // Content
  '\n'           // Newline
].join('')

process.stdout.write(output)
// All content appears atomically
```

**Note:** Ink handles this automatically through its React reconciler. When building custom renderers or using raw escape codes, always batch writes.

Reference: [Textualize Blog - 7 Things Building a TUI Framework](https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/)

### 1.2 Defer ANSI Escape Code Generation to Final Output

**Impact: HIGH (reduces intermediate string allocations)**

Build content using semantic representations (segments with styles) and convert to ANSI escape codes only at the final output stage.

**Incorrect (escape codes generated inline):**

```typescript
function formatLine(text: string, isError: boolean): string {
  if (isError) {
    return `\x1b[31m${text}\x1b[0m`  // Red + reset
  }
  return `\x1b[32m${text}\x1b[0m`  // Green + reset
}

function render(lines: string[]) {
  // Each line already has escape codes - hard to optimize
  return lines.map(line => formatLine(line, line.startsWith('ERR'))).join('\n')
}
```

**Correct (semantic segments, late conversion):**

```typescript
interface Segment {
  text: string
  style: 'error' | 'success' | 'default'
}

function buildSegments(lines: string[]): Segment[] {
  return lines.map(line => ({
    text: line,
    style: line.startsWith('ERR') ? 'error' : 'success'
  }))
}

function toAnsi(segments: Segment[]): string {
  const styles = { error: '\x1b[31m', success: '\x1b[32m', default: '' }

  return segments
    .map(seg => `${styles[seg.style]}${seg.text}\x1b[0m`)
    .join('\n')
}

// Build semantic model, convert at final output
const segments = buildSegments(lines)
process.stdout.write(toAnsi(segments))
```

**Benefits:**
- Semantic model enables optimizations like combining adjacent same-style segments
- Easier to implement partial updates by comparing segment arrays
- Style changes don't require string manipulation

Reference: [Textualize Blog - Algorithms for High Performance Terminal Apps](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)

### 1.3 Overwrite Content Instead of Clear and Redraw

**Impact: CRITICAL (eliminates blank frame flicker)**

Overwrite terminal content in place rather than clearing the screen first. Clearing creates a brief blank frame that users perceive as flicker.

**Incorrect (clear then draw causes blank frame):**

```typescript
function updateProgress(percent: number) {
  console.clear()  // Creates visible blank frame
  console.log(`Progress: ${percent}%`)
  console.log(renderProgressBar(percent))
}
```

**Correct (overwrite in place):**

```typescript
function updateProgress(percent: number) {
  // Move cursor to start without clearing
  process.stdout.write('\x1b[H')
  process.stdout.write(`Progress: ${percent}%\x1b[K\n`)  // \x1b[K clears to end of line
  process.stdout.write(`${renderProgressBar(percent)}\x1b[K`)
}
```

**With Ink (automatic):**

```tsx
function ProgressDisplay({ percent }: { percent: number }) {
  // Ink handles overwrites automatically - no flicker
  return (
    <Box flexDirection="column">
      <Text>Progress: {percent}%</Text>
      <ProgressBar percent={percent} />
    </Box>
  )
}
```

Reference: [Textualize Blog - 7 Things Building a TUI Framework](https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/)

### 1.4 Target 60fps for Smooth Animation

**Impact: CRITICAL (16ms frame budget for perceived smoothness)**

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

### 1.5 Update Only Changed Regions

**Impact: CRITICAL (reduces bandwidth by 80-95%)**

Update only the terminal regions that changed rather than redrawing the entire screen. Full redraws waste bandwidth and increase flicker risk.

**Incorrect (full redraw on every change):**

```typescript
function updateUI(state: AppState) {
  console.clear()  // Clears everything
  console.log(renderHeader(state))
  console.log(renderContent(state))
  console.log(renderFooter(state))
  // Redraws 100% of screen even if only footer changed
}
```

**Correct (targeted region updates):**

```typescript
interface Region {
  row: number
  content: string
}

function updateRegion({ row, content }: Region) {
  // Move cursor to specific row, clear line, write new content
  process.stdout.write(`\x1b[${row};1H\x1b[K${content}`)
}

function updateUI(state: AppState, prevState: AppState) {
  if (state.header !== prevState.header) {
    updateRegion({ row: 1, content: renderHeader(state) })
  }
  if (state.footer !== prevState.footer) {
    updateRegion({ row: 24, content: renderFooter(state) })
  }
  // Only changed regions are updated
}
```

**With Ink (automatic diffing):**

```tsx
function Dashboard({ data }: { data: DashboardData }) {
  // Ink's React reconciler automatically diffs and updates only changed components
  return (
    <Box flexDirection="column">
      <Header title={data.title} />
      <Content items={data.items} />
      <Footer status={data.status} />
    </Box>
  )
}
```

**Note:** Ink handles this automatically through React's reconciliation. When building custom renderers, track previous state to compute minimal diffs.

Reference: [Textualize Blog - Algorithms for High Performance Terminal Apps](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)

### 1.6 Use Synchronized Output Protocol for Animations

**Impact: CRITICAL (eliminates 100% of mid-frame flicker)**

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

---

## 2. Input & Keyboard

**Impact: CRITICAL**

Keyboard event processing, modifier keys, and responsive feedback determine perceived latency and user satisfaction.

### 2.1 Always Provide Escape Routes

**Impact: CRITICAL (prevents user frustration and stuck states)**

Ensure users can always exit or cancel operations. Handle Ctrl+C, Escape, and 'q' consistently. Never trap users in states they can't exit.

**Incorrect (no clear exit path):**

```typescript
function ConfirmDialog({ message }: { message: string }) {
  const [answer, setAnswer] = useState<boolean | null>(null)

  useInput((input) => {
    if (input === 'y') setAnswer(true)
    if (input === 'n') setAnswer(false)
    // No escape route - user stuck if they don't want either option
  })

  return <Text>{message} (y/n)</Text>
}
```

**Correct (multiple escape routes):**

```typescript
function ConfirmDialog({
  message,
  onConfirm,
  onCancel
}: {
  message: string
  onConfirm: () => void
  onCancel: () => void
}) {
  const { exit } = useApp()

  useInput((input, key) => {
    if (input === 'y' || input === 'Y') {
      onConfirm()
      return
    }

    if (input === 'n' || input === 'N') {
      onCancel()
      return
    }

    // Multiple escape routes
    if (key.escape || input === 'q' || (key.ctrl && input === 'c')) {
      onCancel()
      return
    }
  })

  return (
    <Box flexDirection="column">
      <Text>{message}</Text>
      <Text dimColor>y/n (or press Escape to cancel)</Text>
    </Box>
  )
}
```

**With Clack prompts:**

```typescript
import * as p from '@clack/prompts'

const result = await p.confirm({ message: 'Continue?' })

if (p.isCancel(result)) {
  p.cancel('Operation cancelled.')
  process.exit(0)  // Clean exit
}
```

**Benefits:**
- Users never feel trapped
- Consistent cancellation behavior across the application
- Clear indication of how to exit

Reference: [clig.dev - Interactivity](https://clig.dev/#interactivity)

### 2.2 Handle Modifier Keys Correctly

**Impact: CRITICAL (prevents missed shortcuts and input bugs)**

Check modifier key states explicitly using the key object properties. Don't rely on character codes alone as they differ across platforms.

**Incorrect (character code assumptions):**

```typescript
useInput((input) => {
  // Ctrl+C sends character code 3, but this is fragile
  if (input === '\x03') handleCancel()

  // This won't detect Ctrl+S (no character for it)
  if (input === '\x13') handleSave()  // Won't work reliably
})
```

**Correct (explicit modifier checking):**

```typescript
useInput((input, key) => {
  // Ctrl+C with explicit modifier check
  if (key.ctrl && input === 'c') {
    handleCancel()
    return
  }

  // Ctrl+S with explicit modifier check
  if (key.ctrl && input === 's') {
    handleSave()
    return
  }

  // Shift combinations
  if (key.shift && key.tab) {
    handlePreviousField()
    return
  }

  // Meta/Cmd key (macOS)
  if (key.meta && input === 'k') {
    handleCommandPalette()
    return
  }

  // Plain character input (no modifiers)
  if (input && !key.ctrl && !key.meta) {
    handleTextInput(input)
  }
})
```

**Note:** The `key` object provides:
- `key.ctrl` - Control key pressed
- `key.meta` - Meta/Cmd key pressed
- `key.shift` - Shift key pressed
- `key.escape` - Escape key pressed
- `key.return` - Enter/Return key pressed
- `key.tab` - Tab key pressed
- `key.upArrow`, `key.downArrow`, `key.leftArrow`, `key.rightArrow`

Reference: [Ink Documentation - useInput](https://github.com/vadimdemedes/ink#useinputinputhandler-options)

### 2.3 Provide Immediate Visual Feedback for Input

**Impact: CRITICAL (<100ms response feels instant)**

Respond to user input within 100ms. Users perceive delays over 100ms as lag. Show immediate visual feedback even if the underlying operation takes longer.

**Incorrect (no feedback until operation completes):**

```typescript
import { useInput, Text, Box } from 'ink'
import { useState } from 'react'

function SearchInput() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<string[]>([])

  useInput(async (input) => {
    if (input && !input.includes('\x1b')) {
      const newQuery = query + input
      // User sees nothing until search completes
      const searchResults = await performSearch(newQuery)  // 500ms
      setQuery(newQuery)
      setResults(searchResults)
    }
  })

  return <Text>Results: {results.length}</Text>
}
```

**Correct (immediate feedback, async results):**

```typescript
import { useInput, Text, Box } from 'ink'
import { useState, useEffect } from 'react'

function SearchInput() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<string[]>([])
  const [isSearching, setIsSearching] = useState(false)

  useInput((input) => {
    if (input && !input.includes('\x1b')) {
      setQuery(q => q + input)  // Immediate update
    }
  })

  useEffect(() => {
    if (!query) return
    setIsSearching(true)

    const timer = setTimeout(async () => {
      const searchResults = await performSearch(query)
      setResults(searchResults)
      setIsSearching(false)
    }, 150)  // Debounce search

    return () => clearTimeout(timer)
  }, [query])

  return (
    <Box flexDirection="column">
      <Text>Query: {query}</Text>
      <Text dimColor>{isSearching ? 'Searching...' : `${results.length} results`}</Text>
    </Box>
  )
}
```

**Benefits:**
- Input appears instantly (query updates synchronously)
- Visual indicator shows work in progress
- Debouncing prevents excessive API calls

Reference: [clig.dev - Responsiveness](https://clig.dev/#responsiveness)

### 2.4 Use isActive Option for Focus Management

**Impact: HIGH (prevents input conflicts between components)**

Use the `isActive` option with `useInput` to enable/disable input handling based on focus state. This prevents multiple components from competing for keyboard input.

**Incorrect (all components receive all input):**

```typescript
function TextInput({ onSubmit }: { onSubmit: (value: string) => void }) {
  const [value, setValue] = useState('')

  useInput((input, key) => {
    if (key.return) {
      onSubmit(value)
    } else if (input) {
      setValue(v => v + input)
    }
  })
  // Always active - conflicts with other inputs

  return <Text>{value}</Text>
}

function App() {
  return (
    <Box flexDirection="column">
      <TextInput onSubmit={handleName} />
      <TextInput onSubmit={handleEmail} />
      {/* Both inputs receive the same keystrokes */}
    </Box>
  )
}
```

**Correct (focus-aware input handling):**

```typescript
function TextInput({
  onSubmit,
  isFocused
}: {
  onSubmit: (value: string) => void
  isFocused: boolean
}) {
  const [value, setValue] = useState('')

  useInput((input, key) => {
    if (key.return) {
      onSubmit(value)
    } else if (input) {
      setValue(v => v + input)
    }
  }, { isActive: isFocused })  // Only receives input when focused

  return (
    <Text color={isFocused ? 'cyan' : undefined}>
      {isFocused ? '> ' : '  '}{value}
    </Text>
  )
}

function App() {
  const [focusIndex, setFocusIndex] = useState(0)

  return (
    <Box flexDirection="column">
      <TextInput onSubmit={handleName} isFocused={focusIndex === 0} />
      <TextInput onSubmit={handleEmail} isFocused={focusIndex === 1} />
    </Box>
  )
}
```

**Benefits:**
- Only the focused component receives keyboard events
- Clear visual indication of which component is active
- Prevents input from being duplicated across components

Reference: [Ink Documentation - useInput options](https://github.com/vadimdemedes/ink#useinputinputhandler-options)

### 2.5 Use useInput Hook for Keyboard Handling

**Impact: CRITICAL (prevents raw stdin complexity)**

Use Ink's `useInput` hook instead of manually handling stdin. It provides parsed key events with modifier detection and proper cleanup.

**Incorrect (manual stdin handling):**

```typescript
import { render, Box, Text } from 'ink'
import { useEffect } from 'react'

function App() {
  useEffect(() => {
    process.stdin.setRawMode(true)
    process.stdin.resume()

    const handler = (data: Buffer) => {
      const key = data.toString()
      if (key === '\x03') process.exit()  // Ctrl+C
      if (key === 'q') process.exit()
      // Complex parsing for arrows, modifiers...
    }

    process.stdin.on('data', handler)
    return () => process.stdin.off('data', handler)
    // Error-prone, no modifier detection
  }, [])

  return <Text>Press q to quit</Text>
}
```

**Correct (useInput hook):**

```typescript
import { render, useInput, useApp, Box, Text } from 'ink'

function App() {
  const { exit } = useApp()

  useInput((input, key) => {
    if (input === 'q') exit()
    if (key.escape) exit()
    if (key.leftArrow) handleLeft()
    if (key.return) handleSubmit()
    if (key.ctrl && input === 'c') exit()
  })

  return <Text>Press q or Escape to quit</Text>
}
```

**Benefits:**
- Automatic raw mode management
- Parsed modifier keys (ctrl, meta, shift)
- Arrow keys and special keys detected
- Proper cleanup on unmount

Reference: [Ink Documentation - useInput](https://github.com/vadimdemedes/ink#useinputinputhandler-options)

---

## 3. Component Patterns

**Impact: HIGH**

React patterns for terminal including Box/Text usage, Flexbox layouts, and measureElement have multiplicative performance impact.

### 3.1 Use Border Styles for Visual Structure

**Impact: MEDIUM (reduces visual parsing time by 30-50%)**

Use Box borders to create visual grouping and hierarchy. Choose border styles based on emphasis level and terminal compatibility needs.

**Incorrect (manual ASCII borders):**

```typescript
function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box flexDirection="column">
      <Text>+{'-'.repeat(40)}+</Text>
      <Text>| {title.padEnd(39)}|</Text>
      <Text>+{'-'.repeat(40)}+</Text>
      {children}
    </Box>
  )
  // Tedious, error-prone, doesn't adapt to content
}
```

**Correct (Box borderStyle):**

```typescript
function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box
      flexDirection="column"
      borderStyle="round"
      borderColor="cyan"
      paddingX={1}
    >
      <Text bold>{title}</Text>
      {children}
    </Box>
  )
}
```

**Border style options:**

```typescript
// Available border styles
<Box borderStyle="single">Single line</Box>      // ┌─┐
<Box borderStyle="double">Double line</Box>      // ╔═╗
<Box borderStyle="round">Rounded corners</Box>   // ╭─╮
<Box borderStyle="bold">Bold lines</Box>         // ┏━┓
<Box borderStyle="singleDouble">Mixed</Box>      // ╓─╖
<Box borderStyle="doubleSingle">Mixed</Box>      // ╒═╕
<Box borderStyle="classic">ASCII</Box>           // +-+

// Partial borders
<Box borderTop borderBottom borderStyle="single">
  <Text>Horizontal divider</Text>
</Box>

// Colored borders
<Box borderStyle="round" borderColor="green">
  <Text>Success panel</Text>
</Box>
```

**When NOT to use this pattern:**
- For very constrained terminal widths where borders waste space
- When targeting terminals with limited Unicode support (use `borderStyle="classic"`)

Reference: [Ink Documentation - Box borders](https://github.com/vadimdemedes/ink#borders)

### 3.2 Use Box Component with Flexbox for Layouts

**Impact: HIGH (eliminates manual position calculations)**

Use Ink's `Box` component with Flexbox properties for layouts instead of manual character positioning. Flexbox handles alignment, spacing, and responsive sizing automatically.

**Incorrect (manual positioning with spaces):**

```typescript
function Dashboard({ title, status }: { title: string; status: string }) {
  const padding = ' '.repeat(20 - title.length)

  return (
    <Text>
      {title}{padding}{status}
      {'\n'}
      {'='.repeat(40)}
    </Text>
  )
  // Breaks when title length changes
}
```

**Correct (Flexbox layout):**

```typescript
function Dashboard({ title, status }: { title: string; status: string }) {
  return (
    <Box flexDirection="column" width={40}>
      <Box justifyContent="space-between">
        <Text bold>{title}</Text>
        <Text color="green">{status}</Text>
      </Box>
      <Box borderStyle="single" borderBottom />
    </Box>
  )
}
```

**Common Flexbox patterns:**

```typescript
// Centered content
<Box justifyContent="center" alignItems="center" height={10}>
  <Text>Centered</Text>
</Box>

// Sidebar + main content
<Box flexDirection="row" width="100%">
  <Box width="30%"><Sidebar /></Box>
  <Box flexGrow={1}><Content /></Box>
</Box>

// Vertical stack with gaps
<Box flexDirection="column" gap={1}>
  <Header />
  <Content />
  <Footer />
</Box>
```

Reference: [Ink Documentation - Box](https://github.com/vadimdemedes/ink#box)

### 3.3 Use measureElement for Dynamic Sizing

**Impact: HIGH (enables responsive layouts based on content)**

Use `measureElement` to get computed dimensions of rendered components. This enables responsive layouts that adapt to content size and terminal dimensions.

**Incorrect (hardcoded dimensions):**

```typescript
function Table({ rows }: { rows: string[][] }) {
  return (
    <Box width={80} height={20}>
      {/* Hardcoded size may overflow or waste space */}
      {rows.map((row, i) => (
        <Text key={i}>{row.join(' | ')}</Text>
      ))}
    </Box>
  )
}
```

**Correct (measured dimensions):**

```typescript
import { measureElement, Box, Text } from 'ink'
import { useRef, useState, useEffect } from 'react'

function ResponsiveTable({ rows }: { rows: string[][] }) {
  const containerRef = useRef(null)
  const [width, setWidth] = useState(80)

  useEffect(() => {
    if (containerRef.current) {
      const { width: measuredWidth } = measureElement(containerRef.current)
      setWidth(measuredWidth)
    }
  }, [])

  const columnWidth = Math.floor(width / rows[0].length)

  return (
    <Box ref={containerRef} flexDirection="column" width="100%">
      {rows.map((row, i) => (
        <Box key={i}>
          {row.map((cell, j) => (
            <Box key={j} width={columnWidth}>
              <Text>{cell.slice(0, columnWidth - 1)}</Text>
            </Box>
          ))}
        </Box>
      ))}
    </Box>
  )
}
```

**Note:** `measureElement` returns accurate values only after initial render. Call it inside `useEffect` to ensure layout calculations are complete.

**When to use measureElement:**
- Responsive table column widths
- Text truncation based on available space
- Centering content in variable-size containers
- Adapting layout to terminal size changes

Reference: [Ink Documentation - measureElement](https://github.com/vadimdemedes/ink#measureelementref)

### 3.4 Use Percentage Widths for Responsive Layouts

**Impact: HIGH (prevents overflow on 100% of terminal sizes)**

Use percentage-based widths instead of fixed character counts. This ensures layouts adapt to different terminal sizes without overflow or wasted space.

**Incorrect (fixed character widths):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row">
      <Box width={30}>
        <Sidebar />
      </Box>
      <Box width={70}>
        <Content />
      </Box>
    </Box>
  )
  // Breaks on terminals narrower than 100 columns
}
```

**Correct (percentage widths):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row" width="100%">
      <Box width="30%">
        <Sidebar />
      </Box>
      <Box width="70%">
        <Content />
      </Box>
    </Box>
  )
  // Adapts to any terminal width
}
```

**Better (flexGrow for fluid sizing):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row" width="100%">
      <Box width={20} flexShrink={0}>
        {/* Fixed minimum sidebar */}
        <Sidebar />
      </Box>
      <Box flexGrow={1}>
        {/* Content fills remaining space */}
        <Content />
      </Box>
    </Box>
  )
}
```

**Combining approaches:**

```typescript
function DashboardLayout() {
  return (
    <Box flexDirection="column" width="100%" height="100%">
      <Box height={3} flexShrink={0}>
        <Header />
      </Box>

      <Box flexGrow={1} flexDirection="row">
        <Box width="25%" minWidth={15}>
          <Sidebar />
        </Box>
        <Box flexGrow={1}>
          <MainContent />
        </Box>
      </Box>

      <Box height={1} flexShrink={0}>
        <StatusBar />
      </Box>
    </Box>
  )
}
```

Reference: [Ink Documentation - Box dimensions](https://github.com/vadimdemedes/ink#dimensions)

### 3.5 Use Static Component for Log Output

**Impact: HIGH (prevents log lines from re-rendering)**

Use the `Static` component for content that should be written once and never re-rendered, like log lines or command output. This preserves terminal scrollback and reduces CPU usage.

**Incorrect (logs in regular component):**

```typescript
function Logger({ logs }: { logs: string[] }) {
  return (
    <Box flexDirection="column">
      {logs.map((log, i) => (
        <Text key={i}>{log}</Text>
      ))}
    </Box>
  )
  // All logs re-render when new log is added
  // Previous logs may flicker or disappear from scrollback
}
```

**Correct (Static for permanent output):**

```typescript
import { Static, Box, Text } from 'ink'

function Logger({ logs }: { logs: string[] }) {
  return (
    <Box flexDirection="column">
      <Static items={logs}>
        {(log, index) => (
          <Text key={index}>{log}</Text>
        )}
      </Static>
    </Box>
  )
  // Each log is rendered once and never re-rendered
  // Properly preserved in terminal scrollback
}
```

**Combined with dynamic content:**

```typescript
function BuildOutput({
  logs,
  currentStep,
  isComplete
}: {
  logs: string[]
  currentStep: string
  isComplete: boolean
}) {
  return (
    <Box flexDirection="column">
      {/* Static logs - written once, preserved in scrollback */}
      <Static items={logs}>
        {(log, index) => <Text key={index}>{log}</Text>}
      </Static>

      {/* Dynamic status - re-renders on each update */}
      {!isComplete && (
        <Box marginTop={1}>
          <Text color="cyan">
            <Spinner /> {currentStep}
          </Text>
        </Box>
      )}
    </Box>
  )
}
```

Reference: [Ink Documentation - Static](https://github.com/vadimdemedes/ink#static)

### 3.6 Use Text Component for All Visible Content

**Impact: HIGH (prevents 100% of styling bugs from raw strings)**

Wrap all visible text in the `Text` component. Never write raw strings directly in JSX as they won't be properly styled or positioned.

**Incorrect (raw strings in JSX):**

```typescript
function Status({ message }: { message: string }) {
  return (
    <Box>
      Status: {message}
      {/* Raw strings may not render correctly */}
    </Box>
  )
}
```

**Correct (Text component for all content):**

```typescript
function Status({ message }: { message: string }) {
  return (
    <Box>
      <Text>Status: </Text>
      <Text color="green">{message}</Text>
    </Box>
  )
}
```

**Text styling options:**

```typescript
// Color (named or hex)
<Text color="cyan">Cyan text</Text>
<Text color="#ff6600">Orange text</Text>

// Background color
<Text backgroundColor="red" color="white">Alert</Text>

// Font styles
<Text bold>Bold text</Text>
<Text italic>Italic text</Text>
<Text underline>Underlined</Text>
<Text strikethrough>Deprecated</Text>

// Dim text for secondary info
<Text dimColor>Less important</Text>

// Inverse colors
<Text inverse> Selected </Text>

// Combined styles
<Text bold color="cyan" underline>Important link</Text>
```

**Note:** Ink handles color support detection automatically. On terminals without color support, styles degrade gracefully.

Reference: [Ink Documentation - Text](https://github.com/vadimdemedes/ink#text)

---

## 4. State & Lifecycle

**Impact: HIGH**

Hooks patterns, useApp/exit handling, cleanup, and avoiding stale closures prevent cascading re-renders and memory leaks.

### 4.1 Always Clean Up Effects on Unmount

**Impact: HIGH (prevents memory leaks and orphaned timers)**

Return cleanup functions from `useEffect` to cancel timers, close connections, and release resources when components unmount.

**Incorrect (no cleanup):**

```typescript
function Spinner() {
  const [frame, setFrame] = useState(0)
  const frames = ['|', '/', '-', '\\']

  useEffect(() => {
    setInterval(() => {
      setFrame(f => (f + 1) % frames.length)
    }, 100)
    // No cleanup - timer runs forever after unmount
  }, [])

  return <Text>{frames[frame]}</Text>
}
// Memory leak, state updates on unmounted component
```

**Correct (cleanup function):**

```typescript
function Spinner() {
  const [frame, setFrame] = useState(0)
  const frames = ['|', '/', '-', '\\']

  useEffect(() => {
    const timer = setInterval(() => {
      setFrame(f => (f + 1) % frames.length)
    }, 100)

    return () => clearInterval(timer)  // Cleanup on unmount
  }, [])

  return <Text>{frames[frame]}</Text>
}
```

**Common cleanup patterns:**

```typescript
// Event listeners
useEffect(() => {
  const handler = () => handleResize()
  process.stdout.on('resize', handler)
  return () => process.stdout.off('resize', handler)
}, [])

// Abort controller for fetch
useEffect(() => {
  const controller = new AbortController()

  fetch(url, { signal: controller.signal })
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') setError(err)
    })

  return () => controller.abort()
}, [url])

// Subscriptions
useEffect(() => {
  const unsubscribe = eventEmitter.subscribe(handler)
  return unsubscribe
}, [])
```

Reference: [React Documentation - useEffect Cleanup](https://react.dev/reference/react/useEffect#connecting-to-an-external-system)

### 4.2 Memoize Expensive Computations with useMemo

**Impact: MEDIUM (avoids recalculating on every render)**

Use `useMemo` to cache expensive calculations that depend on specific values. This prevents recalculating derived data on every render.

**Incorrect (recalculates on every render):**

```typescript
function FileTree({ files }: { files: FileNode[] }) {
  const [filter, setFilter] = useState('')
  const [selected, setSelected] = useState<string | null>(null)

  // Runs on EVERY render, even when only selected changes
  const filteredFiles = files
    .filter(f => f.name.includes(filter))
    .sort((a, b) => a.name.localeCompare(b.name))

  return (
    <Box flexDirection="column">
      {filteredFiles.map(file => (
        <Text key={file.path} inverse={file.path === selected}>
          {file.name}
        </Text>
      ))}
    </Box>
  )
}
```

**Correct (memoized computation):**

```typescript
function FileTree({ files }: { files: FileNode[] }) {
  const [filter, setFilter] = useState('')
  const [selected, setSelected] = useState<string | null>(null)

  // Only recalculates when files or filter changes
  const filteredFiles = useMemo(() => {
    return files
      .filter(f => f.name.includes(filter))
      .sort((a, b) => a.name.localeCompare(b.name))
  }, [files, filter])

  return (
    <Box flexDirection="column">
      {filteredFiles.map(file => (
        <Text key={file.path} inverse={file.path === selected}>
          {file.name}
        </Text>
      ))}
    </Box>
  )
}
```

**Common memoization candidates:**

```typescript
// Formatting expensive data
const tableRows = useMemo(() =>
  data.map(row => formatRow(row, columns)),
  [data, columns]
)

// Aggregating statistics
const stats = useMemo(() => ({
  total: items.length,
  completed: items.filter(i => i.done).length,
  avgDuration: items.reduce((sum, i) => sum + i.duration, 0) / items.length
}), [items])

// Searching/filtering large datasets
const searchResults = useMemo(() =>
  haystack.filter(item =>
    item.toLowerCase().includes(needle.toLowerCase())
  ),
  [haystack, needle]
)
```

**When NOT to use this pattern:**
- For trivial computations (the overhead of memoization exceeds savings)
- When values change on every render anyway

Reference: [React Documentation - useMemo](https://react.dev/reference/react/useMemo)

### 4.3 Stabilize Callbacks with useCallback

**Impact: MEDIUM (prevents unnecessary re-renders in children)**

Use `useCallback` to memoize callback functions passed to child components. This prevents children from re-rendering when parent state changes.

**Incorrect (new function on every render):**

```typescript
function App() {
  const [items, setItems] = useState<string[]>([])

  // New function created on every render
  const handleSelect = (item: string) => {
    setItems(prev => [...prev, item])
  }

  return (
    <Box flexDirection="column">
      <SelectList onSelect={handleSelect} />
      <SelectedItems items={items} />
    </Box>
  )
}
// SelectList re-renders whenever items changes
```

**Correct (stable callback reference):**

```typescript
function App() {
  const [items, setItems] = useState<string[]>([])

  // Same function reference between renders
  const handleSelect = useCallback((item: string) => {
    setItems(prev => [...prev, item])
  }, [])  // Empty deps - function never changes

  return (
    <Box flexDirection="column">
      <SelectList onSelect={handleSelect} />
      <SelectedItems items={items} />
    </Box>
  )
}
```

**With dependencies:**

```typescript
function SearchableList({ filter }: { filter: string }) {
  const [selected, setSelected] = useState<string | null>(null)

  const handleSelect = useCallback((item: string) => {
    if (item.includes(filter)) {
      setSelected(item)
    }
  }, [filter])  // Recreate when filter changes

  return <SelectList onSelect={handleSelect} />
}
```

**When NOT to use this pattern:**
- For callbacks not passed to child components
- When the component is already fast and memoization adds complexity
- With inline handlers in simple components

Reference: [React Documentation - useCallback](https://react.dev/reference/react/useCallback)

### 4.4 Use Functional State Updates to Avoid Stale Closures

**Impact: HIGH (prevents stale state bugs in callbacks)**

Use the functional form of setState when the new value depends on the previous value. This prevents stale closure bugs in event handlers and callbacks.

**Incorrect (stale closure):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  useInput((input) => {
    if (input === '+') {
      setCount(count + 1)  // Captures count at callback creation time
    }
    if (input === '-') {
      setCount(count - 1)  // Stale if multiple presses
    }
  })

  return <Text>Count: {count}</Text>
}
// Rapidly pressing '+' may only increment once due to stale closure
```

**Correct (functional update):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  useInput((input) => {
    if (input === '+') {
      setCount(c => c + 1)  // Always uses latest value
    }
    if (input === '-') {
      setCount(c => c - 1)
    }
  })

  return <Text>Count: {count}</Text>
}
```

**Complex state updates:**

```typescript
interface ListState {
  items: string[]
  selectedIndex: number
}

function SelectList() {
  const [state, setState] = useState<ListState>({
    items: ['Apple', 'Banana', 'Cherry'],
    selectedIndex: 0
  })

  useInput((input, key) => {
    if (key.upArrow) {
      setState(s => ({
        ...s,
        selectedIndex: Math.max(0, s.selectedIndex - 1)
      }))
    }

    if (key.downArrow) {
      setState(s => ({
        ...s,
        selectedIndex: Math.min(s.items.length - 1, s.selectedIndex + 1)
      }))
    }
  })

  return (
    <Box flexDirection="column">
      {state.items.map((item, i) => (
        <Text key={i} inverse={i === state.selectedIndex}>
          {item}
        </Text>
      ))}
    </Box>
  )
}
```

Reference: [React Documentation - useState](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)

### 4.5 Use useApp Hook for Application Lifecycle

**Impact: HIGH (prevents terminal state corruption on exit)**

Use the `useApp` hook to access application-level controls like `exit()`. This ensures proper unmounting, cleanup, and exit code handling.

**Incorrect (process.exit without cleanup):**

```typescript
function App() {
  useInput((input) => {
    if (input === 'q') {
      process.exit(0)  // Abrupt exit, no cleanup
    }
  })

  return <Text>Press q to quit</Text>
}
// Terminal may be left in raw mode
// Pending operations may be orphaned
```

**Correct (useApp exit):**

```typescript
import { render, useApp, useInput, Text } from 'ink'

function App() {
  const { exit } = useApp()

  useInput((input) => {
    if (input === 'q') {
      exit()  // Proper cleanup and unmounting
    }
  })

  return <Text>Press q to quit</Text>
}

async function main() {
  const { waitUntilExit } = render(<App />)

  await waitUntilExit()
  console.log('Cleanup complete')
}
```

**Exiting with error:**

```typescript
function App() {
  const { exit } = useApp()

  async function runTask() {
    try {
      await dangerousOperation()
      exit()  // Success exit
    } catch (error) {
      exit(error as Error)  // Exit with error - waitUntilExit rejects
    }
  }

  // ...
}

async function main() {
  try {
    const { waitUntilExit } = render(<App />)
    await waitUntilExit()
  } catch (error) {
    console.error('App failed:', error)
    process.exit(1)
  }
}
```

**Benefits:**
- Terminal state is properly restored
- React cleanup functions are called
- Exit code can be controlled
- Async operations can complete before exit

Reference: [Ink Documentation - useApp](https://github.com/vadimdemedes/ink#useapp)

---

## 5. Prompt Design

**Impact: MEDIUM-HIGH**

Clack group flows, validation, spinner/tasks, and cancellation handling affect usability and error recovery.

### 5.1 Build Custom Prompts with @clack/core

**Impact: MEDIUM (enables specialized input patterns)**

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

### 5.2 Handle Cancellation Gracefully with isCancel

**Impact: MEDIUM-HIGH (prevents crashes and ensures clean exit)**

Always check for cancellation using `isCancel()` after prompts. Cancelled prompts return a symbol, not the expected value type.

**Incorrect (no cancellation check):**

```typescript
import * as p from '@clack/prompts'

const name = await p.text({ message: 'Name?' })
const uppercased = name.toUpperCase()  // Crashes if cancelled!
// TypeError: Cannot read property 'toUpperCase' of Symbol
```

**Correct (cancellation check):**

```typescript
import * as p from '@clack/prompts'

const name = await p.text({ message: 'Name?' })

if (p.isCancel(name)) {
  p.cancel('Operation cancelled.')
  process.exit(0)
}

// TypeScript now knows name is string, not Symbol
const uppercased = name.toUpperCase()
```

**In grouped prompts:**

```typescript
const config = await p.group({
  name: () => p.text({ message: 'Name?' }),
  type: () => p.select({
    message: 'Type?',
    options: [{ value: 'ts', label: 'TypeScript' }]
  })
}, {
  onCancel: () => {
    p.cancel('Setup cancelled.')
    process.exit(0)
  }
})
// No need for individual isCancel checks
```

**Partial completion handling:**

```typescript
async function setupWithRecovery() {
  const name = await p.text({ message: 'Name?' })
  if (p.isCancel(name)) {
    return { cancelled: true, step: 'name' }
  }

  const type = await p.select({
    message: 'Type?',
    options: [{ value: 'ts', label: 'TypeScript' }]
  })
  if (p.isCancel(type)) {
    // Could offer to save partial progress
    p.log.info(`Saved name: ${name}`)
    return { cancelled: true, step: 'type', partial: { name } }
  }

  return { cancelled: false, config: { name, type } }
}
```

Reference: [Clack Documentation - isCancel](https://github.com/bombshell-dev/clack)

### 5.3 Use Clack group() for Multi-Step Prompts

**Impact: MEDIUM-HIGH (enables sequential prompts with shared state)**

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

### 5.4 Use Spinner and Tasks for Long Operations

**Impact: MEDIUM-HIGH (prevents perceived hang during async work)**

Show spinners or progress tasks for operations longer than 1 second. Users need visual feedback that work is happening.

**Incorrect (silent waiting):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

await installDependencies()  // User sees nothing for 30+ seconds
await runBuild()
await runTests()

p.outro('Done!')
// User thinks CLI is frozen
```

**Correct (spinner for single operation):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

const s = p.spinner()

s.start('Installing dependencies')
await installDependencies()
s.stop('Dependencies installed')

s.start('Building project')
await runBuild()
s.stop('Build complete')

p.outro('Done!')
```

**Correct (tasks for multiple operations):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

await p.tasks([
  {
    title: 'Installing dependencies',
    task: async (message) => {
      message('Resolving packages...')
      await resolveDeps()
      message('Downloading...')
      await downloadDeps()
      return 'Installed 142 packages'
    }
  },
  {
    title: 'Building project',
    task: async () => {
      await runBuild()
      return 'Built in 2.3s'
    }
  },
  {
    title: 'Running tests',
    task: async () => {
      const result = await runTests()
      return `${result.passed} passed, ${result.failed} failed`
    },
    enabled: process.env.SKIP_TESTS !== 'true'
  }
])

p.outro('Setup complete!')
```

**Benefits:**
- Visual indication of progress
- Dynamic status messages during long operations
- Conditional task execution with `enabled`
- Success/failure messages per task

Reference: [Clack Documentation - spinner, tasks](https://github.com/bombshell-dev/clack)

### 5.5 Validate Input Early with Descriptive Messages

**Impact: MEDIUM-HIGH (prevents invalid data from propagating)**

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

---

## 6. UX & Feedback

**Impact: MEDIUM**

Progress indicators, colors, error messages, and next steps guidance are critical for developer experience.

### 6.1 Show Next Steps After Completion

**Impact: MEDIUM (reduces support requests by providing clear guidance)**

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

### 6.2 Show Progress for Operations Over 1 Second

**Impact: MEDIUM (prevents perceived hangs and user frustration)**

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

### 6.3 Use Colors Semantically and Consistently

**Impact: MEDIUM (reduces time-to-comprehension by 2-3×)**

Use colors to convey meaning, not decoration. Reserve red for errors, yellow for warnings, green for success, and cyan/blue for emphasis.

**Incorrect (inconsistent/decorative colors):**

```typescript
// Colors chosen for aesthetics, not meaning
console.log(color.magenta('Error: File not found'))  // Error in magenta?
console.log(color.blue('Warning: Low disk space'))   // Warning in blue?
console.log(color.red('Success!'))                   // Success in red??
```

**Correct (semantic colors):**

```typescript
import color from 'picocolors'

// Consistent semantic color scheme
const log = {
  error: (msg: string) => console.log(color.red(`✖ ${msg}`)),
  warn: (msg: string) => console.log(color.yellow(`⚠ ${msg}`)),
  success: (msg: string) => console.log(color.green(`✔ ${msg}`)),
  info: (msg: string) => console.log(color.cyan(`ℹ ${msg}`)),
  dim: (msg: string) => console.log(color.dim(msg))
}

log.success('Build complete')
log.warn('Deprecated API usage detected')
log.error('Connection failed')
log.info('Server running on port 3000')
log.dim('Press Ctrl+C to stop')
```

**With Clack logging:**

```typescript
import * as p from '@clack/prompts'

p.log.success('Dependencies installed')
p.log.warn('Using deprecated config format')
p.log.error('Build failed')
p.log.info('Starting server...')
p.log.message('Custom message')  // Neutral
```

**Color scheme reference:**
- **Red**: Errors, failures, destructive actions
- **Yellow**: Warnings, caution, deprecation
- **Green**: Success, completion, safe actions
- **Cyan/Blue**: Information, emphasis, prompts
- **Magenta**: Highlights, special items
- **Dim/Gray**: Secondary info, hints, help text

**Note:** Always support `NO_COLOR` environment variable and provide non-color fallbacks for accessibility.

Reference: [clig.dev - Output](https://clig.dev/#output)

### 6.4 Use Intro and Outro for Session Framing

**Impact: MEDIUM (improves perceived quality and brand recognition)**

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

### 6.5 Write Actionable Error Messages

**Impact: MEDIUM (reduces user frustration and support requests)**

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

---

## 7. Configuration & CLI

**Impact: MEDIUM**

Arguments, flags, environment variables, and sensible defaults affect portability and ease of use.

### 7.1 Implement Comprehensive Help System

**Impact: MEDIUM (enables self-service and reduces support burden)**

Provide thorough help accessible via `-h`, `--help`, and running without arguments. Include examples, not just option lists.

**Incorrect (minimal help):**

```typescript
if (args.help) {
  console.log('Usage: mycli [options]')
  console.log('  --name    Name')
  console.log('  --output  Output')
  process.exit(0)
}
// Unhelpful, no examples, no context
```

**Correct (comprehensive help):**

```typescript
function showHelp() {
  const help = `
${color.bold('mycli')} - Build and deploy applications

${color.yellow('USAGE')}
  mycli <command> [options]

${color.yellow('COMMANDS')}
  init          Create a new project
  build         Build the project
  deploy        Deploy to production
  dev           Start development server

${color.yellow('GLOBAL OPTIONS')}
  -h, --help     Show this help message
  -v, --version  Show version number
  -q, --quiet    Suppress non-error output
  --no-color     Disable colored output

${color.yellow('EXAMPLES')}
  ${color.dim('# Create a new TypeScript project')}
  mycli init my-app --template typescript

  ${color.dim('# Build for production')}
  mycli build --minify --target es2020

  ${color.dim('# Deploy to staging')}
  mycli deploy --env staging

${color.yellow('LEARN MORE')}
  Documentation: ${color.cyan('https://mycli.dev/docs')}
  GitHub:        ${color.cyan('https://github.com/org/mycli')}
`
  console.log(help)
}
```

**Subcommand help:**

```typescript
function showCommandHelp(command: string) {
  const helpMap: Record<string, string> = {
    init: `
${color.bold('mycli init')} - Create a new project

${color.yellow('USAGE')}
  mycli init <name> [options]

${color.yellow('ARGUMENTS')}
  name    Project name (required)

${color.yellow('OPTIONS')}
  -t, --template <name>   Project template (default: default)
  --no-git                Skip git initialization
  --no-install            Skip dependency installation

${color.yellow('TEMPLATES')}
  default     Basic project structure
  typescript  TypeScript with strict config
  react       React application
  api         API server with Express

${color.yellow('EXAMPLES')}
  mycli init my-app
  mycli init my-api --template api
`,
    // ... other commands
  }

  console.log(helpMap[command] || showHelp())
}
```

**Key elements:**
- Examples with comments
- All options with descriptions
- Default values shown
- Links to documentation

Reference: [clig.dev - Help](https://clig.dev/#help)

### 7.2 Prefer Flags Over Positional Arguments

**Impact: MEDIUM (reduces user errors by 50% through self-documentation)**

Use named flags instead of positional arguments for most options. Flags are self-documenting, order-independent, and easier to extend.

**Incorrect (positional arguments):**

```bash
# What do these arguments mean?
mycli deploy prod main true 5
```

```typescript
const [environment, branch, force, retries] = process.argv.slice(2)
// Fragile, hard to remember order, no self-documentation
```

**Correct (named flags):**

```bash
# Self-documenting, any order
mycli deploy --env prod --branch main --force --retries 5
mycli deploy --retries 5 --env prod --force --branch main
```

```typescript
import { parseArgs } from 'util'

const { values } = parseArgs({
  options: {
    env: { type: 'string', short: 'e', default: 'staging' },
    branch: { type: 'string', short: 'b', default: 'main' },
    force: { type: 'boolean', short: 'f', default: false },
    retries: { type: 'string', short: 'r', default: '3' }
  }
})

const { env, branch, force, retries } = values
```

**When positional arguments ARE appropriate:**

```typescript
// Primary target of the command (like file paths)
// mycli compile src/main.ts
// mycli run script.js

const { positionals } = parseArgs({
  allowPositionals: true,
  options: {
    output: { type: 'string', short: 'o' },
    watch: { type: 'boolean', short: 'w' }
  }
})

const inputFile = positionals[0]  // Primary target
```

**Standard flag conventions:**

```typescript
const { values } = parseArgs({
  options: {
    help: { type: 'boolean', short: 'h' },      // -h, --help
    version: { type: 'boolean', short: 'v' },   // -v, --version
    verbose: { type: 'boolean', short: 'V' },   // -V, --verbose
    quiet: { type: 'boolean', short: 'q' },     // -q, --quiet
    force: { type: 'boolean', short: 'f' },     // -f, --force
    output: { type: 'string', short: 'o' },     // -o, --output
    config: { type: 'string', short: 'c' }      // -c, --config
  }
})
```

Reference: [clig.dev - Arguments and flags](https://clig.dev/#arguments-and-flags)

### 7.3 Provide Sensible Defaults for All Options

**Impact: MEDIUM (reduces friction for common use cases)**

Every configurable option should have a sensible default. Users should be able to run commands without specifying anything for the common case.

**Incorrect (requires explicit configuration):**

```typescript
const config = await p.group({
  port: () => p.text({
    message: 'Port number?',
    validate: (v) => !v ? 'Port is required' : undefined
  }),
  host: () => p.text({
    message: 'Host?',
    validate: (v) => !v ? 'Host is required' : undefined
  }),
  timeout: () => p.text({
    message: 'Timeout (ms)?',
    validate: (v) => !v ? 'Timeout is required' : undefined
  })
})
// User must answer 3 questions for basic usage
```

**Correct (smart defaults):**

```typescript
const config = await p.group({
  port: () => p.text({
    message: 'Port number?',
    placeholder: '3000',
    defaultValue: '3000'
  }),
  host: () => p.text({
    message: 'Host?',
    placeholder: 'localhost',
    defaultValue: 'localhost'
  }),
  timeout: () => p.text({
    message: 'Timeout (ms)?',
    placeholder: '5000',
    defaultValue: '5000'
  })
})
// User can press Enter through all prompts for sensible defaults
```

**CLI flag defaults:**

```typescript
import { parseArgs } from 'util'

const { values } = parseArgs({
  options: {
    port: { type: 'string', short: 'p', default: '3000' },
    host: { type: 'string', short: 'h', default: 'localhost' },
    verbose: { type: 'boolean', short: 'v', default: false },
    config: { type: 'string', short: 'c', default: './config.json' }
  }
})

// mycli serve          -> uses all defaults
// mycli serve -p 8080  -> overrides just port
```

**Environment-aware defaults:**

```typescript
const defaults = {
  port: process.env.PORT || '3000',
  host: process.env.HOST || 'localhost',
  logLevel: process.env.DEBUG ? 'debug' : 'info',
  output: process.env.CI ? 'json' : 'pretty'
}
```

Reference: [clig.dev - Arguments and flags](https://clig.dev/#arguments-and-flags)

### 7.4 Support Machine-Readable Output Format

**Impact: MEDIUM (enables scripting and tool integration)**

Provide a `--json` flag for machine-readable output. This enables scripting, piping to other tools, and CI integration.

**Incorrect (human-only output):**

```typescript
async function listProjects() {
  const projects = await getProjects()

  console.log('Projects:')
  projects.forEach(p => {
    console.log(`  • ${p.name} (${p.status})`)
  })
  console.log(`\nTotal: ${projects.length}`)
}
// Can't be parsed by other tools
```

**Correct (dual output modes):**

```typescript
interface OutputOptions {
  json?: boolean
  quiet?: boolean
}

async function listProjects(options: OutputOptions) {
  const projects = await getProjects()

  if (options.json) {
    // Machine-readable output
    console.log(JSON.stringify({
      projects,
      total: projects.length
    }, null, 2))
    return
  }

  if (options.quiet) {
    // Just names, one per line (for piping)
    projects.forEach(p => console.log(p.name))
    return
  }

  // Human-readable output
  console.log(color.bold('Projects:'))
  projects.forEach(p => {
    const status = p.status === 'active'
      ? color.green('●')
      : color.dim('○')
    console.log(`  ${status} ${p.name}`)
  })
  console.log(color.dim(`\nTotal: ${projects.length}`))
}
```

**Consistent JSON structure:**

```typescript
interface JsonOutput<T> {
  success: boolean
  data?: T
  error?: {
    code: string
    message: string
    details?: unknown
  }
  meta?: {
    timestamp: string
    version: string
  }
}

function outputJson<T>(data: T): void {
  const output: JsonOutput<T> = {
    success: true,
    data,
    meta: {
      timestamp: new Date().toISOString(),
      version: packageJson.version
    }
  }
  console.log(JSON.stringify(output, null, 2))
}

function outputJsonError(code: string, message: string): void {
  const output: JsonOutput<never> = {
    success: false,
    error: { code, message }
  }
  console.log(JSON.stringify(output, null, 2))
  process.exit(1)
}
```

**Usage examples:**

```bash
# Parse with jq
mycli list --json | jq '.projects[].name'

# Use in scripts
PROJECT_COUNT=$(mycli list --json | jq '.total')

# Quiet mode for simple piping
mycli list --quiet | xargs -I {} mycli deploy {}
```

Reference: [clig.dev - Output](https://clig.dev/#output)

### 7.5 Support Standard Environment Variables

**Impact: MEDIUM (enables scripting and CI integration)**

Respect common environment variables like `NO_COLOR`, `DEBUG`, `CI`, and tool-specific prefixes. This enables automation and accessibility.

**Incorrect (ignores standard variables):**

```typescript
import color from 'picocolors'

function log(message: string) {
  // Always uses colors, ignores NO_COLOR
  console.log(color.cyan(`ℹ ${message}`))
}

async function runPrompts() {
  // Always prompts, even in CI where stdin isn't interactive
  const name = await p.text({ message: 'Name?' })
  return name
}
// Breaks in CI, ignores accessibility preferences
```

**Correct (respects standard variables):**

```typescript
import color from 'picocolors'

// Respect NO_COLOR and TERM
const useColor = process.stdout.isTTY &&
  !process.env.NO_COLOR &&
  process.env.TERM !== 'dumb' &&
  process.env.FORCE_COLOR !== '0'

// Detect CI environments
const isCI = Boolean(
  process.env.CI ||
  process.env.CONTINUOUS_INTEGRATION ||
  process.env.GITHUB_ACTIONS ||
  process.env.GITLAB_CI
)

function log(message: string) {
  if (useColor) {
    console.log(color.cyan(`ℹ ${message}`))
  } else {
    console.log(`[INFO] ${message}`)
  }
}

async function runPrompts(cliArgs: { name?: string }) {
  // In CI, require flags instead of interactive prompts
  if (isCI && !cliArgs.name) {
    console.error('Error: --name required in CI environment')
    process.exit(1)
  }

  if (cliArgs.name) return cliArgs.name

  const name = await p.text({ message: 'Name?' })
  return name
}
```

**Tool-specific prefix pattern:**

```typescript
// Use MYAPP_ prefix for tool-specific config
const config = {
  apiKey: process.env.MYAPP_API_KEY,
  baseUrl: process.env.MYAPP_BASE_URL || 'https://api.example.com',
  timeout: parseInt(process.env.MYAPP_TIMEOUT || '5000', 10),
  logLevel: process.env.MYAPP_LOG_LEVEL || 'info'
}
```

Reference: [clig.dev - Environment variables](https://clig.dev/#environment-variables)

---

## 8. Robustness & Compatibility

**Impact: LOW-MEDIUM**

TTY detection, graceful degradation, signal handling, and clean exit ensure production reliability.

### 8.1 Always Restore Terminal State on Exit

**Impact: LOW-MEDIUM (prevents broken terminal after crashes)**

Restore terminal settings (cursor visibility, raw mode, alternate screen) before exit. A broken terminal state after a crash is a poor user experience.

**Incorrect (no state restoration):**

```typescript
async function interactiveMode() {
  // Enter raw mode for key handling
  process.stdin.setRawMode(true)
  process.stdin.resume()

  // Hide cursor
  process.stdout.write('\x1b[?25l')

  await runInteractiveSession()

  // If crash happens, terminal is left in bad state
  // Cursor invisible, raw mode on, input broken
}
```

**Correct (guaranteed restoration):**

```typescript
async function interactiveMode() {
  const originalRawMode = process.stdin.isRaw

  // Setup terminal
  process.stdin.setRawMode(true)
  process.stdin.resume()
  process.stdout.write('\x1b[?25l')  // Hide cursor

  function restore() {
    process.stdout.write('\x1b[?25h')  // Show cursor
    process.stdin.setRawMode(originalRawMode ?? false)
    process.stdin.pause()
  }

  // Restore on normal exit
  process.on('exit', restore)

  // Restore on signals
  process.on('SIGINT', () => {
    restore()
    process.exit(130)
  })

  try {
    await runInteractiveSession()
  } finally {
    restore()
  }
}
```

**With Ink (automatic):**

```typescript
import { render } from 'ink'

async function main() {
  // Ink handles terminal state automatically
  const { waitUntilExit } = render(<App />)

  await waitUntilExit()
  // Terminal state is restored automatically
}
```

**Alternate screen buffer:**

```typescript
const ALTERNATE_SCREEN_ON = '\x1b[?1049h'
const ALTERNATE_SCREEN_OFF = '\x1b[?1049l'

async function fullscreenApp() {
  process.stdout.write(ALTERNATE_SCREEN_ON)

  const cleanup = () => {
    process.stdout.write(ALTERNATE_SCREEN_OFF)
  }

  process.on('exit', cleanup)
  process.on('SIGINT', () => {
    cleanup()
    process.exit(130)
  })
  process.on('uncaughtException', (error) => {
    cleanup()
    console.error(error)
    process.exit(1)
  })

  try {
    await runApp()
  } finally {
    cleanup()
  }
}
```

Reference: [Ink Documentation - render](https://github.com/vadimdemedes/ink#rendernode)

### 8.2 Degrade Gracefully for Limited Terminals

**Impact: LOW-MEDIUM (maintains usability in 100% of terminal environments)**

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

### 8.3 Detect TTY and Adjust Behavior Accordingly

**Impact: LOW-MEDIUM (prevents 100% of CI hangs from interactive prompts)**

Check if stdin/stdout are TTYs and adjust behavior. Disable interactive features, colors, and animations when piped or in non-interactive environments.

**Incorrect (assumes interactive terminal):**

```typescript
import * as p from '@clack/prompts'

async function main() {
  const name = await p.text({ message: 'Name?' })
  // Hangs in CI waiting for input that never comes
}
```

**Correct (TTY-aware):**

```typescript
import * as p from '@clack/prompts'

async function main() {
  // Check for interactive terminal
  const isInteractive = process.stdin.isTTY && process.stdout.isTTY

  if (!isInteractive) {
    // Non-interactive: require flags
    if (!args.name) {
      console.error('Error: --name is required in non-interactive mode')
      process.exit(1)
    }
    return { name: args.name }
  }

  // Interactive: use prompts
  const name = await p.text({ message: 'Name?' })
  return { name }
}
```

**Comprehensive detection:**

```typescript
interface Environment {
  isTTY: boolean
  isCI: boolean
  hasColor: boolean
  termWidth: number
}

function detectEnvironment(): Environment {
  const isTTY = Boolean(process.stdout.isTTY)

  const isCI = Boolean(
    process.env.CI ||
    process.env.CONTINUOUS_INTEGRATION ||
    process.env.GITHUB_ACTIONS ||
    process.env.GITLAB_CI ||
    process.env.JENKINS_URL
  )

  const hasColor = isTTY &&
    !process.env.NO_COLOR &&
    process.env.TERM !== 'dumb' &&
    process.env.FORCE_COLOR !== '0'

  const termWidth = isTTY
    ? process.stdout.columns || 80
    : 80

  return { isTTY, isCI, hasColor, termWidth }
}

const env = detectEnvironment()

if (env.isCI) {
  // Longer timeouts
  // Simpler output format
  // No animations
}
```

**Adjust output for non-TTY:**

```typescript
function log(message: string) {
  if (process.stdout.isTTY) {
    console.log(color.cyan(`ℹ ${message}`))
  } else {
    console.log(`[INFO] ${message}`)  // Plain text for logs
  }
}
```

Reference: [clig.dev - Output](https://clig.dev/#output)

### 8.4 Handle Process Signals Gracefully

**Impact: LOW-MEDIUM (enables clean shutdown and resource cleanup)**

Handle SIGINT (Ctrl+C) and SIGTERM for graceful shutdown. Clean up resources, restore terminal state, and exit with appropriate codes.

**Incorrect (no signal handling):**

```typescript
async function server() {
  const db = await connectDatabase()
  const server = await startServer()
  // Ctrl+C abruptly kills process
  // Database connection left hanging
  // Terminal may be in raw mode
}
```

**Correct (graceful signal handling):**

```typescript
async function server() {
  const db = await connectDatabase()
  const httpServer = await startServer()

  let isShuttingDown = false

  async function shutdown(signal: string) {
    if (isShuttingDown) return
    isShuttingDown = true

    console.log(`\n${signal} received, shutting down...`)

    // Stop accepting new connections
    httpServer.close()

    // Finish pending requests (with timeout)
    await Promise.race([
      waitForPendingRequests(),
      new Promise(resolve => setTimeout(resolve, 10000))
    ])

    // Clean up resources
    await db.close()

    console.log('Shutdown complete')
    process.exit(0)
  }

  process.on('SIGINT', () => shutdown('SIGINT'))
  process.on('SIGTERM', () => shutdown('SIGTERM'))
}
```

**With Ink applications:**

```typescript
import { render, useApp } from 'ink'

function App() {
  const { exit } = useApp()

  useEffect(() => {
    const handleSignal = () => {
      console.log('\nCleaning up...')
      exit()
    }

    process.on('SIGINT', handleSignal)
    process.on('SIGTERM', handleSignal)

    return () => {
      process.off('SIGINT', handleSignal)
      process.off('SIGTERM', handleSignal)
    }
  }, [exit])

  return <App />
}

async function main() {
  const { waitUntilExit } = render(<App />)
  await waitUntilExit()
  console.log('Cleanup complete')
}
```

**Immediate feedback on interrupt:**

```typescript
process.on('SIGINT', () => {
  // Give immediate feedback
  console.log('\nInterrupted, cleaning up...')

  // Then do cleanup with timeout
  const cleanup = async () => {
    await closeConnections()
    process.exit(130)  // 128 + signal number (2 for SIGINT)
  }

  // Force exit if cleanup takes too long
  setTimeout(() => process.exit(130), 5000)
  cleanup()
})
```

Reference: [clig.dev - Interactivity](https://clig.dev/#interactivity)

### 8.5 Use Meaningful Exit Codes

**Impact: LOW-MEDIUM (enables proper error handling in scripts)**

Return appropriate exit codes for different outcomes. Scripts and CI systems rely on exit codes to determine success or failure.

**Incorrect (always exit 1 on error):**

```typescript
try {
  await runCommand()
} catch (error) {
  console.error(error.message)
  process.exit(1)  // Same code for all errors
}
```

**Correct (meaningful exit codes):**

```typescript
// Standard exit codes
const EXIT = {
  SUCCESS: 0,
  GENERAL_ERROR: 1,
  MISUSE: 2,           // Invalid arguments, bad usage
  CANNOT_EXECUTE: 126,  // Permission denied
  NOT_FOUND: 127,       // Command not found
  SIGINT: 130,          // 128 + 2 (Ctrl+C)
  SIGTERM: 143          // 128 + 15
} as const

async function main() {
  try {
    const args = parseArgs()

    if (args.help) {
      showHelp()
      process.exit(EXIT.SUCCESS)
    }

    if (!args.command) {
      console.error('Error: No command specified')
      console.error('Run with --help for usage')
      process.exit(EXIT.MISUSE)
    }

    await runCommand(args)
    process.exit(EXIT.SUCCESS)

  } catch (error) {
    if (error instanceof ValidationError) {
      console.error(`Invalid input: ${error.message}`)
      process.exit(EXIT.MISUSE)
    }

    if (error instanceof PermissionError) {
      console.error(`Permission denied: ${error.message}`)
      process.exit(EXIT.CANNOT_EXECUTE)
    }

    if (error instanceof NotFoundError) {
      console.error(`Not found: ${error.message}`)
      process.exit(EXIT.NOT_FOUND)
    }

    console.error(`Error: ${error.message}`)
    process.exit(EXIT.GENERAL_ERROR)
  }
}
```

**Exit code categories:**

```typescript
// 0: Success
// 1: General error
// 2: Misuse (bad arguments, invalid config)
// 3-63: Reserved for application-specific errors
// 64-78: Sysexits.h codes (EX_USAGE, EX_DATAERR, etc.)
// 126: Cannot execute
// 127: Command not found
// 128+N: Killed by signal N

// Application-specific
const APP_EXIT = {
  CONFIG_ERROR: 10,
  NETWORK_ERROR: 11,
  AUTH_ERROR: 12,
  BUILD_FAILED: 20,
  TEST_FAILED: 21,
  DEPLOY_FAILED: 22
}
```

**Check exit code in scripts:**

```bash
mycli build || exit $?

if mycli test; then
  mycli deploy
else
  echo "Tests failed with exit code $?"
fi
```

Reference: [clig.dev - Exit codes](https://clig.dev/#exit-codes)

---

## References

1. [https://github.com/bombshell-dev/clack](https://github.com/bombshell-dev/clack)
2. [https://github.com/vadimdemedes/ink](https://github.com/vadimdemedes/ink)
3. [https://github.com/vadimdemedes/ink-ui](https://github.com/vadimdemedes/ink-ui)
4. [https://clig.dev/](https://clig.dev/)
5. [https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)