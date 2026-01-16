---
title: Respect User Motion Preferences
impact: LOW-MEDIUM
impactDescription: prevents motion sickness for 35% of users affected by vestibular disorders
tags: anim, reduced-motion, accessibility, prefers-reduced-motion, css
---

## Respect User Motion Preferences

Animations can trigger motion sickness, migraines, and seizures in users with vestibular disorders. The `prefers-reduced-motion` media query lets you provide a reduced-motion experience.

**Incorrect (ignoring motion preferences):**

```css
.hero {
  animation: parallax-float 10s infinite;
}

.page-transition {
  animation: slide-in 0.5s ease-out;
}

.notification {
  animation: shake 0.3s ease-in-out;
}
/* Users with motion sensitivity have no way to opt out */
/* Can cause nausea, dizziness, or seizures */
```

**Correct (respecting reduced-motion preference):**

```css
/* Default animations for users who haven't opted out */
.hero {
  animation: parallax-float 10s infinite;
}

.page-transition {
  animation: slide-in 0.5s ease-out;
}

/* Disable or simplify for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  .hero {
    animation: none;
  }

  .page-transition {
    animation: fade-in 0.2s ease-out; /* Simple opacity fade instead */
  }

  /* Disable all decorative animations globally */
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Alternative: Start with no motion, opt-in */
@media (prefers-reduced-motion: no-preference) {
  .hero {
    animation: parallax-float 10s infinite;
  }
}
```

**Motion that should be reduced/removed:**
- Parallax scrolling effects
- Auto-playing carousels and sliders
- Decorative floating/pulsing elements
- Complex page transitions
- Background video

**Motion that can remain:**
- Essential state change indicators
- Loading spinners (simplified)
- Simple opacity fades

Reference: [web.dev prefers-reduced-motion](https://web.dev/articles/prefers-reduced-motion)
