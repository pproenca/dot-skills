---
title: Components Consume Tokens, Never Define Their Own
impact: HIGH
impactDescription: prevents token sprawl
tags: token, component, encapsulation, consistency
---

## Components Consume Tokens, Never Define Their Own

Every design value in a component should trace back to a global token. When components define their own magic numbers (`8px`, `#3b82f6`, `0.75rem`), the token system fractures. Visual consistency degrades silently because there is no central place to audit or update these values. If a component truly needs a unique value, promote it to the global token set so it becomes visible and governable.

**Incorrect (component-scoped magic values):**

```css
/* app/assets/stylesheets/components/card.css */
.card {
  border-radius: 8px;        /* Where did 8px come from? */
  padding: 24px;             /* Is this consistent with other components? */
  background: #ffffff;
  border: 1px solid #e5e7eb; /* Hardcoded gray — won't update with theme */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.card-header {
  font-size: 18px;           /* Doesn't match the typography scale */
  font-weight: 600;
  margin-bottom: 12px;       /* Another magic number */
  color: #1f2937;
}
```

**Correct (components consume global tokens via utilities):**

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.55 0.2 240);
  --color-surface: oklch(0.99 0 0);
  --color-border: oklch(0.9 0 0);
  --color-text: oklch(0.15 0 0);
  --color-text-muted: oklch(0.45 0 0);
  --radius-default: 0.5rem;
  --radius-lg: 0.75rem;
  --shadow-sm: 0 1px 2px oklch(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px oklch(0 0 0 / 0.07);
}
```

```erb
<%# app/views/shared/_card.html.erb %>
<%# No custom CSS needed — tokens consumed via Tailwind utilities %>
<div class="bg-surface border border-border rounded-lg shadow-sm p-6">
  <h3 class="text-xl font-semibold text-text mb-3">
    <%= title %>
  </h3>
  <div class="text-base text-text-muted">
    <%= yield %>
  </div>
</div>
```

**When a component needs a unique value, promote it:**

```css
/* Don't do this inside a component stylesheet */
.avatar {
  width: 40px;  /* Component-specific magic */
  height: 40px;
}

/* Instead, add it to the global token set */
@theme {
  --size-avatar: 2.5rem;
  --size-avatar-sm: 2rem;
  --size-avatar-lg: 3rem;
}
```

```erb
<%# Then reference the token %>
<img src="<%= user.avatar_url %>"
     class="size-avatar rounded-full"
     alt="<%= user.name %>">
```

**The only exception** is truly one-off decorative values (a specific animation curve, a unique illustration position) that have no chance of reuse. Even then, prefer a CSS variable referencing global tokens over a hardcoded value.

Reference: [Tailwind CSS v4 Theme Configuration](https://tailwindcss.com/docs/theme)
