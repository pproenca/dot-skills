---
title: Provide Sensible Default Settings
impact: MEDIUM
impactDescription: extension works immediately without configuration
tags: options, defaults, onboarding, zero-config, ux
---

## Provide Sensible Default Settings

Ship with carefully chosen defaults so the extension works immediately. Users should only visit settings to customize, not to make the extension functional.

**Incorrect (requires configuration to work):**

```typescript
// background.js - Extension broken until configured
chrome.runtime.onInstalled.addListener(() => {
  // No defaults set - extension does nothing
})

// popup.js - Forces user to settings
async function init() {
  const { apiKey, endpoint } = await chrome.storage.sync.get(['apiKey', 'endpoint'])

  if (!apiKey || !endpoint) {
    document.body.innerHTML = `
      <p>Please configure the extension in settings before use.</p>
      <button onclick="chrome.runtime.openOptionsPage()">Open Settings</button>
    `
    return
  }
}
// New user: installs → clicks icon → "go configure" → frustration
```

**Correct (works out of the box):**

```typescript
// background.js - Sensible defaults on install
const DEFAULT_SETTINGS = {
  theme: 'system',           // Follows OS preference
  notifications: true,       // Most users want notifications
  refreshInterval: 15,       // Reasonable balance
  autoSave: true,            // Prevent data loss
  language: 'auto',          // Detect from browser
  fontSize: 'medium',        // Accessible default
  keyboardShortcuts: true,   // Power user friendly
  dataCollection: 'minimal'  // Privacy conscious
}

chrome.runtime.onInstalled.addListener(async () => {
  // Only set defaults for keys that don't exist
  const existing = await chrome.storage.sync.get(Object.keys(DEFAULT_SETTINGS))

  const toSet = {}
  for (const [key, defaultValue] of Object.entries(DEFAULT_SETTINGS)) {
    if (existing[key] === undefined) {
      toSet[key] = defaultValue
    }
  }

  if (Object.keys(toSet).length > 0) {
    await chrome.storage.sync.set(toSet)
  }
})

// Utility for getting settings with fallback to defaults
async function getSetting(key) {
  const { [key]: value } = await chrome.storage.sync.get(key)
  return value ?? DEFAULT_SETTINGS[key]
}
```

**Default selection guidelines:**

| Setting Type | Good Default | Why |
|--------------|--------------|-----|
| Theme | 'system' | Respects user's OS choice |
| Notifications | On (but not aggressive) | Features should be visible |
| Auto-save | On | Prevents data loss |
| Privacy options | Most private | Build trust first |
| Language | Auto-detect | Most convenient |
| Advanced features | Off | Don't overwhelm new users |

**Optional features with smart detection:**

```typescript
// background.js - Smart defaults based on context
async function getSmartDefaults() {
  const defaults = { ...DEFAULT_SETTINGS }

  // Detect user's likely preferences
  const browserLang = navigator.language
  defaults.language = browserLang.startsWith('en') ? 'en' : browserLang

  // Check if user prefers reduced motion
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    defaults.animations = false
  }

  // Check color scheme preference
  if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    defaults.theme = 'dark'
  }

  return defaults
}
```

Reference: [Extension Quality Guidelines](https://developer.chrome.com/docs/webstore/program-policies/quality-guidelines/)
