---
title: Use Lowercase with Dashes or Underscores for Files
impact: MEDIUM
impactDescription: prevents import resolution failures across platforms
tags: naming, files, lowercase, cross-platform
---

## Use Lowercase with Dashes or Underscores for Files

File names must be all lowercase with only dashes or underscores as separators. No other punctuation, no spaces, no uppercase letters. This ensures cross-platform compatibility.

**Incorrect (case-sensitive or invalid characters):**

```text
UserService.js        // Uppercase letters
order-processor.JS    // Uppercase extension
user profile.js       // Space in name
order_$helper.js      // Special character
My-Component.jsx      // Uppercase letters
```

**Correct (lowercase with dashes or underscores):**

```text
user-service.js       // Dashes
order_processor.js    // Underscores
user-profile.js       // Dashes
order-helper.js       // Dashes
my-component.jsx      // Dashes
```

**Consistency rule:** Choose either dashes or underscores and use consistently throughout the project.

**Why this matters:**
- Case-insensitive filesystems (Windows, macOS default) cause silent failures
- Git may not detect case-only renames
- Import paths become unpredictable across platforms

Reference: [Google JavaScript Style Guide - File name](https://google.github.io/styleguide/jsguide.html#file-name)
