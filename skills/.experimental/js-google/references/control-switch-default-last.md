---
title: Always Include Default Case in Switch Statements
impact: MEDIUM-HIGH
impactDescription: prevents silent failures on unexpected values
tags: control, switch, default, exhaustiveness
---

## Always Include Default Case in Switch Statements

Every switch statement must have a `default` case as the last case. Document fall-through with a comment. This ensures all cases are handled explicitly.

**Incorrect (missing default, undocumented fall-through):**

```javascript
function getStatusLabel(status) {
  switch (status) {
    case 'pending':
      return 'Waiting...';
    case 'processing':
    case 'validating':  // Fall-through not documented
      return 'In progress';
    case 'complete':
      return 'Done';
    // Missing default - what if status is invalid?
  }
}
```

**Correct (default case, documented fall-through):**

```javascript
function getStatusLabel(status) {
  switch (status) {
    case 'pending':
      return 'Waiting...';
    case 'processing':
      // fall through
    case 'validating':
      return 'In progress';
    case 'complete':
      return 'Done';
    default:
      throw new Error(`Unknown status: ${status}`);
  }
}
```

**Alternative (empty default with comment):**

```javascript
function handleNotification(type) {
  switch (type) {
    case 'email':
      sendEmail();
      break;
    case 'sms':
      sendSms();
      break;
    case 'push':
      sendPush();
      break;
    default:
      // No action needed for unknown types
      break;
  }
}
```

**Note:** Use block statements (`{ }`) inside cases when declaring variables to create proper scope.

Reference: [Google JavaScript Style Guide - Switch statements](https://google.github.io/styleguide/jsguide.html#features-switch-statements)
