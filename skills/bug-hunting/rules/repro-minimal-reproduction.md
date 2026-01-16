---
title: Create Minimal Reproduction Cases
impact: CRITICAL
impactDescription: reduces noise, exposes root cause
tags: repro, minimal, reduction, isolation
---

## Create Minimal Reproduction Cases

Strip away everything that isn't necessary to reproduce the bug. A minimal reproduction case removes distracting code and exposes the essential conditions that trigger the failure.

**Incorrect (full application context obscures the bug):**

```typescript
// Bug: User profile not updating
// "It happens somewhere in the app"

class UserProfilePage extends React.Component {
  // 500 lines of component code
  // Multiple API calls
  // Complex state management
  // Redux integration
  // Form validation
  // The bug is hidden somewhere in here...
}
```

**Correct (minimal reproduction isolates the issue):**

```typescript
// Minimal reproduction: The bug is in the API call

async function updateProfile(userId: string, data: ProfileData) {
  const response = await fetch(`/api/users/${userId}`, {
    method: 'PUT',
    body: JSON.stringify(data),  // Bug: Missing Content-Type header
  })
  return response.json()
}

// Reproduce with:
// updateProfile("123", { name: "Alice" })
// Result: 400 Bad Request - server expects JSON content type
```

**Process for creating minimal reproductions:**
1. Start with the failing code
2. Remove code until the bug disappears
3. Add back the last removed code—that's the trigger
4. Repeat until nothing else can be removed

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)
