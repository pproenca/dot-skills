---
title: Design for Single Purpose
impact: CRITICAL
impactDescription: required for Chrome Web Store approval
tags: comp, single-purpose, scope, chrome-web-store, guidelines
---

## Design for Single Purpose

Build extensions around one narrowly defined purpose. Chrome Web Store requires extensions to have a single, easily understood function. Multi-purpose extensions face rejection and user confusion.

**Incorrect (multiple unrelated features):**

```typescript
// manifest.json - Bundled unrelated functionality
{
  "name": "Super Browser Tools",
  "description": "Screenshot capture, ad blocker, password manager, and weather widget",
  "permissions": [
    "tabs", "activeTab", "webRequest", "storage",
    "geolocation", "clipboardWrite", "downloads"
  ]
}

// popup.html - Cluttered interface with unrelated tools
<div class="super-tools">
  <section id="screenshots">Screenshot Tools</section>
  <section id="adblock">Ad Blocking Settings</section>
  <section id="passwords">Password Vault</section>
  <section id="weather">Weather Widget</section>
</div>
// Violates single-purpose policy, confuses users
```

**Correct (focused, single-purpose extension):**

```typescript
// manifest.json - Clear, focused functionality
{
  "name": "Quick Screenshot",
  "description": "Capture, annotate, and share screenshots instantly",
  "permissions": [
    "activeTab", "clipboardWrite", "downloads"
  ]
}

// popup.html - All features serve one purpose
<div class="screenshot-tools">
  <button id="capture-visible">Capture Visible Area</button>
  <button id="capture-full">Capture Full Page</button>
  <button id="capture-selection">Select Area</button>
  <div id="annotation-tools"><!-- Drawing, text, shapes --></div>
  <div id="share-options"><!-- Copy, download, upload --></div>
</div>
// Clear purpose: everything relates to screenshots
```

**Identifying your single purpose:**
- Can you describe the extension in one sentence without "and"?
- Do all permissions directly support that sentence?
- Would removing any feature break the core value?

Reference: [Extension Quality Guidelines](https://developer.chrome.com/docs/webstore/program-policies/quality-guidelines/)
