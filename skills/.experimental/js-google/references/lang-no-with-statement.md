---
title: Never Use the with Statement
impact: CRITICAL
impactDescription: prevents scope ambiguity and strict mode errors
tags: lang, with, scope, strict-mode
---

## Never Use the with Statement

The `with` statement makes code ambiguous by creating unclear variable bindings. It's banned in strict mode and should never be used.

**Incorrect (with creates ambiguous scope):**

```javascript
function updateUserSettings(user, newSettings) {
  with (user.settings) {
    // Is 'theme' from user.settings or outer scope?
    theme = newSettings.theme;
    // Is 'language' being set on user.settings or global?
    language = newSettings.language;
    notifications = newSettings.notifications;
  }
}
```

**Correct (explicit property access):**

```javascript
function updateUserSettings(user, newSettings) {
  user.settings.theme = newSettings.theme;
  user.settings.language = newSettings.language;
  user.settings.notifications = newSettings.notifications;
}
```

**Alternative (destructuring for reading):**

```javascript
function displayUserSettings(user) {
  const { theme, language, notifications } = user.settings;
  console.log(`Theme: ${theme}, Language: ${language}`);
  return { theme, language, notifications };
}
```

**Note:** The `with` statement is a syntax error in strict mode (`'use strict'`) and ES modules.

Reference: [Google JavaScript Style Guide - Disallowed features](https://google.github.io/styleguide/jsguide.html#disallowed-features-with)
