---
title: Browser API mocking
impact: MEDIUM
impactDescription: Mocking chrome/browser APIs enables unit testing extension logic
tags: testing, mocking, browser-extension
---

# Browser API mocking

Create mock implementations of browser extension APIs for unit testing. This allows testing background and content script logic without a browser.

## Basic Chrome API Mock

```typescript
// tests/helpers/chrome-mock.ts
import { vi } from 'vitest';

export function setupChromeMock(): void {
    const storage = new Map<string, unknown>();

    global.chrome = {
        runtime: {
            id: 'test-extension-id',
            lastError: null,
            onMessage: {
                addListener: vi.fn(),
                removeListener: vi.fn(),
            },
            onInstalled: {
                addListener: vi.fn(),
            },
            sendMessage: vi.fn().mockResolvedValue(undefined),
        },
        storage: {
            local: {
                get: vi.fn().mockImplementation((keys) => {
                    const result: Record<string, unknown> = {};
                    const keyArray = typeof keys === 'string' ? [keys] : keys;
                    keyArray.forEach((key: string) => {
                        if (storage.has(key)) {
                            result[key] = storage.get(key);
                        }
                    });
                    return Promise.resolve(result);
                }),
                set: vi.fn().mockImplementation((items) => {
                    Object.entries(items).forEach(([k, v]) => storage.set(k, v));
                    return Promise.resolve();
                }),
                clear: vi.fn().mockImplementation(() => {
                    storage.clear();
                    return Promise.resolve();
                }),
            },
            session: {
                get: vi.fn().mockResolvedValue({}),
                set: vi.fn().mockResolvedValue(undefined),
            },
        },
        tabs: {
            query: vi.fn().mockResolvedValue([]),
            get: vi.fn().mockResolvedValue(null),
            sendMessage: vi.fn().mockResolvedValue(undefined),
        },
        alarms: {
            create: vi.fn(),
            clear: vi.fn().mockResolvedValue(true),
            get: vi.fn().mockResolvedValue(null),
            getAll: vi.fn().mockResolvedValue([]),
            onAlarm: {
                addListener: vi.fn(),
            },
        },
        scripting: {
            executeScript: vi.fn().mockResolvedValue([]),
            insertCSS: vi.fn().mockResolvedValue(undefined),
            removeCSS: vi.fn().mockResolvedValue(undefined),
        },
    } as unknown as typeof chrome;
}

export function resetChromeMock(): void {
    vi.clearAllMocks();
}
```

## Using Mocks in Tests

```typescript
// tests/unit/background/tab-manager.tests.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { setupChromeMock, resetChromeMock } from '../../helpers/chrome-mock';
import { TabManager } from '../../../src/background/tab-manager';

describe('TabManager', () => {
    beforeEach(() => {
        setupChromeMock();
    });

    afterEach(() => {
        resetChromeMock();
    });

    it('should get active tab', async () => {
        const mockTab = { id: 1, url: 'https://example.com' };
        vi.mocked(chrome.tabs.query).mockResolvedValue([mockTab]);

        const tab = await TabManager.getActiveTab();

        expect(chrome.tabs.query).toHaveBeenCalledWith({
            active: true,
            currentWindow: true,
        });
        expect(tab).toEqual(mockTab);
    });

    it('should handle no active tab', async () => {
        vi.mocked(chrome.tabs.query).mockResolvedValue([]);

        const tab = await TabManager.getActiveTab();

        expect(tab).toBeNull();
    });
});
```

## Mock Factory Pattern

```typescript
// tests/helpers/factories.ts
export function createMockTab(overrides: Partial<chrome.tabs.Tab> = {}): chrome.tabs.Tab {
    return {
        id: 1,
        index: 0,
        windowId: 1,
        active: true,
        pinned: false,
        highlighted: false,
        incognito: false,
        url: 'https://example.com',
        title: 'Example',
        favIconUrl: undefined,
        status: 'complete',
        discarded: false,
        autoDiscardable: true,
        groupId: -1,
        ...overrides,
    };
}

export function createMockAlarm(name: string, overrides: Partial<chrome.alarms.Alarm> = {}): chrome.alarms.Alarm {
    return {
        name,
        scheduledTime: Date.now() + 60000,
        ...overrides,
    };
}
```

## Message Handler Testing

```typescript
// tests/unit/background/messenger.tests.ts
describe('Messenger', () => {
    let messageListener: (
        message: Message,
        sender: chrome.runtime.MessageSender,
        sendResponse: (response: unknown) => void
    ) => boolean;

    beforeEach(() => {
        setupChromeMock();

        // Capture the message listener
        vi.mocked(chrome.runtime.onMessage.addListener).mockImplementation((fn) => {
            messageListener = fn;
        });

        Messenger.init();
    });

    it('should handle GET_DATA message', async () => {
        const sendResponse = vi.fn();
        const mockData = { settings: DEFAULT_SETTINGS };
        vi.spyOn(Extension, 'collect').mockResolvedValue(mockData);

        const keepOpen = messageListener(
            { type: MessageTypeUItoBG.GET_DATA },
            { id: chrome.runtime.id },
            sendResponse
        );

        expect(keepOpen).toBe(true);

        await vi.waitFor(() => {
            expect(sendResponse).toHaveBeenCalledWith(mockData);
        });
    });
});
```

## Why This Matters

- **Fast tests**: No browser needed for unit tests
- **Isolated testing**: Test logic without side effects
- **CI/CD friendly**: Tests run in Node.js environment
- **Predictable**: Control exact API responses
