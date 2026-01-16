---
title: Handle Modifier Keys Correctly
impact: CRITICAL
impactDescription: prevents missed shortcuts and input bugs
tags: input, modifiers, ctrl, shift, alt, keyboard
---

## Handle Modifier Keys Correctly

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
