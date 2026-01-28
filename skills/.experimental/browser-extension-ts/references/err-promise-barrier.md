---
title: PromiseBarrier for async coordination
impact: MEDIUM
impactDescription: Coordinates initialization sequences without race conditions
tags: error-handling, async, patterns
---

# PromiseBarrier for async coordination

Use the PromiseBarrier pattern for coordinating async operations that need to wait for initialization to complete. This prevents race conditions during extension startup.

## The Problem

Browser extensions have complex startup sequences:
1. Background script starts
2. Storage needs to load
3. UI popup opens (may be before storage is ready)
4. Content scripts connect (may be before background is ready)

Without coordination, components may try to use uninitialized state.

## Incorrect

```typescript
// Polling with arbitrary timeout
let isReady = false;

async function waitForReady(): Promise<void> {
    while (!isReady) {
        await new Promise((r) => setTimeout(r, 100));
    }
}

// Race condition: multiple callers may proceed before ready
async function getData(): Promise<Data> {
    if (!isReady) {
        await waitForReady();
    }
    return data;  // May still not be ready!
}
```

## Correct

```typescript
// PromiseBarrier implementation
class PromiseBarrier {
    private promise: Promise<void>;
    private resolve!: () => void;
    private pending = true;

    constructor() {
        this.promise = new Promise<void>((resolve) => {
            this.resolve = resolve;
        });
    }

    isPending(): boolean {
        return this.pending;
    }

    async entry(): Promise<void> {
        return this.promise;
    }

    resolve(): void {
        this.pending = false;
        this.resolve();
    }
}

// Usage in Extension class
class Extension {
    static startBarrier: PromiseBarrier | null = new PromiseBarrier();
    private static data: ExtensionData;

    static async init(): Promise<void> {
        // Load all required data
        const settings = await UserStorage.loadSettings();
        const theme = await UserStorage.loadTheme();

        Extension.data = { settings, theme };

        // Signal that initialization is complete
        Extension.startBarrier!.resolve();
        Extension.startBarrier = null;  // Allow GC
    }

    static async collect(): Promise<ExtensionData> {
        // Wait for initialization if still pending
        if (Extension.startBarrier?.isPending()) {
            await Extension.startBarrier.entry();
        }

        return Extension.data;
    }
}

// In message handler
async function onGetData(): Promise<ExtensionData> {
    // Safe - will wait for init if needed
    return Extension.collect();
}
```

## Multiple Barriers Pattern

```typescript
class ExtensionLifecycle {
    static storageBarrier = new PromiseBarrier();
    static uiBarrier = new PromiseBarrier();
    static contentScriptBarrier = new PromiseBarrier();

    static async initStorage(): Promise<void> {
        await loadAllStorage();
        this.storageBarrier.resolve();
    }

    static async initUI(): Promise<void> {
        // UI depends on storage
        await this.storageBarrier.entry();
        await setupUI();
        this.uiBarrier.resolve();
    }

    static async waitForFullInit(): Promise<void> {
        await Promise.all([
            this.storageBarrier.entry(),
            this.uiBarrier.entry(),
        ]);
    }
}
```

## Why This Matters

- **No race conditions**: Multiple callers safely wait for same initialization
- **Clear dependencies**: Barriers make initialization order explicit
- **No polling**: Efficient promise-based waiting
- **One-time resolution**: Barrier can only resolve once
