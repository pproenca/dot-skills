---
title: Avoid Blaming the Tool Too Quickly
impact: MEDIUM
impactDescription: 95%+ of bugs are in your code, not libraries; premature blame wastes time
tags: anti, blame, libraries, framework, assumptions
---

## Avoid Blaming the Tool Too Quickly

When debugging, assume the bug is in your code, not in the framework, library, or language. While tools do have bugs, they're far less common than bugs in application code. Blaming the tool prematurely stops productive investigation.

**Incorrect (blaming the tool):**

```javascript
// Bug: Data not saving correctly
// Developer's conclusion: "React useState must be broken"

const [user, setUser] = useState(null);

const updateUser = (newData) => {
  setUser(newData);
  console.log(user);  // Still shows old value!
  // "useState is broken, it's not updating!"
  // Files bug report against React
  // Spends hours searching for React bugs
};

// Actual issue: React state updates are asynchronous
// Developer didn't understand the tool, not a tool bug
```

**Correct (assume it's your code):**

```javascript
// Bug: Data not saving correctly
// Hypothesis: My usage of useState is incorrect

const [user, setUser] = useState(null);

const updateUser = (newData) => {
  setUser(newData);
  console.log(user);  // Shows old value

  // Question: Is this expected behavior?
  // Check React documentation on useState...
  // Found: "setState doesn't immediately mutate state"

  // Understanding: useState is working correctly
  // My expectation was wrong

  // Fix: Use callback for immediate value, or useEffect for side effects
  setUser(newData);
  console.log(newData);  // Use newData directly

  // Or:
  useEffect(() => {
    if (user) {
      console.log('User updated:', user);
    }
  }, [user]);
};
```

**Before blaming the tool, verify:**
1. Did you read the documentation?
2. Does a minimal example reproduce the issue?
3. Can you find others with the same "bug"?
4. Is your version up to date?
5. Are you using the API correctly?
6. Have you isolated the issue from your application code?

**When tool bugs are actually likely:**
- Minimal reproduction in isolation still fails
- Issue documented in tool's bug tracker
- Using edge case or new/deprecated feature
- Multiple independent developers report same issue
- Worked before tool version update

**When NOT to use this pattern:**
- You've verified correct usage through documentation
- Minimal reproduction clearly shows tool issue
- Tool's bug tracker confirms the issue

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
