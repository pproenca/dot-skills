---
title: Avoid Adding Redundant ARIA Roles
impact: HIGH
impactDescription: maintains semantic HTML and proper accessibility
tags: anti, aria, roles, accessibility, semantic-html
---

## Avoid Adding Redundant ARIA Roles

Don't add `role` attributes that elements already have implicitly. This clutters the DOM and can confuse assistive technologies.

**Incorrect (redundant roles):**

```tsx
render(
  <nav role="navigation">
    <button role="button" onClick={handleClick}>
      Submit
    </button>
    <a href="/home" role="link">Home</a>
  </nav>
)

screen.getByRole('button', { name: /submit/i })
// Works, but role="button" is redundant
```

**Correct (semantic HTML):**

```tsx
render(
  <nav>
    <button onClick={handleClick}>Submit</button>
    <a href="/home">Home</a>
  </nav>
)

screen.getByRole('button', { name: /submit/i })
// Works with implicit role from semantic HTML
```

**Implicit roles to remember:**
| Element | Implicit Role |
|---------|--------------|
| `<button>` | button |
| `<a href>` | link |
| `<nav>` | navigation |
| `<main>` | main |
| `<header>` | banner |
| `<footer>` | contentinfo |
| `<input type="checkbox">` | checkbox |

**When explicit roles ARE needed:**
- `<div>` acting as a button (but prefer `<button>`)
- Custom components without semantic elements

Reference: [Common Mistakes - Adding aria- and role Attributes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library#adding-aria--and-role-attributes-incorrectly)
