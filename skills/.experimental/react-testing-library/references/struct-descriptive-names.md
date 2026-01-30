---
title: Use Descriptive Test Names
impact: LOW-MEDIUM
impactDescription: 2-3× faster failure diagnosis from test output
tags: struct, naming, readability, documentation
---

## Use Descriptive Test Names

Test names should describe the behavior being tested, not the implementation. Good names serve as documentation.

**Incorrect (vague or implementation-focused):**

```tsx
test('renders', () => { /* ... */ })

test('handleClick', () => { /* ... */ })

test('should work', () => { /* ... */ })

test('useState', () => { /* ... */ })
// What behavior do these verify?
```

**Correct (behavior-focused):**

```tsx
test('displays user name when loaded', () => { /* ... */ })

test('increments counter when plus button clicked', () => { /* ... */ })

test('shows error message for invalid email', () => { /* ... */ })

test('disables submit button while form is submitting', () => { /* ... */ })
```

**Pattern: describes what happens under what conditions:**

```tsx
describe('LoginForm', () => {
  test('shows validation error when email is empty', () => {})
  test('shows validation error when password is too short', () => {})
  test('calls onSubmit with credentials when form is valid', () => {})
  test('disables submit button during authentication', () => {})
  test('redirects to dashboard on successful login', () => {})
})
```

**Avoid "should" prefix - it's redundant:**

```tsx
// Unnecessary
test('should display error message', () => {})

// Cleaner
test('displays error message when validation fails', () => {})
```
