---
title: State Expected vs Actual Behavior
impact: CRITICAL
impactDescription: Provides clear success criteria and prevents fixing the wrong thing
tags: prob, expected, actual, specification, requirements
---

## State Expected vs Actual Behavior

Explicitly define what should happen before investigating why it doesn't. Without clear expected behavior, you may "fix" code to match your assumptions rather than the actual requirements.

**Incorrect (vague problem statement):**

```javascript
// "The sort doesn't work right"

function sortUsers(users) {
  return users.sort((a, b) => a.name - b.name);  // Bug somewhere here?
}

// Developer "fixes" to:
return users.sort((a, b) => a.name.localeCompare(b.name));

// But wait - what was the EXPECTED behavior?
// - Sort by name alphabetically?
// - Sort by name case-insensitive?
// - Sort by last name, then first name?
// - Sort with numbers handled naturally (item2 before item10)?
// The fix might still be wrong!
```

**Correct (explicit expected vs actual):**

```javascript
// Expected behavior (from requirements):
// - Sort users by display name
// - Case-insensitive (Alice = alice)
// - Handle accented characters (Émile after Emily)
// - Null names sort last

// Actual behavior:
// - Sorts incorrectly: ["bob", "Alice", "émile"] → ["Alice", "bob", "émile"]
// - Should be: ["Alice", "bob", "émile"] (case-insensitive)
// - Also: null names cause crash instead of sorting last

// Clear specification for the fix:
function sortUsers(users) {
  return users.sort((a, b) => {
    // Handle nulls: sort last
    if (!a.name) return 1;
    if (!b.name) return -1;
    // Case-insensitive, locale-aware comparison
    return a.name.localeCompare(b.name, undefined, { sensitivity: 'base' });
  });
}

// Can verify fix matches ALL expected behaviors
```

**Template for stating expected vs actual:**
```markdown
**Expected:** [What should happen according to spec/requirements]
**Actual:** [What currently happens - be specific]
**Difference:** [The gap that needs to be fixed]
**Verification:** [How you'll confirm the fix works]
```

**When NOT to use this pattern:**
- Crashes and exceptions (expected = no crash)
- Performance issues (expected = meets performance target)

Reference: [Cornell CS312 - Debugging](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
