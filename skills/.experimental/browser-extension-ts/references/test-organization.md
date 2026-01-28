---
title: Test file organization
impact: MEDIUM
impactDescription: Consistent test structure improves maintainability and test discovery
tags: testing, organization, structure
---

# Test file organization

Place tests in a `tests/` directory mirroring the source structure. Use `.tests.ts` suffix for test files.

## Directory Structure

```
project/
├── src/
│   ├── background/
│   │   ├── index.ts
│   │   └── tab-manager.ts
│   ├── utils/
│   │   ├── color.ts
│   │   └── url.ts
│   └── inject/
│       └── style-manager.ts
└── tests/
    ├── unit/
    │   ├── background/
    │   │   └── tab-manager.tests.ts
    │   └── utils/
    │       ├── color.tests.ts
    │       └── url.tests.ts
    ├── integration/
    │   └── messaging.tests.ts
    └── browser/
        └── popup.tests.ts
```

## Test File Naming

```typescript
// Matches: src/utils/color.ts
// Test:    tests/unit/utils/color.tests.ts

// Matches: src/background/tab-manager.ts
// Test:    tests/unit/background/tab-manager.tests.ts

// Note: .tests.ts (not .test.ts or .spec.ts)
```

## Test File Structure

```typescript
// tests/unit/utils/color.tests.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { parseColor, rgbaToHex, mixColors } from '../../../src/utils/color';

describe('color utilities', () => {
    describe('parseColor', () => {
        it('should parse hex colors', () => {
            expect(parseColor('#ff0000')).toEqual({ r: 255, g: 0, b: 0, a: 1 });
        });

        it('should parse rgb colors', () => {
            expect(parseColor('rgb(255, 0, 0)')).toEqual({ r: 255, g: 0, b: 0, a: 1 });
        });

        it('should return null for invalid colors', () => {
            expect(parseColor('invalid')).toBeNull();
        });
    });

    describe('rgbaToHex', () => {
        it('should convert rgba to hex', () => {
            expect(rgbaToHex({ r: 255, g: 0, b: 0, a: 1 })).toBe('#ff0000');
        });
    });
});
```

## Test Categories

| Category | Location | Purpose |
|----------|----------|---------|
| Unit | `tests/unit/` | Test individual functions/classes in isolation |
| Integration | `tests/integration/` | Test multiple modules working together |
| Browser | `tests/browser/` | Tests requiring actual browser APIs |
| E2E | `tests/e2e/` | Full extension tests with Playwright/Puppeteer |

## Shared Test Utilities

```typescript
// tests/helpers/mocks.ts
export function createMockTab(overrides?: Partial<chrome.tabs.Tab>): chrome.tabs.Tab {
    return {
        id: 1,
        index: 0,
        windowId: 1,
        active: true,
        pinned: false,
        highlighted: false,
        incognito: false,
        url: 'https://example.com',
        ...overrides,
    };
}

export function createMockSettings(overrides?: Partial<UserSettings>): UserSettings {
    return {
        ...DEFAULT_SETTINGS,
        ...overrides,
    };
}

// tests/helpers/browser-mock.ts
export function mockChromeStorage(): void {
    const storage = new Map<string, unknown>();

    global.chrome = {
        storage: {
            local: {
                get: vi.fn((keys) => Promise.resolve(
                    Object.fromEntries(
                        (Array.isArray(keys) ? keys : [keys]).map((k) => [k, storage.get(k)])
                    )
                )),
                set: vi.fn((items) => {
                    Object.entries(items).forEach(([k, v]) => storage.set(k, v));
                    return Promise.resolve();
                }),
            },
        },
    } as unknown as typeof chrome;
}
```

## Why This Matters

- **Discoverability**: Easy to find tests for any source file
- **Consistency**: Team members know where to add new tests
- **Test runner**: Glob patterns work predictably (`**/*.tests.ts`)
- **Separation**: Clear distinction between test types
