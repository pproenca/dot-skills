---
title: Document Empty Catch Blocks
impact: MEDIUM
impactDescription: prevents silent failure masking
tags: control, exceptions, catch, error-handling
---

## Document Empty Catch Blocks

Empty catch blocks must include a comment explaining why the exception is intentionally suppressed. Silently swallowing errors hides bugs.

**Incorrect (empty catch hides errors):**

```javascript
async function loadUserPreferences(userId) {
  try {
    const prefs = await fetchPreferences(userId);
    return prefs;
  } catch (error) {
    // Empty - error silently swallowed
  }
}

function parseConfigSafe(jsonString) {
  try {
    return JSON.parse(jsonString);
  } catch {
    // What failed? Why is it OK to ignore?
  }
  return null;
}
```

**Correct (documented suppression or proper handling):**

```javascript
async function loadUserPreferences(userId) {
  try {
    const prefs = await fetchPreferences(userId);
    return prefs;
  } catch (error) {
    // Preferences are optional; return defaults if unavailable.
    logger.debug(`Preferences not found for user ${userId}, using defaults`);
    return getDefaultPreferences();
  }
}

function parseConfigSafe(jsonString) {
  try {
    return JSON.parse(jsonString);
  } catch (error) {
    // Invalid JSON is expected when config file doesn't exist.
    // Return null to signal caller should use defaults.
    return null;
  }
}
```

**Alternative (rethrow with context):**

```javascript
async function processPayment(orderId, amount) {
  try {
    await chargeCard(orderId, amount);
  } catch (error) {
    // Add context before rethrowing
    throw new Error(`Payment failed for order ${orderId}: ${error.message}`);
  }
}
```

Reference: [Google JavaScript Style Guide - Empty catch blocks](https://google.github.io/styleguide/jsguide.html#features-exceptions)
