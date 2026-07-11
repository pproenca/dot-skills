---
title: No static-only container classes — export module functions
tags: oo, static, namespacing, modules
---

## No static-only container classes — export module functions

The wrong default is the Java/C# utility class — `class DateUtils { static format(...) {...} }` — using a class as a namespace. ES modules are the namespacing mechanism; the class wrapper adds an unusable constructor, blocks tree-shaking of individual members in most bundlers (the class is one export), and invites the next contributor to add instance state to what was meant as a function bag. The Google TypeScript style guide states it directly — do not create container classes with static methods or properties for the sake of namespacing; export individual constants and functions.

**Evidence of violation:** a class whose members are all `static` (or a class never instantiated, used only via `ClassName.member`). There is no carve-out — a namespace-shaped import (`import * as dateUtils from "./date-utils"`) reproduces the calling convention exactly.

**Incorrect (class as namespace):**

```ts
export class SlugUtils {
  static slugify(title: string): string {
    return title.toLowerCase().replace(/[^a-z0-9]+/g, "-")
  }
  static readonly MAX_LENGTH = 80
}
```

**Correct (module exports; import * for the namespace feel):**

```ts
export const MAX_SLUG_LENGTH = 80

export function slugify(title: string): string {
  return title.toLowerCase().replace(/[^a-z0-9]+/g, "-")
}
```

Reference: [Google TypeScript Style Guide — Container classes](https://google.github.io/styleguide/tsguide.html#container-classes)
