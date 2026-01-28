---
title: Constants and configuration values
impact: MEDIUM
impactDescription: Clear distinction between mutable variables and immutable constants
tags: naming, constants, configuration
---

# Constants and configuration values

Use SCREAMING_SNAKE_CASE for module-level constants and static readonly class properties.

## Incorrect

```typescript
const saveTimeout = 1000;
const alarmName = 'auto-time-alarm';
const maxRetries = 3;

class TabManager {
    static readonly pollingInterval = 5000;
}
```

## Correct

```typescript
const SAVE_TIMEOUT = 1000;
const MAX_RETRIES = 3;

class TabManager {
    private static readonly ALARM_NAME = 'auto-time-alarm';
    private static readonly POLLING_INTERVAL = 5000;
}

// Group related constants
const DEFAULTS = {
    THEME_BRIGHTNESS: 100,
    THEME_CONTRAST: 100,
    THEME_SEPIA: 0,
} as const;
```

## Defaults File Pattern

Keep default values in a dedicated `defaults.ts` file at the src root:

```typescript
// src/defaults.ts
export const DEFAULT_SETTINGS: UserSettings = {
    enabled: true,
    automation: '',
    time: { activation: '18:00', deactivation: '9:00' },
};

export const DEFAULT_THEME: Theme = {
    mode: 1,
    brightness: 100,
    contrast: 100,
    grayscale: 0,
    sepia: 0,
};

export const DEFAULT_COLORS = {
    darkScheme: { background: '#181a1b', text: '#e8e6e3' },
    lightScheme: { background: '#dcdad7', text: '#181a1b' },
};
```

## Why This Matters

- **Immutability signal**: SCREAMING_CASE indicates values that should never change
- **Centralized defaults**: One place to find all default values
- **Type safety**: `as const` ensures literal types
