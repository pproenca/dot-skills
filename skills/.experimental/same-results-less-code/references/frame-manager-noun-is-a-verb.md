---
title: Rename Manager/Helper/Util Classes Until the Real Verb Appears
impact: CRITICAL
impactDescription: reduces grab-bag "Manager" classes to focused functions in their real modules
tags: frame, naming, classes, verbs
---

## Rename Manager/Helper/Util Classes Until the Real Verb Appears

`UserManager`, `OrderHelper`, `StringUtils`, `DataProcessor` — these names exist because the engineer couldn't find a coherent concept and reached for a noun-shaped bag. A manager class is usually a *grab-bag of unrelated verbs* glued together by accident of subject. The fix isn't to rename it; it's to ask, for each method: "what does this actually do?" Each verb usually points to a different real concept — a domain function, a different module, or a method on the data itself.

**Incorrect (one class as a dumping ground for "things involving users"):**

```typescript
class UserManager {
  // Authentication
  async login(email: string, password: string): Promise<Session> { /* ... */ }
  async logout(sessionId: string): Promise<void> { /* ... */ }

  // CRUD
  async createUser(input: CreateUserInput): Promise<User> { /* ... */ }
  async updateUser(id: string, input: UpdateInput): Promise<User> { /* ... */ }

  // Notifications
  async sendWelcomeEmail(user: User): Promise<void> { /* ... */ }
  async sendPasswordReset(user: User): Promise<void> { /* ... */ }

  // Permissions
  canAccess(user: User, resource: Resource): boolean { /* ... */ }

  // Formatting
  displayName(user: User): string { /* ... */ }
}
// 8 methods, 4 unrelated concerns. Every test instantiates the whole thing.
// Every change to one concern reads as a change to "the user manager."
```

**Correct (each verb finds its real home):**

```typescript
// auth/session.ts
export async function login(email: string, password: string): Promise<Session> { /* ... */ }
export async function logout(sessionId: string): Promise<void> { /* ... */ }

// users/repository.ts
export async function createUser(input: CreateUserInput): Promise<User> { /* ... */ }
export async function updateUser(id: string, input: UpdateInput): Promise<User> { /* ... */ }

// notifications/email.ts
export async function sendWelcomeEmail(user: User): Promise<void> { /* ... */ }
export async function sendPasswordReset(user: User): Promise<void> { /* ... */ }

// authorization/policy.ts
export function canAccess(user: User, resource: Resource): boolean { /* ... */ }

// users/model.ts  (or a getter on the User type)
export const displayName = (user: User): string => /* ... */;
```

**The renaming exercise:**

For each method on a Manager/Helper/Util class, ask:
1. **What does this verb actually do?** (`sendWelcomeEmail` — sends an email)
2. **What is its real subject?** (Not "the user" — the *email system*)
3. **Would a stranger looking for this code know to look on the Manager?** (Usually not — they'd search for the verb.)

If three methods on `UserManager` have three different real subjects, the class is hiding the real architecture. Splitting it makes the boundaries visible — and usually shrinks total code volume because the over-broad class had shared private helpers it didn't need.

**When NOT to use this pattern:**

- A `Manager`/`Coordinator` that genuinely *coordinates* across concerns and holds the orchestration state (e.g. a saga, a transaction coordinator). That's a real role. Keep it, but be honest about it.

Reference: [Clean Code — Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) (the "noise word" critique applies directly to Manager/Helper/Data/Info/Util)
