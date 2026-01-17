---
title: Create Minimal Reproduction Cases
impact: CRITICAL
impactDescription: Reduces debugging scope by 80-95%, making root cause obvious in many cases
tags: prob, reproduction, simplification, isolation
---

## Create Minimal Reproduction Cases

Reduce the failing case to the smallest possible example that still exhibits the bug. Minimal reproductions eliminate noise, reveal the essential trigger, and often make the root cause immediately obvious.

**Incorrect (debugging in full application context):**

```javascript
// Bug: "User profile doesn't update after edit"
// Debugging in the full app with 200+ components...

// App.jsx (2000 lines)
// ProfilePage.jsx (500 lines)
// ProfileForm.jsx (300 lines)
// useProfile.js (150 lines)
// api/profile.js (100 lines)
// store/userSlice.js (200 lines)

// Developer spends 3 hours stepping through all layers
// Still unclear if issue is in form, API, or state management
```

**Correct (create minimal reproduction):**

```javascript
// Isolate the suspected component chain
// minimal-repro.jsx - 30 lines total

import { useState } from 'react';

function MinimalRepro() {
  const [profile, setProfile] = useState({ name: 'Alice' });

  const updateProfile = async (newName) => {
    // Simulate API call
    const response = await fetch('/api/profile', {
      method: 'PUT',
      body: JSON.stringify({ name: newName })
    });
    const data = await response.json();
    console.log('API returned:', data);  // Debug point 1
    setProfile(data);
    console.log('State after set:', profile);  // Debug point 2
    // BUG FOUND: Logging stale state due to closure!
  };

  return <button onClick={() => updateProfile('Bob')}>Update</button>;
}

// 10 minutes to find bug vs 3 hours in full app
```

**Simplification techniques:**
- Remove unrelated features one at a time
- Replace real APIs with hardcoded data
- Use a fresh project/file if possible
- Delete code until bug disappears, then add last deletion back

**When NOT to use this pattern:**
- Bug only occurs with specific data interactions across systems
- Performance issues requiring full load

Reference: [Why Programs Fail - Simplifying Problems](https://www.whyprogramsfail.com/)
