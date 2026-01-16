---
title: Capture Full Environmental Context
impact: CRITICAL
impactDescription: prevents environment-specific bugs from escaping
tags: repro, environment, context, configuration
---

## Capture Full Environmental Context

Bugs often depend on environmental factors invisible in the code. Capture OS version, browser, locale, timezone, feature flags, database state, and configuration to ensure reproducibility across environments.

**Incorrect (missing environmental context):**

```javascript
// Bug report: "Date parsing broken"
// Developer: "Works on my machine"

function parseUserDate(input) {
  return new Date(input).toLocaleDateString()
}

// Test passes in development
console.log(parseUserDate("2024-01-15"))  // "1/15/2024"
```

**Correct (captures full environment):**

```javascript
// Bug report with environment context:
// OS: Windows 11, Locale: de-DE, Timezone: Europe/Berlin
// Input: "2024-01-15" → Output: "Invalid Date"

function parseUserDate(input) {
  return new Date(input).toLocaleDateString()
}

// Reproduction requires matching environment:
// - Set system locale to de-DE
// - German locale expects "15.01.2024" format
// Root cause: Date constructor interprets format based on locale
```

**Environment checklist:**
- OS and version
- Browser/runtime and version
- Locale and timezone settings
- Feature flags and A/B test groups
- Database state and test data
- Network conditions (latency, offline)
- User permissions and roles

Reference: [BrowserStack - Root Causes for Software Defects](https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions)
