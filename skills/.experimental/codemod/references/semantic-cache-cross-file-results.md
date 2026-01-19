---
title: Cache Semantic Analysis Results
impact: HIGH
impactDescription: avoids redundant cross-file resolution
tags: semantic, caching, performance, optimization
---

## Cache Semantic Analysis Results

Semantic analysis operations are expensive. Cache results when analyzing multiple related symbols to avoid redundant cross-file resolution.

**Incorrect (repeated analysis):**

```typescript
const transform: Transform<TSX> = async (root) => {
  const apiCalls = root.findAll({
    rule: { pattern: "$API.$METHOD($$$ARGS)" }
  });

  const edits = await Promise.all(apiCalls.map(async call => {
    const apiId = call.getMatch("API");
    if (!apiId) return null;

    // Each call re-resolves the same API symbol
    const def = apiId.definition();  // Expensive!

    // Each call re-finds all references
    const refs = apiId.references();  // Very expensive!

    return call.replace(`newApi.${call.getMatch("METHOD")?.text()}()`);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**Correct (cached analysis):**

```typescript
const transform: Transform<TSX> = async (root) => {
  // Cache for definitions by symbol text
  const defCache = new Map<string, DefinitionResult | null>();

  // Cache for references by definition location
  const refCache = new Map<string, FileReference[]>();

  const apiCalls = root.findAll({
    rule: { pattern: "$API.$METHOD($$$ARGS)" }
  });

  const edits = await Promise.all(apiCalls.map(async call => {
    const apiId = call.getMatch("API");
    if (!apiId) return null;

    const apiName = apiId.text();

    // Check cache before expensive operation
    if (!defCache.has(apiName)) {
      defCache.set(apiName, apiId.definition());
    }
    const def = defCache.get(apiName);

    if (def) {
      const defKey = `${def.root.filename()}:${def.node.range().start}`;
      if (!refCache.has(defKey)) {
        refCache.set(defKey, def.node.references() || []);
      }
    }

    return call.replace(`newApi.${call.getMatch("METHOD")?.text()}()`);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**What to cache:**
- `definition()` results by symbol name
- `references()` results by definition location
- Cross-file root objects for repeated writes
- Import resolution results

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)
