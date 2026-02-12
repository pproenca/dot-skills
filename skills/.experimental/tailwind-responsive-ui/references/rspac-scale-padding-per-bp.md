---
title: Scale Padding Independently Per Breakpoint
impact: HIGH
impactDescription: prevents cramped mobile and overly sparse desktop layouts
tags: rspac, padding, spacing, breakpoints, independent-scaling
---

## Scale Padding Independently Per Breakpoint

Don't scale everything proportionally -- design each size independently (Refactoring UI). Padding that provides comfortable breathing room at 1440px (`p-12` = 48px) consumes over 25% of horizontal space on a 375px mobile screen. Each breakpoint has different content density needs, so padding values should be authored separately rather than using a single value everywhere.

**Incorrect (fixed padding at all screen sizes):**

```html
<!-- p-12 = 48px on every side — eats 96px of a 375px mobile screen, leaving only 279px for content -->
<div class="mx-auto max-w-5xl p-12">
  <div class="rounded-xl border border-gray-200 bg-white p-12 shadow-sm">
    <h2 class="text-2xl font-semibold text-gray-900">Account Settings</h2>
    <p class="mt-2 text-gray-600">Manage your profile, billing, and notification preferences.</p>
    <div class="mt-6 grid grid-cols-2 gap-6">
      <div class="rounded-lg border border-gray-100 bg-gray-50 p-12">
        <h3 class="font-medium text-gray-900">Profile</h3>
        <p class="mt-1 text-sm text-gray-500">Update your name and avatar</p>
      </div>
      <div class="rounded-lg border border-gray-100 bg-gray-50 p-12">
        <h3 class="font-medium text-gray-900">Billing</h3>
        <p class="mt-1 text-sm text-gray-500">Manage payment methods</p>
      </div>
    </div>
  </div>
</div>
```

**Correct (padding scales independently per breakpoint):**

```html
<!-- p-4 (16px) on mobile, p-8 (32px) on tablet, p-12 (48px) on desktop — each feels balanced -->
<div class="mx-auto max-w-5xl p-4 md:p-8 lg:p-12">
  <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm md:p-8 lg:p-12">
    <h2 class="text-2xl font-semibold text-gray-900">Account Settings</h2>
    <p class="mt-2 text-gray-600">Manage your profile, billing, and notification preferences.</p>
    <div class="mt-4 grid grid-cols-1 gap-4 md:mt-6 md:grid-cols-2 md:gap-6">
      <div class="rounded-lg border border-gray-100 bg-gray-50 p-4 md:p-6 lg:p-8">
        <h3 class="font-medium text-gray-900">Profile</h3>
        <p class="mt-1 text-sm text-gray-500">Update your name and avatar</p>
      </div>
      <div class="rounded-lg border border-gray-100 bg-gray-50 p-4 md:p-6 lg:p-8">
        <h3 class="font-medium text-gray-900">Billing</h3>
        <p class="mt-1 text-sm text-gray-500">Manage payment methods</p>
      </div>
    </div>
  </div>
</div>
```
