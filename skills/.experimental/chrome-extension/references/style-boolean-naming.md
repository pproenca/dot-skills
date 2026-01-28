---
title: Boolean variable naming
impact: MEDIUM
impactDescription: Boolean prefixes make code more readable and self-documenting
tags: naming, booleans, convention
---

# Boolean variable naming

Prefix boolean variables with `is`, `has`, `was`, `did`, `should`, or `can` to make their boolean nature explicit.

## Prefix Guide

| Prefix | Use Case | Example |
|--------|----------|---------|
| `is` | Current state | `isEnabled`, `isActive`, `isFirefox` |
| `has` | Possession/capability | `hasPermission`, `hasCache`, `hasError` |
| `was` | Past state | `wasEnabledOnLastCheck`, `wasModified` |
| `did` | Past action | `didSlideIn`, `didInitialize` |
| `should` | Conditional behavior | `shouldUpdate`, `shouldInject` |
| `can` | Capability | `canChangeSettings`, `canAccessTab` |

## Incorrect

```typescript
const enabled = true;
const active = false;
const darkMode = true;
const initialized = false;
```

## Correct

```typescript
const isEnabled = true;
const isActive = false;
const isDarkThemeDetected = true;
const didInitialize = false;

// In interfaces
interface BodyState {
    isOpen: boolean;
    didNewsSlideIn: boolean;
    hasUnreadNews: boolean;
}

// Function parameters
function setStatus(isEnabled: boolean): void { }

// Return types
function checkTheme(): { isDark: boolean; isSystemPreference: boolean } { }
```

## Why This Matters

- **Self-documenting**: Variable name tells you it's a boolean
- **Natural reading**: `if (isEnabled)` reads like English
- **IDE autocomplete**: Type `is` to find all boolean state variables
- **Avoids confusion**: `enabled` could be a function, `isEnabled` is clearly a boolean
