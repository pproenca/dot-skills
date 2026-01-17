---
title: Follow Consistent Test File Structure
impact: MEDIUM
impactDescription: reduces time finding tests
tags: org, file-structure, conventions, naming
---

## Follow Consistent Test File Structure

Establish and follow a consistent pattern for test file location and naming. Developers should instantly know where to find tests for any code.

**Incorrect (inconsistent structure):**

```text
src/
  services/
    userService.ts
    tests/
      userService.spec.ts
  models/
    user.ts
tests/
  models/
    user.test.ts
spec/
  integration/
    user_tests.js
__tests__/
  userStuff.ts
```

**Correct (consistent co-located tests):**

```text
src/
  services/
    userService.ts
    userService.test.ts        # Unit tests next to source
  models/
    user.ts
    user.test.ts
  components/
    UserProfile.tsx
    UserProfile.test.tsx
tests/
  integration/                  # Integration tests separate
    user-registration.test.ts
    checkout-flow.test.ts
  e2e/                         # E2E tests separate
    user-journey.test.ts
```

**Alternative (mirror structure):**

```text
src/
  services/
    userService.ts
  models/
    user.ts
tests/
  unit/
    services/
      userService.test.ts      # Mirrors src/ structure
    models/
      user.test.ts
  integration/
    user-registration.test.ts
```

**Naming conventions:**
- `*.test.ts` or `*.spec.ts` - pick one, use consistently
- Match source file name: `userService.ts` → `userService.test.ts`
- Use descriptive integration test names: `checkout-flow.test.ts`

Reference: [Jest Configuration - testMatch](https://jestjs.io/docs/configuration#testmatch-arraystring)
