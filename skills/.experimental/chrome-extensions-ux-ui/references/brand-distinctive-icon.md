---
title: Design a Distinctive Toolbar Icon
impact: LOW-MEDIUM
impactDescription: improves findability in crowded toolbar
tags: brand, icon, toolbar, recognition, design
---

## Design a Distinctive Toolbar Icon

Create a unique, recognizable icon that stands out in the browser toolbar. Generic icons blend into the crowd, making your extension hard to find.

**Incorrect (generic, hard to distinguish):**

```text
Common mistakes:
- Generic gear/cog icon (looks like settings)
- Plain letter in a circle (looks like every other extension)
- Stock icon from free icon library (not unique)
- Too much detail at 16px (becomes muddy)
- Monochrome gray (blends with browser chrome)
```

**Correct (distinctive and recognizable):**

```text
Design principles for toolbar icons:

1. Simple, bold silhouette
   - Recognizable at 16×16 pixels
   - Clear shape even when squinting

2. Distinctive color
   - Use your brand color if recognizable
   - Avoid browser chrome colors (gray, black)
   - Consider colorblind-friendly palettes

3. Unique concept
   - Don't use generic symbols (gear, star, heart)
   - Create something ownable to your brand
   - Consider combining two concepts (e.g., magnifying glass + bookmark)

4. Consistent with purpose
   - Icon should hint at functionality
   - Screenshot tool → camera/crop marks
   - Password manager → lock/key
   - Note-taking → pencil/paper
```

**Icon design checklist:**

```typescript
// Programmatic icon state for different states
async function setIconState(state) {
  const iconPaths = {
    active: {
      16: 'icons/active-16.png',
      32: 'icons/active-32.png'
    },
    inactive: {
      16: 'icons/inactive-16.png',
      32: 'icons/inactive-32.png'
    },
    alert: {
      16: 'icons/alert-16.png',
      32: 'icons/alert-32.png'
    }
  }

  await chrome.action.setIcon({ path: iconPaths[state] })
}

// Change icon based on extension state
chrome.storage.onChanged.addListener((changes) => {
  if (changes.enabled) {
    setIconState(changes.enabled.newValue ? 'active' : 'inactive')
  }
})
```

**Testing icon visibility:**

| Test | Pass Criteria |
|------|---------------|
| 16px preview | Shape clearly recognizable |
| Grayscale | Still distinguishable |
| On light/dark toolbar | Visible on both |
| Next to other extensions | Stands out from common icons |
| Color blindness simulation | Remains distinct |

Reference: [Extension Branding](https://developer.chrome.com/docs/webstore/branding)
