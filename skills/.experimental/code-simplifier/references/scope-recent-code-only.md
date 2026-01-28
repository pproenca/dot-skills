---
title: Focus on Recently Modified Code Only
impact: HIGH
impactDescription: Touching old stable code increases risk by 3-5x and adds 40%+ review time for code reviewers unfamiliar with legacy context
tags: scope, focus, recent-changes, risk-reduction
---

## Focus on Recently Modified Code Only

Code simplification should target recently modified code unless explicitly asked otherwise. Old, stable code has survived production testing and carries hidden assumptions. Simplifying it introduces risk without proportional benefit, and reviewers lack fresh context to validate changes.

**Incorrect (simplifying unrelated legacy code):**

```typescript
// Task: Simplify the new getUserProfile function
// PR includes changes to:

// 1. The new function (correct target)
async function getUserProfile(id: string): Promise<Profile> {
  const user = await db.users.findById(id);
  return user ? mapToProfile(user) : null;
}

// 2. Legacy auth module last touched 2 years ago (wrong!)
// "While I was here, I noticed this could be cleaner..."
function validateSession(token: string): boolean {
  // Simplified from 50 lines to 20
  return jwt.verify(token, SECRET) && !isExpired(token);
}

// 3. Old utility last touched 18 months ago (wrong!)
// "This helper was verbose, made it more functional..."
const formatDate = (d: Date) => d.toISOString().split('T')[0];
```

**Correct (focused on recent code only):**

```typescript
// Task: Simplify the new getUserProfile function
// PR only touches getUserProfile (added last week)

// Before
async function getUserProfile(id: string): Promise<Profile> {
  const result = await db.users.findById(id);
  if (result !== null && result !== undefined) {
    const profile = mapToProfile(result);
    return profile;
  } else {
    return null;
  }
}

// After - only this function changes
async function getUserProfile(id: string): Promise<Profile> {
  const user = await db.users.findById(id);
  return user ? mapToProfile(user) : null;
}

// Legacy validateSession: untouched (stable for 2 years)
// Old formatDate utility: untouched (stable for 18 months)
```

### When NOT to Apply

- When explicitly asked to audit or simplify legacy code
- When fixing a bug that requires touching old code
- When old code blocks the current feature and must be modified anyway
- When performing a planned, scoped refactoring sprint

### Benefits

- PRs stay focused and reviewable
- Reviewers have full context on changed code
- Risk is contained to code already under active development
- git blame remains meaningful for historical debugging
