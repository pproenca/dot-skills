---
title: Create Quality Web Store Assets
impact: LOW-MEDIUM
impactDescription: 30-50% higher conversion from store listing
tags: brand, web-store, screenshots, promotional, listing
---

## Create Quality Web Store Assets

Prepare high-quality screenshots and promotional images for the Chrome Web Store. Poor listing assets dramatically reduce install conversion rates.

**Incorrect (minimal effort assets):**

```text
Common mistakes:
- Screenshots of empty/default state
- Low resolution or blurry images
- No annotations explaining features
- Generic promotional tile from template
- Screenshots showing errors or loading states
```

**Correct (professional store assets):**

**Required screenshots (1280×800 or 640×400):**

```text
Screenshot best practices:

1. Show the extension in action
   - Populated with realistic data
   - Demonstrating key features
   - On a real-looking webpage

2. Annotate key features
   - Callout boxes pointing to features
   - Brief explanatory text
   - Consistent annotation style

3. Show multiple use cases
   - Screenshot 1: Primary feature
   - Screenshot 2: Secondary feature
   - Screenshot 3: Settings/customization
   - Screenshot 4: Results/output

4. Use high contrast
   - Extension UI should stand out
   - Consider adding subtle shadow/border around extension
```

**Promotional tile guidelines:**

```text
Small tile (440×280):
- Extension icon prominently displayed
- Extension name in clear, readable font
- Brief tagline (5-7 words max)
- Brand colors consistent with icon

Large tile (920×680) - optional but recommended:
- Feature showcase
- Before/after demonstration
- Multiple feature callouts
- Still readable at small display sizes
```

**Screenshot creation script:**

```typescript
// scripts/capture-screenshots.js
// Automate screenshot capture for consistency

async function captureScreenshot(scenario) {
  // Set up extension with demo data
  await chrome.storage.local.set(scenario.demoData)

  // Navigate to appropriate page
  await chrome.tabs.update({ url: scenario.url })

  // Wait for page load
  await new Promise(resolve => setTimeout(resolve, 2000))

  // Open extension UI
  if (scenario.openPopup) {
    // Capture popup
  }

  // Take screenshot
  const screenshot = await chrome.tabs.captureVisibleTab({
    format: 'png',
    quality: 100
  })

  return screenshot
}

const scenarios = [
  {
    name: 'main-feature',
    demoData: { items: sampleItems },
    url: 'https://example.com',
    openPopup: true
  },
  // ... more scenarios
]
```

**Asset checklist:**

| Asset | Size | Required |
|-------|------|----------|
| Icon 128×128 | 128×128 px | Yes |
| Screenshots | 1280×800 or 640×400 | Yes (1-5) |
| Small promo tile | 440×280 px | Recommended |
| Large promo tile | 920×680 px | Optional |
| Marquee | 1400×560 px | Optional |

Reference: [Creating a Great Listing Page](https://developer.chrome.com/docs/webstore/best-listing)
