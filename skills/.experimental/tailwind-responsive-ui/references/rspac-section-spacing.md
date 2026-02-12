---
title: Scale Section Dividers with Viewport
impact: MEDIUM
impactDescription: maintains proportional page rhythm
tags: rspac, sections, dividers, vertical-rhythm, proportional
---

## Scale Section Dividers with Viewport

Large section dividers (80px+) overwhelm mobile screens where the total viewport height is only 667-812px. An 80px gap between sections consumes 10-12% of the visible area on a phone -- the equivalent of 200px on a 1440px desktop monitor. Section spacing should maintain proportional rhythm relative to the viewport, not use absolute values that feel balanced only on large screens.

**Incorrect (fixed large section spacing regardless of screen size):**

```html
<!-- py-20 = 80px per side = 160px total between sections — dominates the 667px mobile viewport -->
<main>
  <section class="bg-white py-20">
    <div class="mx-auto max-w-3xl px-4 text-center">
      <h1 class="text-4xl font-extrabold tracking-tight text-gray-900">Ship Faster, Break Less</h1>
      <p class="mt-4 text-xl text-gray-500">Deploy with confidence using automated testing and one-click rollbacks.</p>
      <a href="/signup" class="mt-8 inline-block rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white shadow-sm hover:bg-blue-700">Start Free Trial</a>
    </div>
  </section>
  <section class="bg-gray-50 py-20">
    <div class="mx-auto max-w-5xl px-4">
      <h2 class="text-center text-3xl font-bold text-gray-900">How It Works</h2>
      <div class="mt-12 grid grid-cols-3 gap-8">
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">1</span>
          <h3 class="mt-4 font-semibold">Connect Repo</h3>
          <p class="mt-2 text-sm text-gray-500">Link your GitHub, GitLab, or Bitbucket repository.</p>
        </div>
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">2</span>
          <h3 class="mt-4 font-semibold">Configure Pipeline</h3>
          <p class="mt-2 text-sm text-gray-500">Set up build, test, and deploy stages in minutes.</p>
        </div>
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">3</span>
          <h3 class="mt-4 font-semibold">Deploy</h3>
          <p class="mt-2 text-sm text-gray-500">Push to main and watch your app go live.</p>
        </div>
      </div>
    </div>
  </section>
  <section class="bg-white py-20">
    <div class="mx-auto max-w-3xl px-4 text-center">
      <h2 class="text-3xl font-bold text-gray-900">Ready to Get Started?</h2>
      <p class="mt-4 text-lg text-gray-500">No credit card required. Free for open-source projects.</p>
    </div>
  </section>
</main>
```

**Correct (proportional section spacing that scales per breakpoint):**

```html
<!-- py-10 (40px) → py-16 (64px) → py-20 (80px) — section rhythm stays proportional to the viewport -->
<main>
  <section class="bg-white py-10 md:py-16 lg:py-20">
    <div class="mx-auto max-w-3xl px-4 text-center">
      <h1 class="text-3xl font-extrabold tracking-tight text-gray-900 md:text-4xl">Ship Faster, Break Less</h1>
      <p class="mt-3 text-lg text-gray-500 md:mt-4 md:text-xl">Deploy with confidence using automated testing and one-click rollbacks.</p>
      <a href="/signup" class="mt-6 inline-block rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white shadow-sm hover:bg-blue-700 md:mt-8">Start Free Trial</a>
    </div>
  </section>
  <section class="bg-gray-50 py-10 md:py-16 lg:py-20">
    <div class="mx-auto max-w-5xl px-4">
      <h2 class="text-center text-2xl font-bold text-gray-900 md:text-3xl">How It Works</h2>
      <div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-3 md:mt-12 md:gap-8">
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">1</span>
          <h3 class="mt-3 font-semibold md:mt-4">Connect Repo</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">Link your GitHub, GitLab, or Bitbucket repository.</p>
        </div>
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">2</span>
          <h3 class="mt-3 font-semibold md:mt-4">Configure Pipeline</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">Set up build, test, and deploy stages in minutes.</p>
        </div>
        <div class="text-center">
          <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white">3</span>
          <h3 class="mt-3 font-semibold md:mt-4">Deploy</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">Push to main and watch your app go live.</p>
        </div>
      </div>
    </div>
  </section>
  <section class="bg-white py-10 md:py-16 lg:py-20">
    <div class="mx-auto max-w-3xl px-4 text-center">
      <h2 class="text-2xl font-bold text-gray-900 md:text-3xl">Ready to Get Started?</h2>
      <p class="mt-3 text-lg text-gray-500 md:mt-4">No credit card required. Free for open-source projects.</p>
    </div>
  </section>
</main>
```
