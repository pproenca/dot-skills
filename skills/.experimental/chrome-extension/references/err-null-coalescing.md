---
title: Null coalescing and optional chaining
impact: MEDIUM
impactDescription: Safe property access prevents runtime errors from undefined values
tags: error-handling, typescript, null-safety
---

# Null coalescing and optional chaining

Use nullish coalescing (`??`) and optional chaining (`?.`) for accessing potentially undefined values. This is safer than `||` which treats `0`, `''`, and `false` as falsy.

## Incorrect

```typescript
// || treats 0, '', false as falsy
const brightness = settings.brightness || 100;  // 0 becomes 100!
const name = user.name || 'Anonymous';          // '' becomes 'Anonymous'

// Verbose null checks
let host: string;
if (tab && tab.url) {
    const parsed = parseURL(tab.url);
    if (parsed && parsed.host) {
        host = parsed.host;
    }
}

// Nested property access without checks
const color = theme.colors.primary.dark;  // Throws if any is undefined
```

## Correct

```typescript
// ?? only triggers on null/undefined
const brightness = settings.brightness ?? 100;  // 0 stays 0
const name = user.name ?? 'Anonymous';          // '' stays ''

// Optional chaining for nested access
const host = tab?.url && parseURL(tab.url)?.host;

// Combined patterns
const color = theme?.colors?.primary?.dark ?? '#000000';

// With function calls
const shortcut = commands.find((cmd) => cmd.name === command)?.shortcut ?? null;

// Nullish assignment
settings.brightness ??= 100;  // Only assign if null/undefined
```

## Common Patterns

```typescript
// Safe array access
const firstItem = items?.[0];
const lastItem = items?.[items.length - 1];

// Safe method calls
element?.classList?.add('active');
callback?.();

// With Map/Set
const cached = cache.get(key) ?? computeValue(key);

// In destructuring with defaults
const { brightness = 100, contrast = 100 } = theme ?? {};

// Combining with type narrowing
function getTabHost(tab: chrome.tabs.Tab | undefined): string {
    const url = tab?.url;
    if (!url) return '';

    return parseURL(url)?.hostname ?? '';
}
```

## When to Use `||` vs `??`

```typescript
// Use ?? for numbers (0 is valid)
const opacity = settings.opacity ?? 1;

// Use ?? for strings ('' might be valid)
const customCSS = settings.customCSS ?? '';

// Use || for truly empty checks where 0/'' should trigger default
const displayName = user.name || 'Unknown';  // '' treated as "no name"

// Use || for boolean-like expressions
const isEnabled = settings.enabled || settings.forceEnable;
```

## Why This Matters

- **Bug prevention**: `0`, `''`, `false` are valid values, not always "missing"
- **Cleaner code**: Replaces verbose if-chains with single expressions
- **Type safety**: Works well with TypeScript's strict null checks
- **Predictable**: Clear distinction between "empty" and "missing"
