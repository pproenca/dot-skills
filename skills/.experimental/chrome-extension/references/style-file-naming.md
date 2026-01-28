---
title: Kebab-case file naming
impact: HIGH
impactDescription: Consistent file naming across all operating systems and browsers
tags: naming, files, convention
---

# Kebab-case file naming

Use kebab-case (lowercase with hyphens) for all file names. This ensures consistency and avoids case-sensitivity issues across different operating systems.

## Incorrect

```
src/
├── userStorage.ts
├── CSSFilter.ts
├── ColorUtils.ts
└── TabManager.ts
```

## Correct

```
src/
├── user-storage.ts
├── css-filter.ts
├── color-utils.ts
└── tab-manager.ts
```

## Why This Matters

- **Cross-platform**: Linux is case-sensitive, Windows/macOS are not - kebab-case avoids issues
- **URL-safe**: File names work naturally in web contexts
- **Searchability**: Easier to grep and find files
- **Consistency**: One convention for all files (TypeScript, CSS, JSON, etc.)

## Test Files

Test files follow the same pattern with `.tests.ts` suffix:

```
tests/unit/utils/color.tests.ts
tests/unit/background/tab-manager.tests.ts
```
