---
title: Validation returns errors array
impact: HIGH
impactDescription: Non-throwing validation enables partial recovery and better error reporting
tags: error-handling, validation, patterns
---

# Validation returns errors array

Validation functions should return an object with errors array and corrected values, not throw exceptions. This allows callers to decide how to handle errors and enables partial recovery.

## Incorrect

```typescript
// Throws on first error - all or nothing
function validateSettings(settings: unknown): UserSettings {
    if (typeof settings !== 'object') {
        throw new Error('Settings must be an object');
    }
    if (typeof settings.enabled !== 'boolean') {
        throw new Error('enabled must be boolean');
    }
    // ...
    return settings as UserSettings;
}

// Caller can't recover
try {
    const settings = validateSettings(input);
} catch (err) {
    // Lost all the valid properties
    settings = DEFAULT_SETTINGS;
}
```

## Correct

```typescript
interface ValidationResult<T> {
    value: T;
    errors: string[];
}

function validateSettings(
    input: unknown
): ValidationResult<Partial<UserSettings>> {
    const errors: string[] = [];
    const settings: Partial<UserSettings> = {};

    if (typeof input !== 'object' || input === null) {
        return { value: {}, errors: ['Settings must be an object'] };
    }

    const obj = input as Record<string, unknown>;

    // Validate each property, collecting errors
    if ('enabled' in obj) {
        if (typeof obj.enabled === 'boolean') {
            settings.enabled = obj.enabled;
        } else {
            errors.push(`Invalid enabled value: ${obj.enabled}`);
        }
    }

    if ('brightness' in obj) {
        const brightness = Number(obj.brightness);
        if (!isNaN(brightness) && brightness >= 0 && brightness <= 200) {
            settings.brightness = brightness;
        } else {
            errors.push(`Invalid brightness value: ${obj.brightness}`);
        }
    }

    // ... validate other properties

    return { value: settings, errors };
}

// Caller can handle partial success
const { value, errors } = validateSettings(imported);
if (errors.length > 0) {
    logWarn('Settings validation errors:', errors);
}
// Apply valid properties, keep defaults for invalid ones
const settings = { ...DEFAULT_SETTINGS, ...value };
```

## Validator Helper Pattern

```typescript
type Validator<T> = (value: unknown) => value is T;

function validateProperty<T>(
    obj: Record<string, unknown>,
    key: string,
    validator: Validator<T>,
    fallback: T,
    errors: string[
): T {
    if (!(key in obj)) {
        return fallback;
    }

    if (validator(obj[key])) {
        return obj[key] as T;
    }

    errors.push(`Unexpected value for "${key}": ${obj[key]}`);
    return fallback;
}

// Type guards
const isBoolean = (x: unknown): x is boolean => typeof x === 'boolean';
const isString = (x: unknown): x is string => typeof x === 'string';
const isNumber = (x: unknown): x is number => typeof x === 'number' && !isNaN(x);

// Usage
function validateTheme(input: unknown): ValidationResult<Theme> {
    const errors: string[] = [];
    const obj = (input ?? {}) as Record<string, unknown>;

    return {
        value: {
            mode: validateProperty(obj, 'mode', isNumber, 1, errors),
            brightness: validateProperty(obj, 'brightness', isNumber, 100, errors),
            contrast: validateProperty(obj, 'contrast', isNumber, 100, errors),
            grayscale: validateProperty(obj, 'grayscale', isNumber, 0, errors),
            sepia: validateProperty(obj, 'sepia', isNumber, 0, errors),
        },
        errors,
    };
}
```

## Why This Matters

- **Partial recovery**: Valid properties are preserved even if some fail
- **Error aggregation**: All errors reported at once, not just the first
- **User feedback**: Can show all validation issues in UI
- **Flexible handling**: Caller decides whether to warn, reject, or accept
