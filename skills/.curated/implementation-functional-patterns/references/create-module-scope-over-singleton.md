---
title: Export a module-scope constant or lazy memo instead of a Singleton class
tags: create, module-singleton, lazy-init, anti-pattern
---

## Export a module-scope constant or lazy memo instead of a Singleton class

A model trained on Java/C# defaults to `class Db { private static instance; private constructor() {…}; static getInstance() { return Db.instance ??= new Db() } }`. In ES modules, this is **anti-idiom**: modules are already singletons (evaluated once per process, cached by URL), so `export const db = createDb()` *is* a singleton. Adding a class wrapper around it makes the dependency harder to mock in tests, harder to replace with an alternate implementation, and harder to lazily initialize than the module-scope form. Reach for the class form only when the singleton must survive HMR reloads with stable identity, when initialization is genuinely lazy *and* must happen on a specific call site, or when you need to inject test doubles via a registration call.

### Shapes to recognize

- A `class X { private static instance: X | null = null; private constructor() {…}; static getInstance(): X { … } }` — every line of this is anti-idiom in TS
- A "service locator" class with `register()` and `resolve()` methods, when imports would do the job
- A pattern where module-level state is wrapped in a class purely to hold a single instance — config, logger, DB client, cache, event bus

**Incorrect (class with private constructor + static getInstance):**

```typescript
export class Logger {
  private static instance: Logger | null = null;
  private constructor(private readonly transport: Transport) {}

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger(createDefaultTransport());
    }
    return Logger.instance;
  }

  info(msg: string): void { this.transport.write({ level: 'info', msg }); }
  warn(msg: string): void { this.transport.write({ level: 'warn', msg }); }
}

// Every call site:
Logger.getInstance().info('starting');
```

**Correct (module-scope const or lazy memo):**

```typescript
// logger.ts
const transport = createDefaultTransport();

export const logger = {
  info: (msg: string) => transport.write({ level: 'info', msg }),
  warn: (msg: string) => transport.write({ level: 'warn', msg }),
};

// Every call site:
import { logger } from './logger';
logger.info('starting');
```

When initialization must be deferred (e.g., depends on environment variables loaded at runtime, or is expensive and may not be needed):

```typescript
// db.ts
let _db: Db | null = null;

export const db = (): Db => _db ??= createDb({ url: process.env.DATABASE_URL! });

// Call sites:
import { db } from './db';
const users = await db().query('SELECT * FROM users');
```

`??=` (nullish assignment, ES2021) makes lazy initialization one line. Or use a thunk pattern for explicit laziness:

```typescript
export const db = lazy(() => createDb({ url: process.env.DATABASE_URL! }));
// where lazy<T>(f: () => T) returns a memoized thunk:
function lazy<T>(f: () => T): () => T {
  let cached: T | undefined;
  let initialized = false;
  return () => {
    if (!initialized) { cached = f(); initialized = true; }
    return cached!;
  };
}
```

### Common pitfalls

- **HMR (hot module reload) re-evaluates modules.** In dev, your "singleton" gets a fresh instance each save. Most of the time this is fine — you reload state intentionally. If you need a *truly* cross-reload singleton (a WebSocket connection, an opened browser tab, a started timer), cache it on `globalThis`: `((globalThis as any).__bus ??= createBus())`. Document the leak.
- **Module-scope const captures import-time environment.** `const apiUrl = process.env.API_URL` at module top-level reads the env *at import*. If the env is set later (test setup, dotenv loaded after imports), you get `undefined`. Use lazy initialization or import the value through a function.
- **Circular imports of singletons.** `a.ts` exports `a = createA(b)`; `b.ts` exports `b = createB(a)`. Module-level construction sees one of them as `undefined` at first evaluation. Either break the cycle structurally or use lazy initialization on at least one side.
- **Tests can't replace the singleton.** A class-based singleton with private constructor is *worse* for testing — you can't subclass it cleanly, you can't `new` an alternate. A module-scope export at least allows `vi.mock('./logger', () => …)` or dependency injection at higher layers. Avoid `import { logger }` deep inside business code; pass loggers as parameters or via context.
- **Singletons + multiple bundles.** If your code is bundled twice (server + client, two separate library entry points), each bundle gets its own "singleton" instance. Not unique to the class form — but module-scope makes it obvious, while class-based hides it.

### Performance trade-offs

- **Time:** identical at runtime — class `getInstance()` is a function call plus a property read; module-scope import is resolved once at load and is a direct reference thereafter (cheaper, actually).
- **Memory:** module-scope is a single object; class form is a class definition + a single instance. Difference is negligible.
- **Cold-start cost:** module-scope eager initialization runs at import time. If the singleton is expensive to build (`createDb()`, parsing a config file), lazy memoization defers it. The class form forces lazy by default; module-scope lets you choose.
- **Tree-shaking:** module-scope const that's not imported gets removed. Class definitions with any referenced static method tend to survive.

### When NOT to apply (keep the class form)

- **Cross-reload identity across HMR / SPA navigation.** If the singleton owns a long-lived OS-level resource (WebSocket, IndexedDB transaction, audio context) and must survive code reloads, `globalThis` + a sentinel-keyed lookup is the pattern; whether you wrap it in a class is style preference
- **Polymorphic singletons** — you want a *kind* of singleton (`Logger`, `MetricsLogger`, `NullLogger`) registered at boot and looked up by name. A `ServiceRegistry` class can model this, though a `Map<string, T>` plus a register/resolve pair of functions is just as honest
- **Singletons that must enforce construction invariants.** A class's private constructor + factory method makes it impossible to construct elsewhere. Module-scope exports trust the import — fine in app code, less fine in published libraries where users might `new` something they shouldn't

### Related

- GoF class form: [`creational-singleton`](../../../.experimental/implementation-design-patterns/references/creational-singleton.md)
- Factory functions that create *fresh* objects (the non-singleton case): [`create-factory-function-over-factory-classes`](create-factory-function-over-factory-classes.md)
- Caching arbitrary keyed values rather than a single instance: [`cache-weakmap-over-flyweight`](cache-weakmap-over-flyweight.md)

Reference: [MDN — `??=` (nullish assignment)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Logical_nullish_assignment) · [TC39 — Static class fields](https://tc39.es/proposal-class-fields/)
