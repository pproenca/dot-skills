---
title: Testing validation functions
impact: MEDIUM
impactDescription: Thorough validation testing prevents bad data from corrupting extension state
tags: testing, validation, patterns
---

# Testing validation functions

Validation functions should be thoroughly tested with edge cases, invalid inputs, and boundary conditions. Use table-driven tests for comprehensive coverage.

## Table-Driven Tests

```typescript
// tests/unit/utils/validation.tests.ts
import { describe, it, expect } from 'vitest';
import { validateSettings, validateTheme } from '../../../src/utils/validation';
import { DEFAULT_SETTINGS, DEFAULT_THEME } from '../../../src/defaults';

describe('validateSettings', () => {
    const validCases = [
        {
            name: 'minimal valid settings',
            input: { enabled: true },
            expected: { enabled: true },
            errors: [],
        },
        {
            name: 'full valid settings',
            input: {
                enabled: true,
                automation: 'scheme-dark',
                brightness: 100,
            },
            expected: {
                enabled: true,
                automation: 'scheme-dark',
                brightness: 100,
            },
            errors: [],
        },
    ];

    const invalidCases = [
        {
            name: 'wrong type for enabled',
            input: { enabled: 'true' },
            expectedValue: {},
            expectedErrors: ['Invalid enabled value: true'],
        },
        {
            name: 'out of range brightness',
            input: { brightness: 999 },
            expectedValue: {},
            expectedErrors: ['Invalid brightness value: 999'],
        },
        {
            name: 'invalid automation value',
            input: { automation: 'invalid' },
            expectedValue: {},
            expectedErrors: ['Invalid automation value: invalid'],
        },
    ];

    describe('valid inputs', () => {
        validCases.forEach(({ name, input, expected, errors }) => {
            it(`should accept ${name}`, () => {
                const result = validateSettings(input);

                expect(result.value).toEqual(expected);
                expect(result.errors).toEqual(errors);
            });
        });
    });

    describe('invalid inputs', () => {
        invalidCases.forEach(({ name, input, expectedValue, expectedErrors }) => {
            it(`should reject ${name}`, () => {
                const result = validateSettings(input);

                expect(result.value).toEqual(expectedValue);
                expect(result.errors).toEqual(expectedErrors);
            });
        });
    });
});
```

## Boundary Testing

```typescript
describe('validateTheme', () => {
    describe('brightness bounds', () => {
        const boundaryTests = [
            { value: -1, shouldBeValid: false, description: 'below minimum' },
            { value: 0, shouldBeValid: true, description: 'at minimum' },
            { value: 100, shouldBeValid: true, description: 'at default' },
            { value: 200, shouldBeValid: true, description: 'at maximum' },
            { value: 201, shouldBeValid: false, description: 'above maximum' },
        ];

        boundaryTests.forEach(({ value, shouldBeValid, description }) => {
            it(`should ${shouldBeValid ? 'accept' : 'reject'} brightness ${description} (${value})`, () => {
                const result = validateTheme({ brightness: value });

                if (shouldBeValid) {
                    expect(result.value.brightness).toBe(value);
                    expect(result.errors).not.toContain(expect.stringContaining('brightness'));
                } else {
                    expect(result.errors).toContain(expect.stringContaining('brightness'));
                }
            });
        });
    });
});
```

## Edge Case Testing

```typescript
describe('edge cases', () => {
    it('should handle null input', () => {
        const result = validateSettings(null);

        expect(result.value).toEqual({});
        expect(result.errors).toContain('Settings must be an object');
    });

    it('should handle undefined input', () => {
        const result = validateSettings(undefined);

        expect(result.value).toEqual({});
        expect(result.errors).toContain('Settings must be an object');
    });

    it('should handle array input', () => {
        const result = validateSettings([1, 2, 3]);

        expect(result.value).toEqual({});
        expect(result.errors.length).toBeGreaterThan(0);
    });

    it('should handle extra properties gracefully', () => {
        const result = validateSettings({
            enabled: true,
            unknownProperty: 'ignored',
        });

        expect(result.value.enabled).toBe(true);
        expect(result.value).not.toHaveProperty('unknownProperty');
        expect(result.errors).toEqual([]);
    });

    it('should collect multiple errors', () => {
        const result = validateSettings({
            enabled: 'not boolean',
            brightness: 'not number',
            automation: 12345,
        });

        expect(result.errors.length).toBe(3);
    });
});
```

## Validation Integration Test

```typescript
describe('settings import validation', () => {
    it('should merge valid imported settings with defaults', () => {
        const imported = {
            enabled: false,
            brightness: 80,
            unknownField: 'ignored',
            contrast: 'invalid', // Will use default
        };

        const { value, errors } = validateSettings(imported);
        const merged = { ...DEFAULT_SETTINGS, ...value };

        expect(merged.enabled).toBe(false);       // From import
        expect(merged.brightness).toBe(80);       // From import
        expect(merged.contrast).toBe(100);        // Default (invalid value rejected)
        expect(errors).toContain(expect.stringContaining('contrast'));
    });
});
```

## Why This Matters

- **Data integrity**: Invalid data can corrupt extension state
- **User imports**: Settings imported from files/backups need validation
- **Sync data**: Data from chrome.storage.sync may be corrupted
- **Type safety**: Validates runtime data matches TypeScript types
