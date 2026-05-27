---
title: Compose a request pipeline as pipe(handler, handler, handler) instead of linked Handler classes
tags: pipe, chain-of-responsibility-alternative, middleware, composition
---

## Compose a request pipeline as pipe(handler, handler, handler) instead of linked Handler classes

A model trained on the Chain of Responsibility pattern will define an abstract `Handler` class with `setNext()` and `handle()`, then chain three or four subclasses. In TypeScript — especially in HTTP, validation, parsing, or transformation pipelines — the equivalent is `pipe(step1, step2, step3)` over an array of small functions. Reach for the class form only when each handler must decide at runtime whether to pass the request along, when handlers carry their own state, or when the chain is reconfigured after construction.

### Shapes to recognize

- An `AbstractHandler` (or `Middleware` base class) with a `next` field and a `setNext` method
- Three to six subclasses, each implementing `handle(request)` to do one thing and call `super.handle(request)` or `this.next.handle(request)`
- A boot-time `auth.setNext(rateLimit).setNext(parse).setNext(route)` wiring that never changes
- A wired chain whose request type is the same on input and output (no narrowing through the steps)

**Incorrect (Chain of Responsibility class hierarchy):**

```typescript
abstract class RequestHandler {
  private next?: RequestHandler;
  setNext(h: RequestHandler) { this.next = h; return h; }
  handle(req: Request): Request {
    return this.next ? this.next.handle(req) : req;
  }
}

class AuthHandler extends RequestHandler {
  handle(req: Request) {
    if (!req.headers.authorization) throw new Error('unauthenticated');
    return super.handle({ ...req, userId: decodeToken(req.headers.authorization) });
  }
}

class RateLimitHandler extends RequestHandler {
  handle(req: Request) {
    if (!withinRateLimit(req.userId)) throw new Error('rate-limited');
    return super.handle(req);
  }
}

class ParseBodyHandler extends RequestHandler {
  handle(req: Request) {
    return super.handle({ ...req, body: JSON.parse(req.rawBody) });
  }
}

const chain = new AuthHandler();
chain.setNext(new RateLimitHandler()).setNext(new ParseBodyHandler());
const result = chain.handle(rawRequest);
```

**Correct (pipe of pure functions):**

```typescript
type Handler<T> = (req: T) => T;

const authenticate: Handler<Request> = (req) => {
  if (!req.headers.authorization) throw new Error('unauthenticated');
  return { ...req, userId: decodeToken(req.headers.authorization) };
};

const enforceRateLimit: Handler<Request> = (req) => {
  if (!withinRateLimit(req.userId)) throw new Error('rate-limited');
  return req;
};

const parseBody: Handler<Request> = (req) => ({ ...req, body: JSON.parse(req.rawBody) });

const pipe = <T>(...fns: Handler<T>[]): Handler<T> =>
  (input) => fns.reduce((acc, fn) => fn(acc), input);

const handle = pipe(authenticate, enforceRateLimit, parseBody);
const result = handle(rawRequest);
```

Each step is independently testable as a pure function. Reordering is editing a `pipe` argument list, not rewiring object graph. The `pipe` helper is six lines; many projects already have one in `fp-ts`, `Effect`, `lodash/fp`, or `remeda`.

### When NOT to apply (keep the chain)

- A handler must decide at runtime whether to pass the request along *or short-circuit and return early* — `pipe` always runs every step (though early-throw still works, `Result`/`Either` types handle this functionally; see Effect/fp-ts)
- Handlers carry per-instance state (request counters, connection pools, retry budgets) that must outlive a single request
- The chain is reconfigured at runtime — plugins inserted/removed, middleware order swapped by feature flag — and you need a named handle to each link
- Each step *narrows the type* of the request (`Request` → `AuthenticatedRequest` → `ParsedRequest`) and you want the type system to track that progression rigorously — a typed `pipe` (Effect, fp-ts) handles this, but raw `reduce` does not

### Related

- GoF class form: [`behavioral-chain-of-responsibility`](../../implementation-design-patterns/references/behavioral-chain-of-responsibility.md)
- Function composition with type narrowing: [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md) *(planned)*

Reference: [MDN — `Array.prototype.reduce`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce)
