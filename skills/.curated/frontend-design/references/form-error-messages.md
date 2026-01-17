---
title: Write Actionable Error Messages
impact: MEDIUM
impactDescription: reduces user confusion and support requests by 30%
tags: form, errors, messages, ux, validation
---

## Write Actionable Error Messages

Generic error messages like "Invalid input" don't help users fix problems. Effective error messages explain what's wrong and how to fix it.

**Incorrect (vague, unhelpful error messages):**

```html
<div class="error">Invalid input</div>
<div class="error">Error</div>
<div class="error">Please enter a valid value</div>
<div class="error">This field is required</div>
<!-- User doesn't know what's wrong or how to fix it -->
```

**Correct (specific, actionable error messages):**

```html
<!-- Explain format requirements -->
<div class="error">
  Enter your email address (example: name@company.com)
</div>

<!-- Explain constraints -->
<div class="error">
  Password must be at least 8 characters with one number
</div>

<!-- Explain what happened -->
<div class="error">
  This email is already registered. <a href="/login">Log in</a> or use a different email.
</div>

<!-- Explain required context -->
<div class="error">
  Enter your phone number so we can send delivery updates
</div>
```

**Error message guidelines:**
- State what's wrong specifically
- Explain how to fix it
- Use positive language ("Enter..." not "You must...")
- Keep it brief but complete
- Position error adjacent to the field
- Use appropriate tone (helpful, not blaming)

**Error message anatomy:**
```text
[What's wrong] + [How to fix it]
"Password too short" + "Use at least 8 characters"
= "Password must be at least 8 characters"
```

Reference: [NNGroup Error Message Guidelines](https://www.nngroup.com/articles/errors-forms-design-guidelines/)
