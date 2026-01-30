---
title: Prefer getByRole Over Other Queries
impact: CRITICAL
impactDescription: enables accessibility verification during testing
tags: query, getByRole, accessibility, best-practice
---

## Prefer getByRole Over Other Queries

`getByRole` is the primary recommended query because it matches how assistive technologies and users perceive your component. It tests the accessibility tree, not the DOM structure.

**Incorrect (tests implementation details):**

```tsx
render(<button className="submit-btn">Submit</button>)

const button = screen.getByTestId('submit-button')
// Tests internal attribute, not user-visible behavior
```

**Correct (tests accessible behavior):**

```tsx
render(<button className="submit-btn">Submit</button>)

const button = screen.getByRole('button', { name: /submit/i })
// Tests what users actually see and interact with
```

**Benefits:**
- Catches accessibility issues during testing
- More resilient to implementation changes
- Reflects how real users find elements

Reference: [Testing Library Query Priority](https://testing-library.com/docs/queries/about#priority)
