---
title: Maintain a Test List
impact: CRITICAL
impactDescription: prevents scope creep and forgotten cases
tags: cycle, planning, test-list, organization
---

## Maintain a Test List

Before coding, write down all the test cases you can think of. Work through them one at a time. This prevents scope creep during implementation and ensures edge cases aren't forgotten.

**Incorrect (ad-hoc test discovery):**

```typescript
// Start coding without a plan
test('parses valid JSON', () => {
  expect(parseConfig('{"key": "value"}')).toEqual({ key: 'value' })
})
// Pass, move on

test('handles nested objects', () => {
  expect(parseConfig('{"a": {"b": 1}}')).toEqual({ a: { b: 1 } })
})
// Pass, move on, forget about error cases

// Ship to production, crashes on invalid input
// Edge cases discovered by users, not tests
```

**Correct (test list first):**

```typescript
/*
 * Test List for parseConfig:
 * [x] parses valid JSON object
 * [x] parses nested objects
 * [x] parses arrays
 * [ ] throws on invalid JSON syntax
 * [ ] throws on non-object root (array, string, number)
 * [ ] handles empty object {}
 * [ ] handles unicode characters
 * [ ] handles escaped quotes in strings
 */

// Work through list systematically
test('parses valid JSON object', () => {
  expect(parseConfig('{"key": "value"}')).toEqual({ key: 'value' })
})

test('throws on invalid JSON syntax', () => {
  expect(() => parseConfig('{invalid}')).toThrow('Invalid JSON')
})

test('throws on non-object root', () => {
  expect(() => parseConfig('[1, 2, 3]')).toThrow('Config must be an object')
})

// Add new cases to list as you discover them
// Cross off completed tests
```

**Managing the test list:**
- Keep it visible (comment block, sticky note, or task tracker)
- Add new cases as you think of them during implementation
- Prioritize by risk and importance
- Don't remove items, mark them done

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
