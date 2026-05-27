---
title: Compose wrappers as compose(withCache, withLogging, withAuth)(handler) instead of Decorator classes
tags: pipe, compose, decorator-alternative, function-composition, middleware
---

## Compose wrappers as compose(withCache, withLogging, withAuth)(handler) instead of Decorator classes

A model trained on the Decorator pattern stacks three wrapper classes — `LoggingDecorator(CachingDecorator(AuthDecorator(handler)))` — when the wrappers add cross-cutting behavior (logging, caching, auth, retries, metrics) without changing the wrapped object's interface. In TypeScript, the equivalent is **function composition**: each wrapper is a function `(fn) => fn'` that takes a handler and returns a wrapped one. Compose them with `compose` (right-to-left) or `pipe` (left-to-right) and apply to the base handler. Reach for the class form only when wrappers must be added or removed at runtime, when they carry per-instance state that outlives a single call, or when the wrapper type-narrows the handler's signature in a way function composition can't track.

### Distinguishing `compose` from `pipe`

Both this rule and [`pipe-pipeline-over-chain-of-responsibility`](pipe-pipeline-over-chain-of-responsibility.md) use function composition, but they solve different problems:

- **`pipe(stepA, stepB, stepC)(input)`** — pipeline of *data transforms*. Each step's output becomes the next step's input. The data flows forward; reading order matches execution order.
- **`compose(wrapperA, wrapperB, wrapperC)(handler)`** — composition of *function wrappers*. Each wrapper takes a handler and returns a decorated handler. By convention right-to-left: `compose(f, g, h)(x) === f(g(h(x)))`, so the **outermost** wrapper is on the left. This matches how Decorator class stacking reads top-to-bottom from outermost to innermost.

If you want decoration order to read left-to-right (innermost-first), use `pipe` — it just inverts the order.

### Shapes to recognize

- An `AbstractDecorator` base class that holds a reference to the wrapped object and forwards every method
- Three to six `Decorator` subclasses, each overriding one method to "do my thing then call `super` / `this.wrapped`"
- Boot-time wiring: `new LoggingDecorator(new CachingDecorator(new AuthDecorator(realHandler)))` — fixed once, never reconfigured
- Each decorator is stateless: its only fields are the wrapped object and any constructor-injected config that never changes

**Incorrect (three Decorator classes wrapping a handler):**

```typescript
type RequestHandler = (req: Request) => Promise<Response>;

abstract class HandlerDecorator {
  constructor(protected wrapped: RequestHandler) {}
  abstract handle(req: Request): Promise<Response>;
}

class WithAuth extends HandlerDecorator {
  async handle(req: Request) {
    if (!req.headers.authorization) throw new Error('unauthenticated');
    return this.wrapped({ ...req, userId: decodeToken(req.headers.authorization) });
  }
}

class WithCache extends HandlerDecorator {
  private cache = new Map<string, Response>();
  async handle(req: Request) {
    const key = `${req.method}:${req.url}`;
    const hit = this.cache.get(key);
    if (hit) return hit;
    const res = await this.wrapped(req);
    if (req.method === 'GET') this.cache.set(key, res);
    return res;
  }
}

class WithLogging extends HandlerDecorator {
  async handle(req: Request) {
    const start = Date.now();
    try {
      return await this.wrapped(req);
    } finally {
      logger.info({ url: req.url, durationMs: Date.now() - start });
    }
  }
}

const realHandler: RequestHandler = async (req) => fetch(req.url).then((r) => r as unknown as Response);

const stack = new WithLogging(new WithCache(new WithAuth(realHandler)).handle.bind);
// ...awkward: each Decorator's .handle must be bound; can't be passed as RequestHandler directly
```

The class form forces each Decorator to expose `.handle` rather than being a `RequestHandler` itself, breaks call-site interchangeability with the base type, and (in the `WithCache` case) hides per-instance state inside a class field that's not obviously the wrapper's responsibility.

**Correct (each wrapper is `(handler) => handler`; compose them):**

```typescript
type RequestHandler = (req: Request) => Promise<Response>;
type Wrap = (handler: RequestHandler) => RequestHandler;

const withAuth: Wrap = (handler) => async (req) => {
  if (!req.headers.authorization) throw new Error('unauthenticated');
  return handler({ ...req, userId: decodeToken(req.headers.authorization) });
};

const withCache = (): Wrap => {
  const cache = new Map<string, Response>(); // captured per call to withCache(), not shared
  return (handler) => async (req) => {
    const key = `${req.method}:${req.url}`;
    const hit = cache.get(key);
    if (hit) return hit;
    const res = await handler(req);
    if (req.method === 'GET') cache.set(key, res);
    return res;
  };
};

const withLogging: Wrap = (handler) => async (req) => {
  const start = Date.now();
  try {
    return await handler(req);
  } finally {
    logger.info({ url: req.url, durationMs: Date.now() - start });
  }
};

const compose = <T>(...wraps: ((x: T) => T)[]) => (base: T): T =>
  wraps.reduceRight((acc, w) => w(acc), base);

const realHandler: RequestHandler = async (req) => fetch(req.url).then((r) => r as unknown as Response);

const handle = compose(withLogging, withCache(), withAuth)(realHandler);
// Reads top-down: log around cache around auth around realHandler — same as the class form.
```

Each wrapper is interchangeable with the base type (it returns a `RequestHandler`, so it can be passed anywhere one is expected). Per-instance state — the cache — is honestly modelled by a factory function (`withCache()`) that captures the cache in a closure; you pick when a fresh cache is created. The composition order in the `compose(...)` call reads exactly like the Decorator stack.

### Common pitfalls

- **`compose` vs `pipe` direction.** `compose(f, g, h)(x) === f(g(h(x)))` (right-to-left, math convention). `pipe(f, g, h)(x) === h(g(f(x)))` (left-to-right). Pick one convention per project — fp-ts, Effect, Ramda all use right-to-left `compose`. Mixing both in one file invites bugs.
- **Wrapper state is per-instance.** If `withCache` is a top-level constant `Wrap`, every call site shares the same cache. Use a factory (`withCache()` returning a `Wrap`) when each composition needs its own state — the closure captures the state, the factory hands out fresh ones.
- **Async wrappers must `await`.** Forgetting `await handler(req)` inside an async wrapper returns the unresolved Promise upstream — the wrapper around it sees a Promise<Promise<Response>>. `try/finally` for logging needs an actual `await` or you log before the wrapped handler resolves.
- **Throwing in a wrapper crosses the abstraction.** If `withAuth` throws, every wrapper *outside* it must understand that exception. The same is true for the class form, but composition makes it visible — the outer wrappers are obviously the catch sites.

### Performance trade-offs

- **Time:** A composed chain calls n functions; a Decorator-class chain calls n methods. Modern V8 inlines both equally well. No measurable difference at the per-call level.
- **Allocations:** The composed chain allocates one closure per `compose` step at composition time (once, at boot). The class chain allocates one class instance per step. Closures are typically *lighter* than class instances with a prototype chain — small win, not the reason to do this.
- **The real cost is in the boilerplate**, which the composed form deletes. Three wrapper classes ≈ 60 lines; three wrapper functions + `compose` ≈ 30 lines.

### When NOT to apply (keep the Decorator class)

- **Per-instance state with lifecycle** — the wrapper holds a database connection, a metrics emitter, or a resource that must be `Symbol.dispose`d when the wrapper goes out of scope. Classes (especially with `using` and `Symbol.dispose`) model this honestly; closures don't have a destructor hook.
- **Runtime add/remove of wrappers** — users toggle middlewares in a config UI; you need to introspect and reorder the stack at runtime. Each Decorator class is a named addressable thing; closures in a composed chain are opaque.
- **Type-narrowing wrappers** — `withAuth: (h: Handler) => Handler<AuthenticatedRequest>` where the wrapped handler now sees a narrower input type. Function composition can express this with conditional types and overloads, but the class form with a chain of named interfaces is often clearer. (Effect and fp-ts handle this elegantly if you're already in their ecosystem.)
- **Cross-cutting state shared across all wrappers** — a unit of work, a transaction handle, a request-scoped context. A context object passed through `pipe` or a stateful class hierarchy both work; pick whichever the team reads more readily.

### Related

- GoF class form: [`structural-decorator`](../../implementation-design-patterns/references/structural-decorator.md)
- Linear data pipelines (different shape, same machinery): [`pipe-pipeline-over-chain-of-responsibility`](pipe-pipeline-over-chain-of-responsibility.md)
- HOF as the building block of any wrapper: [`hof-lambda-as-strategy`](hof-lambda-as-strategy.md)

Reference: [Mostly Adequate Guide — Ch. 5 "Coding by Composing"](https://mostly-adequate.gitbook.io/mostly-adequate-guide/ch05) · [MDN — `Array.prototype.reduceRight`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduceRight)
