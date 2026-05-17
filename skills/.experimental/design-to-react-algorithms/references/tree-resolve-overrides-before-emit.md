---
title: Resolve symbolInstance Overrides Against the Master Before Emit
impact: CRITICAL
impactDescription: prevents instance/master divergence; reduces emitted JSX by 5-50x for repeated symbols
tags: tree, symbols, overrides, prop-flattening
---

## Resolve symbolInstance Overrides Against the Master Before Emit

Every `symbolInstance` carries an `overrideValues` array keyed by `overridePath` — a dotted path into the master's subtree (e.g., `"3F2C…/2A1B…_stringValue"`). The instance does *not* contain the resolved tree; you must merge the master's layers with the instance's overrides yourself. Emitting the instance without resolving overrides produces components with the master's defaults always, and the per-instance customizations silently vanish.

**Incorrect (treating the instance as self-contained):**

```ts
function emitInstance(instance: SymbolInstance) {
  // Wrong: instance.layers is empty — the actual content lives in the master.
  return `<div>${instance.layers?.map(emitLayer).join('')}</div>`;
  // Result: every button renders with placeholder text "Label" from the master.
}
```

**Correct (merge master subtree with instance overrides into props):**

```ts
function emitInstance(instance: SymbolInstance, masters: Map<string, SymbolMaster>) {
  const master = masters.get(instance.symbolID);
  if (!master) throw new Error(`Master not found: ${instance.symbolID}`);

  // Each override targets a path like "<layerID>_stringValue" or "<layerID>_image".
  // Build a path → value map keyed by the override's target layer ID + property.
  const overrides = new Map(
    instance.overrideValues.map(o => [o.overrideName, o.value])
  );

  // The master's overrideProperties declares which paths are overridable.
  // For each, derive a prop name and resolve the value (instance → master default).
  //   propNameFor: YOUR resolver — typically slugifies the target layer's name
  //                ("Title Label" → "title") and disambiguates duplicates with the property kind.
  //   defaultValueAt: YOUR resolver — walks `master.layers` along the override path and
  //                   reads the field (e.g., `attributedString.string`, `image._ref`).
  const props: Record<string, unknown> = {};
  for (const prop of master.overrideProperties ?? []) {
    const propName = propNameFor(prop, master);     // e.g., "title", "icon"
    props[propName] =
      overrides.get(prop.overrideName) ??
      defaultValueAt(master, prop.overrideName);    // master's value at that path
  }

  // Now emit as a component reference, not as inline JSX.
  return `<${componentNameFor(master)} ${propsToAttrs(props)} />`;
}
```

**Why named props beat inline JSX:** with N instances of a master, named props compress N × (master-subtree-size) JSX into N short attribute lists plus one component definition. Future override changes diff cleanly because only the prop value changed, not 200 lines of nested JSX.

Reference: [Sketch File Format — overrideValues](https://developer.sketch.com/file-format/objects#OverrideValue)
