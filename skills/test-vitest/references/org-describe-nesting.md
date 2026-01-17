---
title: Use Describe Blocks for Logical Grouping
impact: LOW
impactDescription: Improves test output readability and enables scoped setup/teardown
tags: org, describe, nesting, grouping, test-structure
---

## Use Describe Blocks for Logical Grouping

Flat test files with many `it()` blocks are hard to scan. Use `describe()` blocks to group related tests, enabling scoped setup and clearer failure messages.

**Incorrect (flat structure):**

```typescript
import { describe, it, expect } from 'vitest'

it('should create user with valid data', () => {})
it('should fail to create user with invalid email', () => {})
it('should fail to create user with short password', () => {})
it('should update user name', () => {})
it('should update user email', () => {})
it('should fail to update with invalid email', () => {})
it('should delete user', () => {})
it('should fail to delete non-existent user', () => {})
// Hard to see the structure
```

**Correct (logical grouping):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'

describe('UserService', () => {
  describe('create', () => {
    it('should create user with valid data', () => {})

    describe('validation', () => {
      it('should reject invalid email', () => {})
      it('should reject short password', () => {})
    })
  })

  describe('update', () => {
    beforeEach(() => {
      // Setup specific to update tests
    })

    it('should update user name', () => {})
    it('should update user email', () => {})
    it('should reject invalid email', () => {})
  })

  describe('delete', () => {
    it('should delete existing user', () => {})
    it('should throw for non-existent user', () => {})
  })
})
```

**Test output comparison:**

```
# Flat structure output
✓ should create user with valid data
✓ should fail to create user with invalid email
✗ should fail to create user with short password
# Which feature is failing?

# Grouped structure output
✓ UserService > create > should create user with valid data
✓ UserService > create > validation > should reject invalid email
✗ UserService > create > validation > should reject short password
# Clear: create validation is failing
```

**Nesting limits:**
- Keep nesting to 2-3 levels max
- If deeper, consider splitting into separate files

**Benefits:**
- Clearer test output
- Scoped beforeEach/afterEach
- Easy to run subsets (`vitest UserService.create`)

Reference: [Vitest describe](https://vitest.dev/api/#describe)
