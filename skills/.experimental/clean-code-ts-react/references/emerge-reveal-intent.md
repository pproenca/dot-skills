---
title: Maximize Expressiveness — Code as Communication
impact: MEDIUM
impactDescription: Names and structure communicate purpose; bytecode is a side effect
tags: emerge, naming, expressiveness, readability
---

## Maximize Expressiveness — Code as Communication

Code is communication first, instruction to the machine second. Every name, every type, every structural choice either reveals or obscures intent. The reader is the customer; the bytecode is a side effect. The cost of an unclear name is paid by every future reader, including yourself in six months.

**Incorrect (abbreviated names, opaque string literals, vague verbs):**

```tsx
function process(users: User[]) {
  // What status is 'a'? What does processStuff do? Why these users?
  const u = users.filter((x) => x.s === 'a');
  return processStuff(u);
}
```

**Correct (every name carries meaning):**

```tsx
function sendMonthlyNewsletter(users: User[]) {
  // status, 'active', sendMonthlyNewsletter — each name reveals what and why.
  const activeUsers = users.filter((user) => user.status === 'active');
  return enqueueNewsletterDelivery(activeUsers);
}
```

**When NOT to apply this pattern:**
- Tight inner loops and hot paths where verbose locals genuinely hurt readability for the cycle (rare in app code; common in numerics).
- Conventional cryptic forms — matrix math with `M`, `v`, indices `i`/`j`, `x`/`y`/`z` for vectors — where the convention itself IS the readable form.
- Minified production bundles — they're not human-read by definition; the source is what matters.

**Why this matters:** A program's lifetime cost is dominated by reading, not writing. Optimizing names for the reader is the highest-leverage cleanup you can do.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Rich Hickey — Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy/)
