---
title: Type guard functions
impact: MEDIUM
impactDescription: Type guards enable TypeScript to narrow types based on runtime checks
tags: typescript, type-safety, patterns
---

# Type guard functions

Create type guard functions for validating unknown data at runtime. Name them with `is` prefix and use `x is T` return type.

## Basic Type Guards

```typescript
// Primitive type guards
function isBoolean(x: unknown): x is boolean {
    return typeof x === 'boolean';
}

function isString(x: unknown): x is string {
    return typeof x === 'string';
}

function isNumber(x: unknown): x is number {
    return typeof x === 'number' && !isNaN(x);
}

function isNonEmptyString(x: unknown): x is string {
    return typeof x === 'string' && x.length > 0;
}

// Usage
function processValue(value: unknown): void {
    if (isString(value)) {
        // TypeScript knows value is string here
        console.log(value.toLowerCase());
    }
}
```

## Complex Object Type Guards

```typescript
interface UserSettings {
    enabled: boolean;
    brightness: number;
    theme: Theme;
}

function isUserSettings(x: unknown): x is UserSettings {
    if (typeof x !== 'object' || x === null) {
        return false;
    }

    const obj = x as Record<string, unknown>;

    return (
        isBoolean(obj.enabled) &&
        isNumber(obj.brightness) &&
        isTheme(obj.theme)
    );
}

// Partial object guard
function isPartialUserSettings(x: unknown): x is Partial<UserSettings> {
    if (typeof x !== 'object' || x === null) {
        return false;
    }

    const obj = x as Record<string, unknown>;

    if ('enabled' in obj && !isBoolean(obj.enabled)) return false;
    if ('brightness' in obj && !isNumber(obj.brightness)) return false;
    if ('theme' in obj && !isTheme(obj.theme)) return false;

    return true;
}
```

## Message Type Guards

```typescript
interface GetDataMessage {
    type: MessageTypeUItoBG.GET_DATA;
}

interface ChangeSettingsMessage {
    type: MessageTypeUItoBG.CHANGE_SETTINGS;
    data: Partial<UserSettings>;
}

type UIMessage = GetDataMessage | ChangeSettingsMessage;

function isGetDataMessage(msg: unknown): msg is GetDataMessage {
    return (
        typeof msg === 'object' &&
        msg !== null &&
        (msg as GetDataMessage).type === MessageTypeUItoBG.GET_DATA
    );
}

function isChangeSettingsMessage(msg: unknown): msg is ChangeSettingsMessage {
    return (
        typeof msg === 'object' &&
        msg !== null &&
        (msg as ChangeSettingsMessage).type === MessageTypeUItoBG.CHANGE_SETTINGS &&
        isPartialUserSettings((msg as ChangeSettingsMessage).data)
    );
}

// Usage in message handler
function handleMessage(message: unknown): void {
    if (isGetDataMessage(message)) {
        return handleGetData();
    }

    if (isChangeSettingsMessage(message)) {
        // TypeScript knows message.data is Partial<UserSettings>
        return handleChangeSettings(message.data);
    }

    logWarn('Unknown message type:', message);
}
```

## Array Type Guards

```typescript
function isArrayOf<T>(
    arr: unknown,
    guard: (item: unknown) => item is T
): arr is T[] {
    return Array.isArray(arr) && arr.every(guard);
}

// Usage
function isStringArray(x: unknown): x is string[] {
    return isArrayOf(x, isString);
}

function isTabInfoArray(x: unknown): x is TabInfo[] {
    return isArrayOf(x, isTabInfo);
}
```

## Why This Matters

- **Type safety**: Validate external data matches expected types
- **Type narrowing**: TypeScript understands the type after the check
- **Reusability**: Type guards can be composed and reused
- **Runtime safety**: Catches type mismatches that TypeScript can't see
