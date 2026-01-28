---
title: URL parsing with fallback
impact: HIGH
impactDescription: Invalid URLs are common in browser extensions; always handle parse failures
tags: error-handling, url, parsing
---

# URL parsing with fallback

Always wrap URL parsing in try-catch and return null or a sensible default on failure. User URLs, tab URLs, and external URLs can all be malformed.

## Incorrect

```typescript
// Throws on invalid URL
function getHost(urlString: string): string {
    const url = new URL(urlString);
    return url.hostname;
}

// No error handling
const tabUrl = new URL(tab.url);
```

## Correct

```typescript
// Safe URL parsing with null return
function parseURL(url: string): URL | null {
    try {
        return new URL(url);
    } catch (err) {
        return null;
    }
}

// Get host with fallback
function getURLHostOrProtocol(url: string): string {
    try {
        const parsed = new URL(url);
        if (parsed.host) {
            return parsed.host;
        }
        // Handle special URLs like chrome://extensions
        return parsed.protocol.replace(':', '');
    } catch (err) {
        return url;
    }
}

// Usage with cache
const parsedURLCache = new Map<string, URL | null>();

function parseURLWithCache(url: string): URL | null {
    if (parsedURLCache.has(url)) {
        return parsedURLCache.get(url)!;
    }

    const result = parseURL(url);
    parsedURLCache.set(url, result);
    return result;
}
```

## Common Failure Cases

```typescript
// These all throw on `new URL()`:
new URL('');                        // Empty string
new URL('not-a-url');              // No protocol
new URL('chrome://newtab');        // Works, but no hostname
new URL('about:blank');            // Works, but no hostname
new URL('javascript:void(0)');     // JavaScript protocol
new URL('file:///local/path');     // File protocol

// Guard clauses for special URLs
function shouldProcessURL(url: string): boolean {
    if (!url) return false;

    const parsed = parseURL(url);
    if (!parsed) return false;

    // Skip special protocols
    const skipProtocols = ['chrome:', 'chrome-extension:', 'about:', 'javascript:'];
    if (skipProtocols.some((p) => parsed.protocol === p)) {
        return false;
    }

    return true;
}
```

## Match Pattern Validation

```typescript
// Validate extension match patterns
function isValidMatchPattern(pattern: string): boolean {
    try {
        // Match pattern format: <scheme>://<host>/<path>
        const match = pattern.match(/^(\*|https?|file|ftp):\/\/([^/]+)\/(.*)$/);
        if (!match) return false;

        const [, scheme, host] = match;

        // Validate host part
        if (host !== '*' && !host.match(/^(\*\.)?[a-z0-9.-]+$/i)) {
            return false;
        }

        return true;
    } catch (err) {
        return false;
    }
}
```

## Why This Matters

- **Tab URLs**: Browser tabs can have any URL including malformed ones
- **User input**: Site lists and custom URLs from users need validation
- **Special pages**: Chrome pages, about:blank, etc. don't have normal hosts
- **Robustness**: Extension should never crash on unexpected URL
