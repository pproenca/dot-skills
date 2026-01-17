---
title: Use Built-in 3D Transform Utilities
impact: LOW-MEDIUM
impactDescription: enables 3D effects without custom CSS
tags: anim, 3d, transforms, perspective, rotate
---

## Use Built-in 3D Transform Utilities

Tailwind CSS v4 includes native 3D transform utilities. Use them instead of arbitrary values for perspective, 3D rotations, and transform styles.

**Incorrect (arbitrary 3D values):**

```html
<div class="[perspective:1000px]">
  <div class="[transform-style:preserve-3d] [rotate-x:45deg] [rotate-z:30deg]">
    <!-- Arbitrary syntax for 3D transforms -->
  </div>
</div>
```

**Correct (native 3D utilities):**

```html
<div class="perspective-distant">
  <article class="transform-3d rotate-x-45 rotate-z-30">
    <!-- Native 3D transform utilities -->
  </article>
</div>
```

**Available 3D utilities:**

```html
<!-- Perspective on container -->
<div class="perspective-dramatic">  <!-- 100px -->
<div class="perspective-near">      <!-- 300px -->
<div class="perspective-normal">    <!-- 500px -->
<div class="perspective-midrange">  <!-- 800px -->
<div class="perspective-distant">   <!-- 1200px -->

<!-- 3D transform style -->
<div class="transform-3d">          <!-- preserve-3d -->
<div class="transform-flat">        <!-- flat -->

<!-- 3D rotations -->
<div class="rotate-x-45">           <!-- rotateX(45deg) -->
<div class="rotate-y-90">           <!-- rotateY(90deg) -->
<div class="rotate-z-180">          <!-- rotateZ(180deg) -->

<!-- Backface visibility -->
<div class="backface-visible">
<div class="backface-hidden">
```

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
