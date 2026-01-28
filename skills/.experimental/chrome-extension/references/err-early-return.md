---
title: Early return for guard clauses
impact: MEDIUM
impactDescription: Guard clauses reduce nesting and make code flow clearer
tags: error-handling, patterns, code-style
---

# Early return for guard clauses

Use early returns for guard clauses to avoid deep nesting and make the "happy path" clear.

## Incorrect

```typescript
// Deep nesting makes main logic hard to find
function processTab(tab: chrome.tabs.Tab): void {
    if (tab) {
        if (tab.url) {
            if (!tab.url.startsWith('chrome://')) {
                if (tab.id !== undefined) {
                    const parsed = parseURL(tab.url);
                    if (parsed) {
                        // Finally, the actual logic...
                        applyTheme(tab.id, parsed.hostname);
                    }
                }
            }
        }
    }
}
```

## Correct

```typescript
// Guard clauses at the top, main logic at normal indentation
function processTab(tab: chrome.tabs.Tab): void {
    if (!tab?.url) {
        return;
    }

    if (tab.url.startsWith('chrome://')) {
        return;
    }

    if (tab.id === undefined) {
        return;
    }

    const parsed = parseURL(tab.url);
    if (!parsed) {
        return;
    }

    // Main logic is clear and at base indentation
    applyTheme(tab.id, parsed.hostname);
}
```

## Guard Clause Patterns

```typescript
// Boolean check
function setEnabled(enabled: boolean): void {
    if (!enabled) {
        return;
    }
    // ... enable logic
}

// Type narrowing guard
function processMessage(message: unknown): void {
    if (!isValidMessage(message)) {
        return;
    }
    // message is now typed as Message
    handleMessage(message);
}

// State guard
async function applyTheme(): Promise<void> {
    if (!Extension.isEnabled) {
        return;
    }

    if (Extension.startBarrier?.isPending()) {
        await Extension.startBarrier.entry();
    }

    // Apply theme...
}

// Multiple conditions combined
function shouldProcessURL(url: string | undefined): boolean {
    if (!url) return false;

    const parsed = parseURL(url);
    if (!parsed) return false;

    if (SKIP_PROTOCOLS.includes(parsed.protocol)) return false;

    return true;
}
```

## Async Guard Clauses

```typescript
async function loadTabData(tabId: number): Promise<TabData | null> {
    // Guards with early return
    const tab = await chrome.tabs.get(tabId).catch(() => null);
    if (!tab) {
        return null;
    }

    if (!tab.url || tab.url.startsWith('chrome://')) {
        return null;
    }

    // Main logic
    const host = parseURL(tab.url)?.hostname;
    const settings = await loadHostSettings(host);

    return { tab, host, settings };
}
```

## Why This Matters

- **Readability**: Main logic isn't buried in nested conditions
- **Maintainability**: Easy to add new guards without restructuring
- **Debugging**: Clear which condition caused early exit
- **Cognitive load**: Don't need to track multiple nested conditions
