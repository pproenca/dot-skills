---
title: Declare Ambient Modules for Non-TypeScript Asset Imports
impact: MEDIUM
impactDescription: enables typed `import` of SVGs, CSS modules, images, and binary assets without per-file casts
tags: decl, ambient-modules, assets, bundler, vite, webpack
---

## Declare Ambient Modules for Non-TypeScript Asset Imports

Bundlers (Vite, webpack, Rspack) let you `import logo from './logo.svg'` or `import styles from './card.module.css'` and resolve the path at build time. TypeScript by default rejects these — it doesn't know what type to assign to the import. **Ambient module declarations** (`declare module '*.svg'`) tell the compiler the *type* of values these imports produce, without telling it anything about the file contents themselves. The result is type-safe imports of assets across the entire project from one declaration file.

**Incorrect (rely on bundler globals or per-file casts):**

```typescript
// @ts-expect-error TS doesn't know about .svg imports
import logo from './logo.svg'

// or worse:
const logo = require('./logo.svg') as string  // breaks `verbatimModuleSyntax`

// or worst:
const logo: any = (await import('./logo.svg' as any)).default
```

**Correct (one ambient declaration per asset kind):**

```typescript
// src/types/assets.d.ts — ambient declarations for all asset kinds the project imports

declare module '*.svg' {
  // Vite default: SVG imported as URL string. (For React components, use the ?react query.)
  const url: string
  export default url
}

declare module '*.svg?react' {
  // Vite + vite-plugin-svgr: SVG imported as a React component.
  import type { FunctionComponent, SVGProps } from 'react'
  const Component: FunctionComponent<SVGProps<SVGSVGElement>>
  export default Component
}

declare module '*.module.css' {
  const classes: Readonly<Record<string, string>>
  export default classes
}

declare module '*.png' {
  const url: string
  export default url
}

declare module '*.wasm' {
  const init: (imports?: WebAssembly.Imports) => Promise<WebAssembly.Instance>
  export default init
}
```

Now anywhere in the project:

```typescript
import logo      from './assets/logo.svg'         // logo: string (URL)
import LogoIcon  from './assets/logo.svg?react'    // LogoIcon: React component
import styles    from './card.module.css'         // styles: Readonly<Record<string, string>>

styles.title    // string
styles.titlee   // string — class names are not type-checked beyond being a string record
```

**Stricter typing for CSS modules** — if you use a typegen step (`typed-css-modules`, `vite-plugin-css-modules-types`), it emits one `.d.ts` per CSS file with the *actual* class names, and `styles.titlee` becomes a type error. The ambient declaration above is the fallback when typegen isn't wired up.

**When NOT to apply:**
- Single-file `import` of an asset — a per-file `.d.ts` next to it (`./logo.svg.d.ts`) is more precise than a global wildcard.
- Bundlers that already ship type definitions for asset imports (some Next.js setups, Bun) — check `tsconfig.json`'s `types` array and don't duplicate.

**Scope delta:**
- No existing TypeScript skill in this repo covers ambient asset modules. Most projects hit this exactly once, copy a fragment from a tutorial, and never revisit. Getting the React-component vs URL-string distinction right (and the `?query` syntax for Vite) is the one detail that saves an afternoon of confusion.

Reference: [TypeScript Handbook — Modules: Wildcard Module Declarations](https://www.typescriptlang.org/docs/handbook/modules/reference.html#wildcards)
