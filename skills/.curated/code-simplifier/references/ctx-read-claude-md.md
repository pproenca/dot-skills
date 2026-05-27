---
title: Always Read CLAUDE.md Before Simplifying
impact: CRITICAL
impactDescription: Prevents 90% of rejected PRs due to violating undocumented project conventions
tags: ctx, conventions, project-setup
---

## Always Read CLAUDE.md Before Simplifying

Project-specific instructions in CLAUDE.md define how code should be written, tested, and structured. Ignoring these instructions leads to simplifications that violate project standards, causing rework and rejected changes. Reading CLAUDE.md first ensures your simplifications align with the team's established practices.

**Incorrect (simplifying without reading project instructions):**

```typescript
// Developer simplifies by removing "unnecessary" error handling
// Not knowing CLAUDE.md requires explicit error boundaries
function fetchUser(id: string) {
  return api.get(`/users/${id}`);
}
```

**Correct (reading CLAUDE.md first, respecting error handling requirement):**

```typescript
// CLAUDE.md specifies: "All API calls must have explicit error handling"
function fetchUser(id: string) {
  try {
    return api.get(`/users/${id}`);
  } catch (error) {
    throw new UserFetchError(id, error);
  }
}
```

**When NOT to use:**

- When CLAUDE.md does not exist in the project
- For exploratory analysis where no changes will be made

**Benefits:**

- Simplifications are accepted on first review
- Maintains consistency with team expectations
- Avoids introducing patterns the team has explicitly rejected

**References:**

- Check `.claude/CLAUDE.md`, `CLAUDE.md`, and parent directory CLAUDE.md files
- Look for `AGENTS.md` or similar instruction files
