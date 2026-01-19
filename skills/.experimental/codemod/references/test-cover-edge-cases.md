---
title: Cover Edge Cases in Test Fixtures
impact: MEDIUM
impactDescription: prevents production failures on unusual code
tags: test, edge-cases, coverage, fixtures
---

## Cover Edge Cases in Test Fixtures

Create fixtures for edge cases that production code might contain. Real codebases have unusual patterns that simple examples miss.

**Incorrect (only happy path):**

```text
tests/
└── basic-case/
    ├── input.tsx     # Simple, clean code
    └── expected.tsx
# Misses: comments, formatting, edge cases
```

**Correct (comprehensive edge cases):**

```text
tests/
├── basic-case/
│   ├── input.tsx
│   └── expected.tsx
├── with-inline-comments/
│   ├── input.tsx    # Code with // comments
│   └── expected.tsx
├── with-block-comments/
│   ├── input.tsx    # Code with /* */ comments
│   └── expected.tsx
├── multiline-expression/
│   ├── input.tsx    # Spans multiple lines
│   └── expected.tsx
├── already-transformed/
│   ├── input.tsx    # Should be no-op
│   └── expected.tsx # Same as input
├── mixed-patterns/
│   ├── input.tsx    # Some match, some don't
│   └── expected.tsx
├── empty-file/
│   ├── input.tsx    # Empty content
│   └── expected.tsx
├── syntax-edge-cases/
│   ├── input.tsx    # Optional chaining, nullish coalescing
│   └── expected.tsx
└── typescript-specific/
    ├── input.tsx    # Generics, type assertions
    └── expected.tsx
```

**Edge cases to always test:**
- Empty files
- Files with only comments
- Already-transformed code (idempotency)
- Code with unusual formatting
- TypeScript-specific syntax
- JSX variations
- Dynamic/computed expressions

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)
