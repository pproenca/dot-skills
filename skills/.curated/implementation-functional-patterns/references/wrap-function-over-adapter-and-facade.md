---
title: Translate or simplify an interface with a wrapper function instead of an Adapter or Facade class
tags: wrap, adapter, facade, interface-translation, subsystem-simplification
---

## Translate or simplify an interface with a wrapper function instead of an Adapter or Facade class

Two GoF patterns — Adapter (translate one interface to another) and Facade (expose a simple interface over a complex subsystem) — collapse to the same TypeScript shape: a **function (or small set of functions) that takes the awkward thing and returns a function in the shape you want**. The Adapter class form (`class StripeAdapter implements PaymentProvider { …forwards each call… }`) and the Facade class form (`class FileUploadFacade { … }`) both exist because their source languages can't return arbitrary objects with matching interfaces from a function. TypeScript can, so the class is ceremony. The distinction between the two patterns survives — Adapter translates *shape*, Facade hides *complexity* — but at the implementation level they're both "a function that wraps something else."

### Shapes to recognize

- A class that implements a target interface by forwarding each method to a wrapped object (Adapter): `class FetchHttpClient implements HttpClient { get(url) { return fetch(url).then(r => r.json()) } }`
- A class whose only purpose is to call several lower-level APIs in sequence and hide the orchestration (Facade): `class S3UploadFacade { upload(file) { compress() then sign() then put() then notify() } }`
- A "wrapper class" with no state of its own, only forwarding methods
- Code where every method of the wrapper is one line that calls one method of the wrapped thing — pure interface translation

**Incorrect (Adapter class translating an old HTTP client to a new interface):**

```typescript
interface HttpClient {
  get<T>(url: string): Promise<T>;
  post<T>(url: string, body: unknown): Promise<T>;
}

class LegacyXhrAdapter implements HttpClient {
  constructor(private xhr: { request: (cfg: { method: string; url: string; body?: unknown }) => Promise<{ data: unknown }> }) {}

  async get<T>(url: string): Promise<T> {
    const res = await this.xhr.request({ method: 'GET', url });
    return res.data as T;
  }

  async post<T>(url: string, body: unknown): Promise<T> {
    const res = await this.xhr.request({ method: 'POST', url, body });
    return res.data as T;
  }
}

const client: HttpClient = new LegacyXhrAdapter(legacyXhr);
```

**Correct (factory function returning the target shape):**

```typescript
type HttpClient = {
  get:  <T>(url: string)                  => Promise<T>;
  post: <T>(url: string, body: unknown)   => Promise<T>;
};

function adaptLegacyXhr(xhr: LegacyXhr): HttpClient {
  return {
    get:  async <T>(url)       => (await xhr.request({ method: 'GET',  url        })).data as T,
    post: async <T>(url, body) => (await xhr.request({ method: 'POST', url, body  })).data as T,
  };
}

const client = adaptLegacyXhr(legacyXhr);
```

Same surface, half the lines, no class, no `implements`. The contract is enforced by the `: HttpClient` return type — structural typing does what `implements` did in the class form.

**Facade collapses identically:**

```typescript
// Subsystem APIs: s3Client, imageProcessor, db, notifier — each with their own interface

async function uploadAndProcessImage(file: File, userId: string): Promise<{ id: string; url: string }> {
  const compressed = await imageProcessor.compress(file, { quality: 0.8 });
  const { key, url } = await s3Client.put({ bucket: 'user-uploads', body: compressed });
  const record = await db.images.insert({ ownerId: userId, key, contentType: file.type });
  await notifier.send(userId, { type: 'upload-complete', imageId: record.id });
  return { id: record.id, url };
}
```

That's the Facade. One function, well-named, calls the four subsystems in order. No `class ImageUploadFacade { constructor(private s3, private images, …) }` with one method delegating to the four — that class is the same code plus dependency-injection ceremony.

When the facade needs configuration captured at construction:

```typescript
function createImageUploader(deps: { s3: S3Client; images: ImageProcessor; db: Db; notifier: Notifier }) {
  return {
    upload: async (file: File, userId: string) => {
      const compressed = await deps.images.compress(file, { quality: 0.8 });
      // …same as above…
    },
  };
}
```

A factory function returns an object of methods — same DI capability, no class.

### Common pitfalls

- **Adapter that does more than translate.** If the adapter validates inputs, retries on failure, caches results, or adds logging, it's no longer pure translation — it's also wrapping behavior. That's `compose` territory. Keep adapters thin; layer concerns separately ([`pipe-compose-over-decorator`](pipe-compose-over-decorator.md)).
- **Facade swallowing errors.** A facade hiding orchestration can also accidentally hide failure modes — caller doesn't know whether the s3 put failed or the db insert did. Propagate enough error info (typed errors, `Result` types) for callers to react meaningfully.
- **Facade growing into a god-function.** A facade that started as "upload-and-process" and now also handles cropping, watermarking, virus scanning, and notification-fan-out is too big. Split into smaller facades or expose the lower-level steps for callers that need specificity.
- **Returning a class instance from a factory function.** `function adaptLegacyXhr(xhr) { return new HttpClient(xhr) }` keeps the class. That's still a factory function but you've added a class. Only do this if `HttpClient` carries methods that genuinely deserve `this` binding (subclassing, framework integration) — most don't.
- **Reaching for a "facade" when you mean an SDK.** Wrapping several public methods into a single entry point is a *facade*. Wrapping an entire third-party service with versioned, typed, documented endpoints is an *SDK* — bigger thing, more design needed.

### Performance trade-offs

- **Time:** wrapper function call ≈ wrapper class method call. Same V8 inlining.
- **Memory:** the function form allocates one object literal per `adapt(…)` call (a tiny record of methods). The class form allocates one class instance. Comparable.
- **Bundle size:** factory functions tree-shake when unused. Adapter classes tend to drag in their dependencies because any reference to the class anchors the whole class definition.

### When NOT to apply (keep the class)

- **The adapter must be polymorphic.** Multiple adapters share an interface and you need to swap them at runtime via DI container, plugin registry, or feature flag — a named class is a clean handle. The factory-function shape works too, but the class form makes the polymorphism syntactically obvious
- **You need to subclass the adapter.** Specialized adapters extend a base adapter with overrides. Inheritance models that; closures don't (well — you can compose factories, but inheritance is sometimes cleaner)
- **The facade owns lifecycle.** A facade that opens a connection, registers cleanup, and must be disposed at shutdown is more naturally a class with `Symbol.dispose` — the `using` syntax pairs with classes
- **Framework integration.** Some DI containers, ORMs, and decorator libraries assume the wrapper is a class. Going against the grain costs more than the boilerplate saved

### Related

- GoF class forms collapsed: [`structural-adapter`](../../../.experimental/implementation-design-patterns/references/structural-adapter.md), [`structural-facade`](../../../.experimental/implementation-design-patterns/references/structural-facade.md)
- For substitute-and-control-access (Proxy, distinct from Adapter/Facade): [`wrap-proxy-native-or-hof`](wrap-proxy-native-or-hof.md)
- For adding behavior layers (Decorator): [`pipe-compose-over-decorator`](pipe-compose-over-decorator.md)

Reference: [TS Handbook — Object Types](https://www.typescriptlang.org/docs/handbook/2/objects.html) · [MDN — Closures](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
