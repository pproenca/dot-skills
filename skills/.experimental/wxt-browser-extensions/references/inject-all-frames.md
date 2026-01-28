---
title: Configure allFrames for Iframe Handling
impact: HIGH
impactDescription: 10-100× script execution on iframe-heavy pages
tags: inject, frames, iframes, all-frames
---

## Configure allFrames for Iframe Handling

By default, content scripts only run in the top frame. Set `allFrames: true` when you need to process content in iframes, but be aware of the performance cost.

**Incorrect (missing iframe content):**

```typescript
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  // Default: allFrames: false
  main() {
    // Only finds elements in top frame
    const videos = document.querySelectorAll('video')
    videos.forEach(addControls)
    // Misses videos embedded in iframes
  }
})
```

**Correct (explicit frame handling):**

```typescript
// When you need to process iframes
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  allFrames: true,
  main() {
    const videos = document.querySelectorAll('video')
    videos.forEach(addControls)
    // Now runs in every frame
  }
})

// When you only want top frame (explicit for clarity)
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  allFrames: false,
  main() {
    // Communicate with iframes via postMessage if needed
    window.addEventListener('message', (event) => {
      if (event.data.type === 'VIDEO_FOUND') {
        handleVideoInIframe(event.source, event.data)
      }
    })
  }
})
```

**Performance note:** With `allFrames: true`, your content script executes once per frame. For pages with many iframes (ads, embeds), this multiplies resource usage.

Reference: [Chrome Content Scripts - Frames](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts#frames)
