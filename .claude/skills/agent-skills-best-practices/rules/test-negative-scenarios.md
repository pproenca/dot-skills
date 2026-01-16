---
title: Test That Skills Do NOT Trigger on Unrelated Requests
impact: MEDIUM
impactDescription: prevents false positive activations
tags: test, negative-testing, activation, precision
---

## Test That Skills Do NOT Trigger on Unrelated Requests

Verify your skill does NOT activate for superficially similar but actually unrelated requests. Over-triggering skills frustrate users and waste context on irrelevant instructions.

**Incorrect (no negative testing):**

```yaml
---
name: python-debugger
description: Helps debug Python code and fix errors.
---
```

```text
# Positive tests pass - activates on Python errors
# No negative testing done
# User asks "what Python version do I have?" - debugger activates
# User asks "recommend Python books" - debugger activates
# User asks "Python vs JavaScript?" - debugger activates
# Skill over-triggers on any Python mention
```

**Correct (negative scenarios tested):**

```markdown
# Negative Test Results

## Should NOT Trigger

1. "what Python version do I have?"
   - Result: Triggered ✗
   - Fix: Added "errors", "bugs", "exceptions" as required context

2. "recommend Python books"
   - Result: Did not trigger ✓

3. "Python vs JavaScript comparison"
   - Result: Did not trigger ✓

4. "write a Python function to sort a list"
   - Result: Triggered ✗
   - Fix: Added "This skill does NOT write new code"

5. "explain how Python decorators work"
   - Result: Did not trigger ✓

## Updated Description
description: Debugs Python errors, traces exceptions, and fixes bugs in Python code. This skill should be used when encountering Python errors, tracebacks, or exceptions. This skill does NOT write new Python code or explain Python concepts.
```

**Negative test categories:**
| If skill does... | Test that it doesn't trigger on... |
|------------------|-----------------------------------|
| Debug errors | General questions about language |
| Generate code | Explanation requests |
| Process files | File organization questions |
| API calls | API documentation questions |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
