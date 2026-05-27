---
title: Animate only with a purpose
tags: motion, animation, restraint
---

## Animate only with a purpose

Adding transitions to everything — especially high-frequency or keyboard-triggered actions like toggling a sidebar — makes the interface feel slow, because the user waits through the same motion hundreds of times a day. Animate to aid understanding (entrance, state change, spatial continuity), and skip it for frequent, repeated actions.

```css
/* Occasional: a modal earns an entrance animation */
.modal { transition: opacity 200ms, transform 200ms; }

/* High-frequency: a sidebar toggled on every navigation responds instantly */
.sidebar { /* no transition — instant on each repeated use */ }
```

Reference: [Emil Kowalski — You don't need animations](https://emilkowal.ski/ui/you-dont-need-animations)
