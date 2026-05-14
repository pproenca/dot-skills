---
title: Test Code Deserves Production-Grade Care
impact: MEDIUM
impactDescription: Readable tests make production code feel safe to change
tags: test, readability, fixtures, naming
---

## Test Code Deserves Production-Grade Care

Tests get read, modified, and debugged more often than they're written. Bad test code — copy-pasted setup, single-letter variables, unexplained numeric literals — makes production code feel risky to change because the tests are unreadable. Apply the same naming, structure, and DRY discipline you'd apply to shipped code.

**Incorrect (mystery variables and unexplained literals):**

```ts
import { test, expect } from 'vitest';
import { login } from './login';

test('it works', () => {
  const u = { id: '123', e: 'a@b.c', n: 'A' };
  const r = login(u);
  // What is `x`? Why 1? Reader has to read login() to understand the test.
  expect(r.x).toBe(1);
});
```

**Correct (domain names, intent in the assertion):**

```ts
import { test, expect } from 'vitest';
import { login } from './login';

test('returning user skips the onboarding flow', () => {
  const returningUser = {
    id: 'usr_123',
    email: 'alice@example.com',
    name: 'Alice',
    completedOnboardingAt: new Date('2024-01-01'),
  };

  const result = login(returningUser);

  // Named domain field and expected behavior — readable as documentation.
  expect(result.shouldShowOnboarding).toBe(false);
});
```

**When NOT to apply this pattern:**
- Throwaway diagnostic tests written to reproduce a bug — they're temporary scaffolding and should be deleted before merge.
- Snapshot / golden tests where exact equality IS the assertion and adding domain narrative just adds noise.
- Property-based or fuzzer-generated tests where the inputs are intentionally synthetic — clarity rules apply to the property, not each generated case.

**Why this matters:** A codebase's confidence ceiling is set by its tests. Tests that read like documentation lift that ceiling; tests that read like puzzles lower it.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Kent C. Dodds — Avoid Nesting When You're Testing](https://kentcdodds.com/blog/avoid-nesting-when-youre-testing)
