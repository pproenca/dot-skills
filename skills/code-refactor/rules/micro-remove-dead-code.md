---
title: Remove Dead Code
impact: LOW
impactDescription: reduces cognitive load and maintenance burden
tags: micro, dead-code, cleanup, unused
---

## Remove Dead Code

Code that is never executed confuses readers and creates maintenance burden. Delete it; version control preserves history if needed.

**Incorrect (dead code left in place):**

```typescript
class UserService {
  // Old method kept "just in case"
  // async getUser_OLD(id: string): Promise<User> {
  //   return this.db.query('SELECT * FROM users WHERE id = ?', [id])
  // }

  async getUser(id: string): Promise<User> {
    return this.userRepository.findById(id)
  }

  // Method that's never called anywhere
  async getUsersByDepartment(deptId: string): Promise<User[]> {
    return this.userRepository.findByDepartment(deptId)
  }

  // Feature flag that's always false in production
  async getUsers(): Promise<User[]> {
    if (process.env.USE_LEGACY_QUERY === 'true') {  // Never true
      return this.legacyGetUsers()
    }
    return this.userRepository.findAll()
  }

  // Dead code from abandoned feature
  private legacyGetUsers(): Promise<User[]> {
    // Old implementation no longer used
    return this.db.query('SELECT * FROM users_legacy')
  }
}
```

**Correct (dead code removed):**

```typescript
class UserService {
  async getUser(id: string): Promise<User> {
    return this.userRepository.findById(id)
  }

  async getUsers(): Promise<User[]> {
    return this.userRepository.findAll()
  }
}

// If getUsersByDepartment is needed later, recreate it from git history
// git log -p --all -S 'getUsersByDepartment' -- '*.ts'
```

**Signs of dead code:**
- Methods with no callers (IDE can detect)
- Commented-out code blocks
- Feature flags that are always false
- Catch blocks that can never execute
- Conditions that are always true/false

**When NOT to delete:**
- API endpoints that external systems might call
- Hooks/callbacks registered with external frameworks
- Code that appears dead but is invoked via reflection

Reference: [Remove Dead Code](https://refactoring.com/catalog/removeDeadCode.html)
