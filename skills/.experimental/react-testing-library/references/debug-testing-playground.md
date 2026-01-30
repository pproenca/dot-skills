---
title: Use Testing Playground for Query Discovery
impact: LOW
impactDescription: finds optimal queries interactively, reduces trial-and-error
tags: debug, testing-playground, queries, browser
---

## Use Testing Playground for Query Discovery

Use `screen.logTestingPlaygroundURL()` or the Testing Playground browser extension to interactively find the best query for elements.

**Incorrect (trial and error queries):**

```tsx
test('submits contact form', () => {
  render(<ContactForm />)

  // Trying different queries until one works
  screen.getByTestId('submit-btn')     // Works but anti-pattern
  screen.getByText('Submit')           // Too fragile
  screen.querySelector('.btn-primary') // Implementation detail
})
```

**Correct (use Testing Playground):**

```tsx
test('submits contact form', () => {
  render(<ContactForm />)

  screen.logTestingPlaygroundURL()
  // Opens: https://testing-playground.com/#markup=...
  // Hover over submit button, playground suggests:
  // screen.getByRole('button', { name: /submit/i })

  screen.getByRole('button', { name: /submit/i })
})
```

**Benefits over manual inspection:**
- Suggests best query type (role, label, text)
- Shows accessible name for getByRole
- Warns about anti-pattern queries
- Tests queries in real-time

Reference: [Testing Playground](https://testing-playground.com)
