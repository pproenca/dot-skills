---
title: Test File Colocation
impact: HIGH
impactDescription: makes tests easy to find and update alongside implementation changes
tags: org, tests, colocation, testing
---

## Test File Colocation

Place test files alongside source files with `.test.tsx` suffix for unit tests and `.spec.tsx` for type/integration tests.

**Incorrect (separate test directory):**

```text
src/
  accordion/
    AccordionRoot.tsx
    AccordionTrigger.tsx
__tests__/
  accordion/
    AccordionRoot.test.tsx
    AccordionTrigger.test.tsx
```

**Correct (co-located tests):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRoot.test.tsx      # Unit tests
    AccordionRoot.spec.ts       # Type tests
    AccordionRootContext.ts
  trigger/
    AccordionTrigger.tsx
    AccordionTrigger.test.tsx
  Accordion.test.tsx            # Integration tests for full component
```

**When to use:**
- `.test.tsx` for component behavior tests
- `.spec.ts` for type definition tests
- Integration tests at component root level
