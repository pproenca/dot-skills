---
title: Cache shared values with a WeakMap or Map plus a factory function, not a Flyweight class
tags: cache, flyweight, memoization, weakmap, intrinsic-state
---

## Cache shared values with a WeakMap or Map plus a factory function, not a Flyweight class

The Flyweight pattern shares intrinsic state across many small objects to save memory — instead of every `Tree` carrying its own `bitmap`, all trees of the same species point at a shared `TreeType`. A model trained on GoF defaults to a `FlyweightFactory` class with an internal pool, an `intrinsicState` method, and a `getFlyweight(key)` accessor. In TypeScript the equivalent is a **`WeakMap` or `Map` plus a factory function**: the cache is the data structure, the factory is the function. The class wrapper carries no useful state and exposes no extra capability. Reach for `WeakMap` when the cache key is an object (entries get auto-collected when the key is unreachable); use `Map` for primitive keys (faster lookups, but watch for leaks).

### Shapes to recognize

- A `FlyweightFactory` class with a `pool: Map<string, Flyweight>` field and one method `get(key)` doing memoization
- A "shared state" class instantiated once at startup, where every method is `pool.get(key) ?? pool.set(key, create(key))`
- Code that creates millions of small near-identical objects (text glyphs, tree species, ORM model classes per row) and would benefit from interning
- A "cache singleton" wrapping a Map for typed access — that's a Flyweight in disguise

**Incorrect (Flyweight class with internal pool):**

```typescript
type TreeType = { name: string; bitmap: Bitmap };

class TreeTypeFactory {
  private pool = new Map<string, TreeType>();

  getType(name: string, bitmap: Bitmap): TreeType {
    const key = name;
    let type = this.pool.get(key);
    if (!type) {
      type = { name, bitmap };
      this.pool.set(key, type);
    }
    return type;
  }
}

const factory = new TreeTypeFactory();
const trees = positions.map((pos) => ({
  pos,
  type: factory.getType('pine', pineBitmap),
}));
```

**Correct (Map + factory function):**

```typescript
type TreeType = { name: string; bitmap: Bitmap };

const treeTypes = new Map<string, TreeType>();

const getTreeType = (name: string, bitmap: Bitmap): TreeType =>
  treeTypes.get(name) ?? (treeTypes.set(name, { name, bitmap }), treeTypes.get(name)!);

const trees = positions.map((pos) => ({
  pos,
  type: getTreeType('pine', pineBitmap),
}));
```

Eight lines of class becomes three — the Map IS the pool, the function IS the factory method. The `(treeTypes.set(name, …), treeTypes.get(name)!)` idiom uses comma-expression to set-and-return; alternatively use `??=` on a temporary local:

```typescript
const getTreeType = (name: string, bitmap: Bitmap): TreeType => {
  let t = treeTypes.get(name);
  if (!t) treeTypes.set(name, t = { name, bitmap });
  return t;
};
```

**When the key is an object, use `WeakMap` for auto-cleanup:**

```typescript
const renderCache = new WeakMap<AstNode, RenderedOutput>();

const render = (node: AstNode): RenderedOutput => {
  let out = renderCache.get(node);
  if (!out) {
    out = computeRender(node);  // expensive
    renderCache.set(node, out);
  }
  return out;
};
```

When an `AstNode` becomes unreachable elsewhere, its `RenderedOutput` entry is garbage-collected automatically. With a regular `Map`, you'd have to remember to evict — a classic memory leak source.

### Common pitfalls

- **`Map` cache leaks when keys are never removed.** Long-lived `Map<string, T>` caches accumulate entries forever unless you cap their size (LRU eviction) or explicitly `delete`. For per-request caches that should be scoped to the request, attach them to the request object, not module scope.
- **`WeakMap` keys must be objects.** `weakMap.set('some-string', value)` is a TypeError. For string keys, `Map` is the choice; pair with eviction policy.
- **Sharing a mutable cached value defeats Flyweight's invariant.** The whole point is that the cached intrinsic state doesn't change per consumer. If a caller does `getTreeType('pine', …).bitmap = newBitmap`, *every* tree of type 'pine' now uses the new bitmap. Freeze cached values (`Object.freeze(...)`) or document the immutability contract.
- **Cache key collisions.** `getTreeType('pine', oakBitmap)` returns the existing 'pine' entry (with `pineBitmap`) and silently ignores the second argument. The factory function should either reject mismatched calls or include the bitmap (or its hash) in the key.
- **Premature memoization.** Caching takes memory and adds lookup cost. If the keyed values are cheap to create and infrequently reused, caching makes things slower *and* eats more memory. Benchmark before memoizing.

### Performance trade-offs

- **Time:** `Map.get` is O(1) amortized; `WeakMap.get` is too. The factory function call plus a lookup is comparable to a class method's overhead.
- **Memory:** the *win* is in cached values vs duplicated values. Sharing one `TreeType` across 1M trees saves `1M * sizeof(TreeType)` minus the cache's own overhead. Worth it when the intrinsic state is meaningfully large (bitmaps, parsed ASTs, compiled regexes).
- **GC behavior:** `WeakMap` entries are collected when keys are unreachable. `Map` entries persist until manually removed. Choose based on the value's lifecycle.
- **Cache replacement policy matters at scale.** For unbounded `Map` caches with a hot working set, an LRU implementation (e.g., `lru-cache` package) prevents memory growth. For small finite key sets, plain `Map` is fine.

### When NOT to apply (keep the Flyweight class)

- **Multiple caches with shared eviction policy.** When you have several pools that all need the same LRU rules, max size, and metrics, a `CacheFactory` class encapsulating that policy is reasonable. Function factories returning `{ get, set, evict }` work too — pick whichever the team reads more readily
- **The pool itself has lifecycle.** The cache must be initialized with configuration, flushed on shutdown, persisted to disk, or replaced atomically. A class with explicit `init`/`dispose` methods is cleaner than a module-scope `Map` and ad-hoc lifecycle hooks
- **Interfacing with a framework that expects a class.** Some ORMs and dependency-injection systems expect repositories/caches to be classes with annotated decorators. Going against the grain costs more than the saved boilerplate

### Related

- GoF class form: [`structural-flyweight`](../../../.experimental/implementation-design-patterns/references/structural-flyweight.md)
- For single-instance objects (Singleton): [`create-module-scope-over-singleton`](create-module-scope-over-singleton.md)
- For interface translation (Adapter/Facade): [`wrap-function-over-adapter-and-facade`](wrap-function-over-adapter-and-facade.md)

Reference: [MDN — `WeakMap`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap) · [MDN — `Map`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)
