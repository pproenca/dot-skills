---
title: Avoid the {} Type — It Means Non-Nullish
impact: LOW-MEDIUM
impactDescription: prevents accepting any non-null value when you mean "empty object"
tags: quirk, empty-object, non-nullish, type-safety
---

## Avoid the {} Type — It Means Non-Nullish

The `{}` type does not mean "empty object" — it means "any value that is not `null` or `undefined`." Strings, numbers, booleans, and arrays all satisfy `{}`. Use `Record<string, never>` for truly empty objects or `object` for any non-primitive.

**Incorrect ({} accepts everything non-nullish):**

```typescript
function processMetadata(meta: {}) {
  // Intended: empty object or object with unknown keys
  // Actually: accepts string, number, boolean, array...
}

processMetadata("hello")     // Compiles — string satisfies {}
processMetadata(42)          // Compiles — number satisfies {}
processMetadata([1, 2, 3])   // Compiles — array satisfies {}
```

**Correct (use the right type for your intent):**

```typescript
// For "any non-primitive value" (objects, arrays, functions):
function processMetadata(meta: object) { /* ... */ }

// For "empty object with no properties":
function processMetadata(meta: Record<string, never>) { /* ... */ }

// For "object with unknown string keys":
function processMetadata(meta: Record<string, unknown>) { /* ... */ }

processMetadata("hello") // Compile error with all three options
```
