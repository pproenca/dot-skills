---
title: Use the native Proxy primitive or an HOF wrapper instead of a Proxy class
tags: wrap, proxy, native-proxy, lazy-loading, access-control, hof-wrapper
---

## Use the native Proxy primitive or an HOF wrapper instead of a Proxy class

The Proxy pattern substitutes one object for another while preserving the original interface, intercepting calls to add lazy loading, access control, caching, or logging. A model trained on Java/C# defaults to a `class XProxy implements X` that wraps a real `X` and forwards/intercepts each method. TypeScript has two better answers depending on the use case: (1) the **native `Proxy` primitive** for transparent interception of arbitrary property access — handles unknown keys, dynamic schemas, and reads/writes uniformly; (2) an **HOF wrapper** that takes the real implementation and returns one with selected behavior added — best when you know which calls to intercept and want plain TypeScript types without `Proxy`'s loose `any` shape. The class form is rarely the right pick in TS.

### When to reach for native `Proxy` vs an HOF

| Use case | Reach for |
|---|---|
| Lazy-load on first property access of an object whose shape you know | **HOF wrapper** (typed, no `Proxy` runtime cost) |
| Intercept every property read/write (debugging, observable state, ORM model proxies) | **Native `Proxy`** (uniform interception across all keys) |
| Dynamic property names you can't statically know (config from JSON, dynamic ORM) | **Native `Proxy`** |
| Cache method results, retry on failure, add logging around known methods | **HOF wrapper** or [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md) |
| Implement reactive state where any field change fires a callback | **Native `Proxy`** (or use a signal library) |

### Shapes to recognize

- A `class CachingProxy implements Service` wrapping a `Service` to cache method results — really a Decorator, see [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md)
- A `class LazyImageProxy implements Image` deferring `load()` until first `display()` — HOF territory
- A `class AccessControlledProxy implements Repository` checking permissions before each call — HOF or Decorator
- A `class VirtualProxy` for an expensive remote object — HOF with lazy init
- A "dynamic config" object built up at runtime where you can't statically type all keys — native `Proxy` for `get`/`set` traps

**Incorrect (Proxy class for lazy-load):**

```typescript
interface Image {
  display(): void;
  size(): number;
}

class RealImage implements Image {
  constructor(private filename: string) { this.load(); }
  private bytes!: Uint8Array;
  private load() { this.bytes = readFileSync(this.filename); }
  display() { canvas.draw(this.bytes); }
  size()    { return this.bytes.length; }
}

class LazyImageProxy implements Image {
  private real: RealImage | null = null;
  constructor(private filename: string) {}
  private get realImage() { return this.real ??= new RealImage(this.filename); }
  display() { this.realImage.display(); }
  size()    { return this.realImage.size(); }
}

const img: Image = new LazyImageProxy('large.png');
img.display();  // loads on first display
```

**Correct (HOF wrapper returning a lazy version):**

```typescript
type Image = {
  display: () => void;
  size:    () => number;
};

function lazyImage(filename: string): Image {
  let real: Image | null = null;
  const get = () => real ??= loadImage(filename);
  return {
    display: () => get().display(),
    size:    () => get().size(),
  };
}

const img = lazyImage('large.png');
img.display();  // loads on first display
```

Six lines of orchestration vs ~15 of class boilerplate. The closure carries the cached `real`; the returned object literal binds each method to the lazy getter.

**For unknown / dynamic keys, native `Proxy` is the right answer:**

```typescript
type DeepGet = { [key: string]: DeepGet };

function readonlyConfig(source: object): DeepGet {
  return new Proxy(source, {
    get(target, key, receiver) {
      const value = Reflect.get(target, key, receiver);
      if (value && typeof value === 'object') return readonlyConfig(value);
      return value;
    },
    set() { throw new Error('config is readonly'); },
  }) as DeepGet;
}

const config = readonlyConfig({ db: { host: 'localhost', port: 5432 }, cache: { ttl: 60 } });
console.log(config.db.host);   // 'localhost'
config.db.host = 'other';      // throws — readonly
```

The native `Proxy` handles arbitrary property names without a class declaring each one. The trade-off: TypeScript can't track the dynamic types past the `as DeepGet` cast — you give up some type safety in exchange for shape flexibility.

### Common pitfalls

- **Native `Proxy` and `instanceof`.** `proxiedObj instanceof Class` returns false unless the handler implements the `getPrototypeOf` trap forwarding to the target. Tests, ORMs, and runtime-type-checking libraries can misbehave silently.
- **Native `Proxy` and `JSON.stringify`.** Stringification uses property enumeration; if the `get` trap returns wrapped values, the JSON includes the wrappers' enumerable own keys, which may include `Proxy`-related artifacts. Unwrap before serializing.
- **`Proxy` performance.** Every property access goes through the trap handler. For hot-path objects (per-render in React, per-iteration in tight loops), this is measurable — 2–10× slower than direct property access. Don't put Proxies in inner loops.
- **HOF wrapper closes over mutable state.** A lazy wrapper's cached value lives in the closure. If you re-call the factory, you get a fresh wrapper with its own cache. If you re-assign the wrapper, the old closure becomes garbage. Be deliberate about whether the cache is per-wrapper or shared.
- **Forgetting to forward `Reflect.*`.** In a native Proxy handler, `get(t, k) { return doSomething(t, k) }` skips the receiver binding and prototype chain. Always `Reflect.get(target, key, receiver)` (and similar for `set`, `has`, `apply`) unless you specifically intend to alter the binding.

### Performance trade-offs

- **Time (HOF wrapper):** comparable to a Proxy class — function call overhead. Lazy init pays once.
- **Time (native `Proxy`):** every operation through a trap. Modern V8 has improved Proxy performance but it's still ~2–10× slower than direct access. Don't wrap performance-critical objects (per-render state, per-iteration data structures).
- **Memory (HOF):** one closure-bound object literal per wrapper. Comparable to a class instance.
- **Memory (native `Proxy`):** a `Proxy` object + its target + the handler. ~3× the per-object memory of a plain object. Negligible at small counts; relevant at millions.
- **Tree-shaking:** HOF wrappers tree-shake when unused. Native `Proxy` is a builtin — always available, never adds bundle size.

### When NOT to apply (keep the Proxy class)

- **Polymorphism via subclasses.** Multiple proxy variants share a common interface (`LoggingProxy`, `CachingProxy`, `AuthProxy`) and a base class consolidates the forwarding logic. Inheritance can be clearer than three independent factory functions
- **Framework integration that expects a class.** Some ORMs, dependency injectors, and reflection libraries reflect over class methods to register hooks. The class form integrates; a closure-returned object literal often doesn't (no class to reflect over)
- **Decorator-style stacking.** When the "proxy" is actually one of several wrappers stacked around the target, compose them as functions — that's not Proxy, that's Decorator: see [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md)

### Related

- GoF class form: [`structural-proxy`](../../../.experimental/implementation-design-patterns/references/structural-proxy.md)
- For multiple stacked wrappers (Decorator): [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md)
- For interface translation (Adapter): [`wrap-function-over-adapter-and-facade`](wrap-function-over-adapter-and-facade.md)
- For shared cached instances (Flyweight): [`cache-weakmap-over-flyweight`](cache-weakmap-over-flyweight.md)

Reference: [MDN — `Proxy`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy) · [MDN — `Reflect`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect)
