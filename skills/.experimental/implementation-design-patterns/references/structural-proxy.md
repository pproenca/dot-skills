---
title: Use Proxy to Insert a Substitute Controlling Access to an Object
impact: MEDIUM-HIGH
impactDescription: enables lazy loading, access control, caching, and logging without modifying the real subject or duplicating that logic at every call site, preserves the original interface so callers remain unchanged
tags: structural, proxy, lazy-loading, access-control, caching, same-interface
---

## Use Proxy to Insert a Substitute Controlling Access to an Object

**Pattern intent:** provide a surrogate or placeholder for another object to control access to it. The proxy implements the same interface as the real subject so clients can't tell the difference.

### Shapes to recognize

- A heavyweight object (large video, remote service, expensive computation) you want to load lazily
- Need to add caching, access control, logging, or request batching around an existing service — without touching it
- A client interacts with a remote service and you want network handling separate from business logic
- Smart pointers / smart references in classic OOP languages

### Problem

You have a resource-intensive object needed only occasionally. Implementing lazy initialization in every client duplicates code, and modifying a closed third-party class isn't possible.

### Solution

Create a proxy class implementing the same interface as the real subject. The proxy handles lazy initialization, caching, logging, or access checks transparently and delegates the real work to the subject when needed. Clients hold a reference to the interface — they don't know whether it's the proxy or the subject.

**Incorrect (every caller duplicates lazy-loading and access-control code):**

```typescript
class HeavyVideo {
  constructor(filename: string) { /* eager load — slow */ }
  play() { /* ... */ }
}

class Player {
  private cache: Record<string, HeavyVideo> = {};
  play(filename: string, user: User) {
    if (!user.canWatch(filename)) throw new Error('forbidden'); // duplicated everywhere
    if (!this.cache[filename]) this.cache[filename] = new HeavyVideo(filename); // duplicated everywhere
    this.cache[filename].play();
  }
}
```

**Correct (proxy mediates access, real subject stays clean):**

```typescript
/**
 * The Subject interface declares common operations for both RealSubject and the
 * Proxy. As long as the client works with RealSubject using this interface,
 * you'll be able to pass it a proxy instead of a real subject.
 */
interface Subject {
    request(): void;
}

/**
 * The RealSubject contains some core business logic. Usually, RealSubjects are
 * capable of doing some useful work which may also be very slow or sensitive -
 * e.g. correcting input data. A Proxy can solve these issues without any
 * changes to the RealSubject's code.
 */
class RealSubject implements Subject {
    public request(): void {
        console.log('RealSubject: Handling request.');
    }
}

/**
 * The Proxy has an interface identical to the RealSubject.
 */
class ProtectionProxy implements Subject {
    private realSubject: RealSubject;

    /**
     * The Proxy maintains a reference to an object of the RealSubject class. It
     * can be either lazy-loaded or passed to the Proxy by the client.
     */
    constructor(realSubject: RealSubject) {
        this.realSubject = realSubject;
    }

    /**
     * The most common applications of the Proxy pattern are lazy loading,
     * caching, controlling the access, logging, etc. A Proxy can perform one of
     * these things and then, depending on the result, pass the execution to the
     * same method in a linked RealSubject object.
     */
    public request(): void {
        if (this.checkAccess()) {
            this.realSubject.request();
            this.logAccess();
        }
    }

    private checkAccess(): boolean {
        // Some real checks should go here.
        console.log('Proxy: Checking access prior to firing a real request.');
        return true;
    }

    private logAccess(): void {
        console.log('Proxy: Logging the time of request.');
    }
}

/**
 * The client code is supposed to work with all objects (both subjects and
 * proxies) via the Subject interface in order to support both real subjects and
 * proxies. In real life, however, clients mostly work with their real subjects
 * directly. In this case, to implement the pattern more easily, you can extend
 * your proxy from the real subject's class.
 */
function clientCode(subject: Subject) {
    subject.request();
}

console.log('Client: Executing the client code with a real subject:');
const realSubject = new RealSubject();
clientCode(realSubject);

console.log('');

console.log('Client: Executing the same client code with a proxy:');
const proxy = new ProtectionProxy(realSubject);
clientCode(proxy);
```

**Output:**

```text
Client: Executing the client code with a real subject:
RealSubject: Handling request.

Client: Executing the same client code with a proxy:
Proxy: Checking access prior to firing a real request.
RealSubject: Handling request.
Proxy: Logging the time of request.
```

### When to use

- Lazy initialization for heavyweight objects whose construction is expensive
- Access control restricting specific clients from a service
- Remote service execution where you want to hide network handling
- Logging or auditing all requests transparently
- Caching recurring requests with identical results
- Smart reference counting / lifecycle tracking

### When NOT to use

- The real subject is cheap and always needed — Proxy adds latency for nothing
- You actually want to change the interface — use **Adapter**
- You want to *simplify* a subsystem — use **Facade**
- You want to *layer behaviors* without lifecycle concerns — use **Decorator**

### Implementation Steps

1. Create a service interface if none exists, so proxy and service are interchangeable
2. Build the proxy class with a reference to the service object
3. Implement proxy methods to delegate to the service after pre-processing
4. Add a creation helper that decides whether to return the proxy or the real service
5. Consider lazy initialization — instantiate the real subject only on first call

### Pros

- Control over the service object without client awareness
- Manage service lifecycle independently from the client
- Operates even when the service isn't yet available (lazy)
- Open/Closed Principle: introduce new proxies without changing the service or clients

### Cons

- Increased complexity — additional classes per service
- Potential service response delays from the proxy's pre-processing

### Related Patterns

- **Adapter** — changes the interface; Proxy keeps it identical
- **Facade** — simplifies a *subsystem*; Proxy wraps a *single object* and keeps the interface
- **Decorator** — same wrapping shape, but Decorator adds behavior recursively while Proxy controls lifecycle independently of the client

Reference: [refactoring.guru/design-patterns/proxy](https://refactoring.guru/design-patterns/proxy)
