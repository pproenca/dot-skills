---
title: Every Interactive Element Has an Accessible Name
impact: CRITICAL
impactDescription: An unlabeled control is announced as "button" or "graphic" by screen readers — causing 100% task failure for ~2.5% of users (visually impaired); fails WCAG 1.3.1 + 4.1.2
tags: acc, accessibility, labels, aria-label, screen-reader, wcag-1-3-1, wcag-4-1-2
---

## Every Interactive Element Has an Accessible Name

Buttons, links, inputs, and form controls must have an accessible name announceable by screen readers. Prefer visible text labels — they help everyone. When only an icon is shown, add `aria-label`. For inputs, always pair with `<label htmlFor>`; never rely on `placeholder` as the label (it disappears on focus and has insufficient contrast).

**Incorrect (icon-only button, placeholder-as-label, decorative image announced):**

```tsx
function Header() {
  return (
    <header>
      <button onClick={() => setOpen(true)}>
        <Menu /> {/* announced as "button" — what does it open? */}
      </button>
      <img src="/avatar.png" /> {/* announced as "graphic" — misleading */}
      <input type="search" placeholder="Search" /> {/* no programmatic name */}
    </header>
  )
}
```

**Correct (every interactive element is named):**

```tsx
function Header({ user }: { user: User }) {
  return (
    <header>
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Open navigation menu"
        className="size-11 inline-flex items-center justify-center"
      >
        <Menu className="size-5" aria-hidden="true" />
      </button>

      <img
        src={user.avatarUrl}
        alt={`${user.name} avatar`}
      />

      {/* If the image is decorative, use alt="" — not aria-hidden alone on <img> */}
      <img src="/decorative-divider.svg" alt="" />

      <label htmlFor="header-search" className="sr-only">Search projects</label>
      <input
        id="header-search"
        type="search"
        placeholder="Search projects…"
        className="rounded-md border px-3 h-11"
      />
    </header>
  )
}
```

**Naming rules per element:**

```tsx
// Form field — visible label is best
<label htmlFor="email" className="block text-sm font-medium">Email</label>
<input id="email" type="email" />

// Icon-only button — aria-label describes the action
<Button size="icon" aria-label="Delete project">
  <Trash2 aria-hidden="true" className="size-4" />
</Button>

// Composite labels — combine with aria-labelledby
<section aria-labelledby="settings-heading">
  <h2 id="settings-heading">Settings</h2>
  ...
</section>

// Live state — toggle pressed/unpressed
<Button
  aria-pressed={pinned}
  aria-label={pinned ? 'Unpin from top' : 'Pin to top'}
  onClick={togglePin}
>
  <Pin />
</Button>
```

**Rule:**
- Every `<button>`, `<a>`, and form control passes the [accessible name computation](https://www.w3.org/TR/accname-1.2/) — verify with the Accessibility panel in Chrome DevTools
- Icon-only buttons must have `aria-label`; decorative icons inside labelled buttons get `aria-hidden="true"`
- Inputs always have a `<label htmlFor="...">` (use `className="sr-only"` to hide visually when the visible UI relies on context)
- Use `aria-pressed` for toggle buttons, `aria-expanded` for disclosure triggers, `aria-current="page"` for active nav links
- `placeholder` is never the only label — it disappears on focus, has poor contrast, and isn't announced as the field's name

Reference: [WCAG 4.1.2 Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)
