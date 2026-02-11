---
title: Use Template Literal Types for String Patterns
impact: MEDIUM-HIGH
impactDescription: eliminates invalid string formats at compile time
tags: modern, template-literal-types, string-patterns, validation
---

## Use Template Literal Types for String Patterns

Template literal types (TS 4.1+) encode string patterns directly in the type system. Use them to validate format constraints — event names, CSS units, API paths — without runtime checks.

**Incorrect (plain string accepts any value):**

```typescript
function on(eventName: string, handler: () => void) {
  // ...
}

on("click", handleClick)
on("clck", handleClick) // Typo — no error
```

**Correct (template literal constrains format):**

```typescript
type DomEvent = "click" | "focus" | "blur" | "input" | "change"
type EventHandler = `on${Capitalize<DomEvent>}`

function registerHandler(name: EventHandler, handler: () => void) {
  // ...
}

registerHandler("onClick", handleClick)
registerHandler("onClck", handleClick) // Compile error
```

**Alternative (dynamic key patterns):**

```typescript
type CssUnit = `${number}${"px" | "rem" | "em" | "%"}`

function setWidth(value: CssUnit) { /* ... */ }

setWidth("100px")  // OK
setWidth("2.5rem") // OK
setWidth("100")    // Compile error — missing unit
```

Reference: [TypeScript 4.1 - Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
