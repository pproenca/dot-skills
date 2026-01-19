---
title: Use Input/Expected Fixture Pairs
impact: MEDIUM
impactDescription: enables repeatable, automated validation
tags: test, fixtures, input, expected, snapshot
---

## Use Input/Expected Fixture Pairs

Organize tests as paired input/expected files. The test runner compares actual output against expected files for automated validation.

**Incorrect (ad-hoc testing):**

```typescript
// Manual testing in console
const result = transform(parse("tsx", "const x = 1"));
console.log(result);  // "Looks right..."
// No persistent record, not reproducible
```

**Correct (fixture-based testing):**

```text
tests/
├── basic-transform/
│   ├── input.tsx
│   └── expected.tsx
├── handles-async/
│   ├── input.tsx
│   └── expected.tsx
├── preserves-comments/
│   ├── input.tsx
│   └── expected.tsx
└── no-op-when-already-migrated/
    ├── input.tsx
    └── expected.tsx
```

```typescript
// tests/basic-transform/input.tsx
const user = await fetchUser();
const posts = await fetchPosts();
```

```typescript
// tests/basic-transform/expected.tsx
const [user, posts] = await Promise.all([
  fetchUser(),
  fetchPosts()
]);
```

**Run tests:**

```bash
npx codemod jssg test ./transform.ts --language tsx

# Output:
# ✓ basic-transform
# ✓ handles-async
# ✓ preserves-comments
# ✓ no-op-when-already-migrated
# 4 tests passed
```

**Test naming conventions:**
- Describe the scenario: `handles-nested-callbacks`
- Describe expected behavior: `converts-require-to-import`
- Describe edge cases: `preserves-dynamic-imports`

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)
