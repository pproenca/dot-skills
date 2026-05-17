---
title: Convert Symbol Masters Before Any Instance References Them
impact: CRITICAL
impactDescription: prevents N copies of the same component diverging across the codebase
tags: iter, dependency-order, componentization, topological-sort
---

## Convert Symbol Masters Before Any Instance References Them

A Sketch `symbolMaster` is the definition; every `symbolInstance` is a reference with overrides. If you convert instances first, you emit N inline duplicates of the button component, each slightly different because the converter saw them out of context — then the master conversion produces an *unused* shared component and the duplicates drift forever. Topologically sort masters → instances so every instance can resolve to an already-emitted React component.

**Incorrect (page-order conversion, no dependency awareness):**

```ts
// Walk pages in file order and emit whatever you encounter.
for (const page of doc.pages) {
  for (const layer of page.layers) {
    await emitReact(layer);   // First instance hit emits inline JSX.
  }
}
// Result: 47 inline <div> copies of the "Table View Row" symbol,
// each subtly different because overrides applied differently each time.
```

**Correct (topological sort by symbol dependency):**

```ts
// 1. Collect all symbolMasters from every page.
const masters = collectSymbolMasters(doc);   // includes foreignSymbols

// 2. Build dependency graph: master M depends on master M' if any descendant
//    of M is a symbolInstance referencing M'. Then topological sort.
const order = topologicalSort(masters, dependenciesOf);

// 3. Emit masters first, in dependency order, as shared components.
for (const master of order) {
  await emitMasterComponent(master);  // → src/components/TableViewRow.tsx
}

// 4. Now emit pages. Every symbolInstance resolves to an import of an
//    already-emitted component, with overrides as props.
for (const page of doc.pages) {
  for (const layer of walk(page)) {
    if (layer._class === 'symbolInstance') {
      await emitInstanceAsImport(layer);  // <TableViewRow title={...} />
    } else {
      await emitReact(layer);
    }
  }
}
```

**Why topological sort:** Sketch allows symbols to contain other symbols (nested masters). A pure "all masters then all pages" two-pass approach fails when master A embeds master B — A's converter needs B's component to already exist as an import target.

Reference: [Sketch File Format — Symbol Masters and Instances](https://developer.sketch.com/file-format/objects)
