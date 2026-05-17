---
title: Map foreignSymbols to Shared Library Imports, Not Duplicates
impact: HIGH
impactDescription: prevents the same external symbol being re-emitted in every consuming file (10-100x duplication)
tags: tree, foreign-symbols, library-imports, modularization
---

## Map foreignSymbols to Shared Library Imports, Not Duplicates

`doc.foreignSymbols` lists symbols imported from an external Sketch library — typically a design-system file shared across products. The naïve converter inlines each foreign symbol into every file that uses it, producing a codebase where the canonical `Button` component is duplicated in 40 places with no shared source. Treat each foreign symbol as an import from an established design-system package (or a sibling generated module), and emit a reference instead of the body.

**Incorrect (inline foreign symbols as if they were local):**

```ts
for (const instance of symbolInstances) {
  const master = doc.foreignSymbols.find(f => f.symbolID === instance.symbolID)
              ?? doc.symbols.find(s => s.symbolID === instance.symbolID);
  await emitInline(master);   // foreign symbols inlined into every consumer
}
```

```tsx
// Result: src/screens/Profile.tsx, Settings.tsx, Onboarding.tsx all contain:
function Button({ label, variant }) { /* 120 lines of generated JSX */ }
// And every design-system update requires 40 file edits.
```

**Correct (foreign symbols become library imports):**

```ts
// Configure once: foreign library prefix → import path.
const FOREIGN_LIBRARY_MAP = {
  'acme-design-system': '@acme/design-system',
  'acme-icons':         '@acme/icons',
};

function resolveForeignImport(foreign: ForeignSymbol): { name: string; from: string } | null {
  // foreign.libraryID points to the source .sketch library;
  // foreign.symbolMaster.name carries the full path e.g. "Controls/Button/Primary".
  const lib = doc.perDocumentLibraries.find(l => l.libraryID === foreign.libraryID);
  const importPath = FOREIGN_LIBRARY_MAP[lib.name];
  if (!importPath) return null;          // unknown library — fall through to inline

  const componentName = pascalCase(foreign.symbolMaster.name.split('/').pop()!);
  return { name: componentName, from: importPath };
}

for (const instance of symbolInstances) {
  const foreign = doc.foreignSymbols.find(f => f.symbolID === instance.symbolID);
  if (foreign) {
    const imp = resolveForeignImport(foreign);
    if (imp) {
      addImport(imp.name, imp.from);                                   // import { Button } from '@acme/design-system'
      emit(`<${imp.name} ${propsToAttrs(resolveOverrides(instance))} />`);
      continue;
    }
  }
  await emitLocal(instance);   // local symbol or unknown library
}
```

**Why the library map is configurable:** the converter cannot infer the npm package name from the .sketch file alone. Surface the map in `config.json` (`{ "foreign_library_map": { ... } }`) and ask the user to fill it on first run.

**Fallback policy:** when the library map has no entry, emit the symbol once into a sentinel `src/generated/foreign/` directory and import from there — this is salvageable into a real package later, whereas inline duplication is not.

Reference: [Sketch File Format — foreignSymbols](https://developer.sketch.com/file-format/objects#ForeignSymbol)
