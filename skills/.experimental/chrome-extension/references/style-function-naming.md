---
title: Function naming conventions
impact: HIGH
impactDescription: Predictable function names improve code readability and API discoverability
tags: naming, functions, convention
---

# Function naming conventions

Use camelCase for functions with consistent prefixes that indicate the function's purpose.

## Function Prefixes

| Prefix | Purpose | Example |
|--------|---------|---------|
| `on` | Event handlers | `onMessage`, `onTabUpdate`, `onColorSchemeChange` |
| `create` | Factory functions | `createStyle`, `createManager`, `createRegExp` |
| `get` | Accessors | `getURLHost`, `getActiveTab`, `getSettings` |
| `is` | Boolean checks / type guards | `isEnabled`, `isFirefox`, `isValidURL` |
| `parse` | Parsing operations | `parseColorWithCache`, `parseURL` |
| `validate` | Validation | `validateSettings`, `validateTheme` |

## Incorrect

```typescript
function ParseColor(s: string): Color { }      // PascalCase
function get_url_host(url: string): string { } // snake_case
function handleClick(): void { }               // inconsistent prefix
function asyncLoadSettings(): Promise<void> { } // redundant async prefix
```

## Correct

```typescript
function parseColorWithCache(s: string): Color { }
function getURLHostOrProtocol(url: string): string { }
function onClick(): void { }
async function loadSettings(): Promise<UserSettings> { }
```

## Why This Matters

- **Predictability**: Developers can guess function names based on conventions
- **Searchability**: Easy to find all handlers with `on*`, all factories with `create*`
- **Self-documenting**: Prefix tells you what the function does
