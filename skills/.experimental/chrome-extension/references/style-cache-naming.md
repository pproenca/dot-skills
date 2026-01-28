---
title: Cache variable naming
impact: LOW
impactDescription: Clear identification of caching data structures
tags: naming, caching, performance
---

# Cache variable naming

Suffix cache variables and Maps with `Cache` to indicate their caching purpose.

## Incorrect

```typescript
const parsedURLs = new Map<string, URL>();
const colorMap = new Map<string, RGBA>();
const styleSheet: CSSStyleSheet | null = null;
```

## Correct

```typescript
const parsedURLCache = new Map<string, URL>();
const rgbaParseCache = new Map<string, RGBA>();
const styleSheetCache: CSSStyleSheet | null = null;

// Module-level caches
const themeCache = new Map<string, Theme>();
const settingsCache: UserSettings | null = null;

// Cache with clear invalidation
const fontFaceCache = new Map<string, FontFaceRule[]>();

function clearFontFaceCache(): void {
    fontFaceCache.clear();
}
```

## Cache Pattern with Parsing

```typescript
const rgbaParseCache = new Map<string, RGBA>();
const MAX_CACHE_SIZE = 1000;

function parseColorWithCache(color: string): RGBA | null {
    if (rgbaParseCache.has(color)) {
        return rgbaParseCache.get(color)!;
    }

    const result = parseColor(color);

    if (result && rgbaParseCache.size < MAX_CACHE_SIZE) {
        rgbaParseCache.set(color, result);
    }

    return result;
}
```

## Why This Matters

- **Intent clarity**: Cache suffix signals that this Map is for performance optimization
- **Cache invalidation**: Easy to find all caches when you need to clear them
- **Memory awareness**: Developers know to consider cache size limits
