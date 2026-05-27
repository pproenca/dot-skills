---
title: Check dimensional, type, or category consistency
tags: constrain, dimensions, types
---

## Check dimensional, type, or category consistency

Physicists never write an equation without checking units; the same discipline catches a large class of software bugs before the code runs. The agent's default is to combine quantities by syntax (whatever compiles, whatever the type system allows) rather than by category. When the categories disagree, the result is meaningless even when the program runs.

```typescript
// Compiles. Looks reasonable. Is silently wrong.
function recordLogin(user: Promise<User>) {
  analytics.track('login', { userId: user.id });
  //                                  ^^^^^^^
  // `user` is a Promise<User>, not a User. `.id` is undefined.
  // Categories: Promise<User>.id ≠ User.id. The dimensions disagree,
  // even when the TypeScript checker is permissive enough to let it
  // through (any-typed callers, optional-chained reads, generated types).
}

// Correct: await before crossing the category boundary.
async function recordLogin(userP: Promise<User>) {
  const user = await userP;
  analytics.track('login', { userId: user.id });
}
```

The same check catches a large family of bugs that the type system or runtime cannot:

```text
- Adding amounts in different currencies (EUR + USD treated as the same number).
- Mixing tz-naive and tz-aware timestamps in a comparison.
- Adding "duration since epoch" to "duration of this request".
- Comparing UTF-16 code-unit lengths to grapheme counts ("rendered length").
- Dividing "requests" by "window milliseconds" but labelling the result "per second".
- Passing a path relative to one root through an API expecting relative to another.
```

A useful habit: before running the calculation, write the dimensions of every input and the dimension of the output. If the equation cannot produce the output dimension from the input dimensions, the equation is wrong — regardless of what the type checker says.

Reference: [Bridgman — Dimensional Analysis (Yale UP, 1922); standard in physics and engineering curricula](https://en.wikipedia.org/wiki/Dimensional_analysis)
