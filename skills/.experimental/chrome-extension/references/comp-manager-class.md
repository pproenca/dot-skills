---
title: Manager class pattern for background
impact: HIGH
impactDescription: Singleton managers provide clear initialization and API for background script services
tags: patterns, background, singleton, architecture
---

# Manager class pattern for background

Use classes with static methods for singleton managers in background scripts. Initialize with a static `init()` method.

## Incorrect

```typescript
// Object literal lacks type safety and clear initialization
const messenger = {
    adapter: null,
    init: (adapter) => { messenger.adapter = adapter; },
    send: (msg) => { messenger.adapter.send(msg); },
};

// Instantiated class creates multiple instances
class TabManager {
    constructor(private adapter: ExtensionAdapter) {}
}
const manager = new TabManager(adapter);
```

## Correct

```typescript
export default class Messenger {
    private static adapter: ExtensionAdapter;
    private static onMessage: (msg: Message) => void;

    static init(adapter: ExtensionAdapter): void {
        Messenger.adapter = adapter;
        chrome.runtime.onMessage.addListener(Messenger.handleMessage);
    }

    private static handleMessage(
        message: Message,
        sender: chrome.runtime.MessageSender,
        sendResponse: (response: any) => void
    ): boolean {
        // Handle message
        return true; // Keep channel open for async response
    }

    static sendToContentScript(tabId: number, message: Message): void {
        chrome.tabs.sendMessage(tabId, message);
    }
}

// In background entry point
import Messenger from './messenger';
import TabManager from './tab-manager';
import UserStorage from './user-storage';

async function init(): Promise<void> {
    await UserStorage.init();
    TabManager.init();
    Messenger.init(createAdapter());
}
```

## Benefits

- **Single instance**: Static methods guarantee one instance per context
- **Clear initialization**: `init()` method explicitly sets up the manager
- **Testable**: Can mock static methods in tests
- **Type safety**: Full TypeScript support for all methods
- **Encapsulation**: Private static members hide implementation details

## When NOT to Use

For simple utilities that don't need state, use plain functions instead:

```typescript
// Good: stateless utility
export function parseURL(url: string): URL | null { }

// Overkill: no state needed
export class URLParser {
    static parse(url: string): URL | null { }
}
```
