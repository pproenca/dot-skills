---
title: Prefer Inline Snapshots for Small Values
impact: MEDIUM
impactDescription: Improves test readability by showing expected output directly in test code
tags: snap, inline-snapshot, toMatchInlineSnapshot, readability
---

## Prefer Inline Snapshots for Small Values

File-based snapshots require jumping between test files and `.snap` files. For small values (under 10-15 lines), inline snapshots keep expected output visible in the test, making reviews and debugging faster.

**Less readable (file snapshot):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserSerializer', () => {
  it('should serialize user', () => {
    const user = { id: 1, name: 'Alice', role: 'admin' }
    // Have to open __snapshots__/user.test.ts.snap to see expected value
    expect(serialize(user)).toMatchSnapshot()
  })
})
```

**More readable (inline snapshot):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserSerializer', () => {
  it('should serialize user', () => {
    const user = { id: 1, name: 'Alice', role: 'admin' }
    // Expected value visible directly in test
    expect(serialize(user)).toMatchInlineSnapshot(`
      {
        "id": 1,
        "name": "Alice",
        "role": "admin"
      }
    `)
  })
})
```

**When to use file snapshots:**
- Large objects (>15 lines)
- Binary data or complex structures
- HTML/JSX components with many elements
- Generated code or documentation

**When to use inline snapshots:**
- Small objects and primitives
- Error messages
- Simple serialized data
- API response shapes

**Updating inline snapshots:**

```bash
# Update all snapshots
vitest -u

# Interactive update in watch mode
# Press 'u' when prompted
```

**Benefits:**
- Test is self-documenting
- Changes visible in code review diffs
- No context switching to .snap files

Reference: [Vitest Inline Snapshots](https://vitest.dev/guide/snapshot#inline-snapshots)
