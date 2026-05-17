---
title: Snapshot Per Component, Not Per Page
impact: HIGH
impactDescription: localizes regression scope by 10-50x; enables parallel re-baselining
tags: diff, baseline-granularity, storybook, scope
---

## Snapshot Per Component, Not Per Page

A full-page snapshot lights up red whenever *any* of its 80 components changes, telling you nothing about which one regressed. Snapshot at component granularity — one baseline image per component variant — so a failure points directly at the responsible code, and accepting a deliberate change updates exactly one baseline, not all 80. Storybook + a snapshot runner (Chromatic, Loki, Playwright with story navigation) is the standard tool for this.

**Incorrect (page-level snapshots):**

```ts
// One snapshot per route in the app.
await page.goto('/profile');
await expect(page).toHaveScreenshot('profile.png');
// Day 1 — designer tweaks the avatar border radius globally.
// All 12 page snapshots fail. You can't tell which other changes also slipped through.
// Re-baseline blindly accepts all 12 diffs.
```

**Correct (component-level snapshots via Storybook):**

```ts
// stories/Avatar.stories.tsx
export default { component: Avatar };
export const Default       = { args: { size: 64, src: '/a.jpg' } };
export const WithBadge     = { args: { size: 64, src: '/a.jpg', badge: true } };
export const Small         = { args: { size: 32, src: '/a.jpg' } };

// tests/snapshot.ts
import { test, expect } from '@playwright/test';
import { stories } from '../storybook-stories-list.json';

for (const story of stories) {
  test(story.id, async ({ page }) => {
    await page.goto(`/iframe.html?id=${story.id}`);
    await expect(page.locator('#storybook-root')).toHaveScreenshot(`${story.id}.png`);
  });
}

// Day 1 — avatar border radius change.
// 3 snapshots fail (Avatar.Default, Avatar.WithBadge, Avatar.Small).
// All from the same component. Accept those 3, ship the change. Other 200
// snapshots pass — confirming nothing else regressed.
```

**Re-baselining policy:**

| Snapshot scope | Re-baseline burden | Regression hiding risk |
|---|---|---|
| Per page | Accept N diffs blindly (or audit N pages) | High — page contains many components |
| Per component | Accept K diffs where K = components actually changed | Low — diff scope = blast radius |
| Per variant | Accept K' diffs where K' = variants actually changed | Lowest — distinguishes state-conditional bugs |

**Why per-component beats per-page even in scale:** modern snapshot runners parallelize per-snapshot across workers. 200 component snapshots in parallel can be faster than 12 sequential page snapshots, and the diff report is actionable instead of "12 things changed somewhere."

**Variant coverage matters:** capture each component in every state that changes its rendering — default/hover/pressed for buttons, empty/loading/error for data components, each theme for themed components. A bug that only appears in pressed-state is invisible to a default-only snapshot.

Reference: [Storybook — Visual Tests](https://storybook.js.org/docs/writing-tests/visual-testing)
