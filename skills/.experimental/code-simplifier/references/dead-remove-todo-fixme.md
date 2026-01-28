---
title: Remove Stale TODO/FIXME Comments
impact: MEDIUM
impactDescription: Stale TODOs accumulate to hundreds per codebase, creating noise that hides real issues and urgent work
tags: dead, comments, todo, fixme, issues, tracking
---

## Remove Stale TODO/FIXME Comments

TODO and FIXME comments are promises that rarely get kept. They accumulate over months and years until codebases have hundreds of stale reminders that everyone ignores. Either convert TODOs to tracked issues with owners and deadlines, or delete them. If something matters, it belongs in your issue tracker.

**Incorrect (accumulated stale TODOs):**

```typescript
export class UserService {
  // TODO: add caching
  // FIXME: this is slow
  // TODO: refactor this whole class (2019-03-15)
  // HACK: temporary fix for login bug
  // XXX: revisit this later

  async getUser(id: string): Promise<User> {
    // TODO: handle the case where user doesn't exist
    // FIXME: should validate id format
    const user = await this.db.query(`SELECT * FROM users WHERE id = ?`, [id]);

    // TODO: add proper error handling
    // TODO: log this somewhere
    // NOTE: Bob said to fix this - not sure what he meant
    return user;
  }

  // TODO(john): finish implementing this
  // TODO: write tests
  async updateUser(id: string, data: Partial<User>): Promise<void> {
    // FIXME: SQL injection vulnerability!!!
    await this.db.query(`UPDATE users SET ${data} WHERE id = ${id}`);
  }
}
```

**Correct (clean code, issues in tracker):**

```typescript
export class UserService {
  async getUser(id: string): Promise<User | null> {
    const user = await this.db.query(`SELECT * FROM users WHERE id = ?`, [id]);
    return user ?? null;
  }

  async updateUser(id: string, data: Partial<User>): Promise<void> {
    // Security: parameterized query prevents SQL injection
    const setClauses = Object.keys(data).map(k => `${k} = ?`).join(', ');
    await this.db.query(
      `UPDATE users SET ${setClauses} WHERE id = ?`,
      [...Object.values(data), id]
    );
  }
}

// Issue tracker entries created:
// - PROJ-1234: Add Redis caching layer to UserService
// - PROJ-1235: Add input validation for user ID format
// - PROJ-1236: Implement proper error handling in data layer
```

**Incorrect (TODOs with no actionable path):**

```python
# TODO: make this better
def process_data(data):
    # FIXME: ugly code
    result = []
    for item in data:
        # TODO: optimize this
        if item.value > 0:
            result.append(item)
    # TODO: think about edge cases
    return result

# TODO: might need to change this someday
MAX_RETRIES = 3

# FIXME: ???
def mystery_function():
    pass
```

**Correct (either fix it or delete the noise):**

```python
def process_data(data):
    return [item for item in data if item.value > 0]

MAX_RETRIES = 3

def mystery_function():
    pass  # Intentionally empty - interface placeholder for plugins
```

**When a TODO is acceptable (temporarily):**

```javascript
// Acceptable: Specific, dated, with ticket reference
// TODO(2024-Q1): Remove after migrating to v2 API (JIRA-5678)
const legacyAdapter = createLegacyAdapter();

// Acceptable: Blocking issue documented
// FIXME: Blocked on upstream PR#123 - using workaround until merged
const result = workaroundFunction();

// Acceptable: Part of active PR/branch
// TODO: Add error handling - will address in next commit
```

### TODO Triage Process

When you find a TODO, decide:
1. **Fix it now** - If it takes < 5 minutes, just do it
2. **Create issue** - If it's real work, track it properly
3. **Delete it** - If it's vague, stale, or no longer relevant

### Signs a TODO is Stale

- Date older than 6 months
- Author no longer on team
- References completed work or old versions
- Vague ("make better", "fix this", "???")
- No one knows why it's there

### Benefits

- Issue tracker becomes single source of truth
- TODO count stays near zero (easy to spot new ones)
- Urgent FIXMEs don't get lost in noise
- Code review can focus on real issues
- New developers don't inherit archaeological debt

### References

- Most IDEs can extract TODOs to tasks: "TODO to Issue" extensions
- CI tools can fail builds on TODO count thresholds
- `grep -r "TODO\|FIXME" --include="*.ts" | wc -l` for auditing
