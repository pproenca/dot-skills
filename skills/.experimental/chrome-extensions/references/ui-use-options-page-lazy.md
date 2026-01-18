---
title: Lazy Load Options Page Sections
impact: MEDIUM
impactDescription: faster initial options page load
tags: ui, options, lazy-loading, tabs, performance
---

## Lazy Load Options Page Sections

Options pages with many settings and complex UI can take time to render. Load only the visible section initially, then lazy load other tabs/sections when accessed.

**Incorrect (all sections rendered upfront):**

```javascript
// options.js - Everything loaded immediately
async function initOptions() {
  const settings = await chrome.storage.sync.get(null);

  // All sections rendered even if user never opens them
  renderGeneralSettings(settings);
  renderAdvancedSettings(settings);
  renderKeyboardShortcuts(settings);
  renderPrivacySettings(settings);
  renderExperimentalFeatures(settings);
  renderDataExport(settings);  // Heavy: generates preview
}
```

**Correct (lazy load on tab switch):**

```javascript
// options.js - Load sections on demand
const loadedSections = new Set();

async function initOptions() {
  setupTabs();
  await loadSection('general');  // Load default tab only
}

function setupTabs() {
  document.querySelectorAll('.tab-button').forEach(button => {
    button.addEventListener('click', async () => {
      const section = button.dataset.section;
      await loadSection(section);
      showSection(section);
    });
  });
}

async function loadSection(sectionId) {
  if (loadedSections.has(sectionId)) return;

  const container = document.getElementById(`section-${sectionId}`);
  container.innerHTML = '<div class="loading">Loading...</div>';

  const settings = await chrome.storage.sync.get(null);

  switch (sectionId) {
    case 'general':
      renderGeneralSettings(container, settings);
      break;
    case 'advanced':
      renderAdvancedSettings(container, settings);
      break;
    case 'export':
      // Lazy import heavy module
      const { renderExport } = await import('./export-section.js');
      renderExport(container, settings);
      break;
  }

  loadedSections.add(sectionId);
}

function showSection(sectionId) {
  document.querySelectorAll('.section').forEach(s => s.hidden = true);
  document.getElementById(`section-${sectionId}`).hidden = false;
}
```

**Benefits:**
- Faster initial page load
- Reduced memory for unused features
- Better user experience for complex options

Reference: [Dynamic Import MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)
