---
title: Leave verbatimModuleSyntax disabled in a Start app
tags: tscfg, verbatim-module-syntax, bundling, framework-exception
---

## Leave verbatimModuleSyntax disabled in a Start app

This rule inverts generic TypeScript advice, which is exactly why it earns a place in the gate: the TS docs recommend `verbatimModuleSyntax` for Vite projects, so a model confidently adds it. TanStack Start's own recommended tsconfig warns the opposite — enabling it can result in **server bundles leaking into client bundles**, because Start's compiler relies on import elision to split server code out of client output. Framework guidance overrides the generic flag advice.

**Evidence of violation:** `"verbatimModuleSyntax": true` in the `tsconfig.json` of a TanStack Start app.

```json
{
  "compilerOptions": {
    "strict": true,
    "erasableSyntaxOnly": true,
    "jsx": "react-jsx",
    "moduleResolution": "bundler"
  }
}
```

The Start baseline omits the flag entirely — absence is the correct state, not an oversight to fix.

Reference: [TanStack Start — Build a Project from Scratch](https://tanstack.com/start/latest/docs/framework/react/build-from-scratch)
