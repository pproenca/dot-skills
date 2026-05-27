---
title: Use Chain of Responsibility to Pass Requests Through Handlers
impact: MEDIUM-HIGH
impactDescription: replaces hardcoded validation/auth/parsing pipelines with composable handler chains, enables reordering or adding new handlers at runtime without modifying others, eliminates deeply nested if/else cascades that obscure pipeline intent
tags: behavioral, chain-of-responsibility, pipeline, middleware, handler-chain
---

## Use Chain of Responsibility to Pass Requests Through Handlers

**Pattern intent:** pass a request along a chain of handlers. Each handler decides either to process the request or pass it to the next handler. Handlers stay independent and can be reordered or composed at runtime.

### Shapes to recognize

- Sequential checks (auth → permissions → validation → rate limiting → cache) in one bloated function with early returns
- Middleware pipelines (Express/Koa-style `app.use(...)` chains, ASP.NET pipelines)
- Event bubbling: DOM events propagate up until something calls `stopPropagation()`
- Validation rules that must run in a particular order — and the order changes between contexts

### Problem

An online ordering system requires sequential validation: authentication, permission verification, data sanitization, brute-force protection, caching. As checks accumulate, the code becomes bloated and hard to maintain. Logic scattered across one method can't be reused independently across other endpoints.

### Solution

Extract each check into a standalone handler object with a single method. Link handlers into a chain where each holds a reference to the next. A request travels through the chain until a handler processes it or the chain is exhausted; any handler can stop propagation.

**Incorrect (hardcoded pipeline with nested conditionals):**

```typescript
function handleOrder(request: OrderRequest) {
  if (!authenticate(request))     return error('unauth');
  if (!checkPermission(request))  return error('forbidden');
  if (!validatePayload(request))  return error('bad request');
  if (rateLimited(request))       return error('throttled');
  if (cache.has(request.key))     return cache.get(request.key);
  // Add a new check? Insert another branch. Reorder them? Risky.
  return process(request);
}
```

**Correct (composable handler chain, runtime ordering):**

```typescript
/**
 * The Handler interface declares a method for building the chain of handlers.
 * It also declares a method for executing a request.
 */
interface Handler<Request = string, Result = string> {
    setNext(handler: Handler<Request, Result>): Handler<Request, Result>;

    handle(request: Request): Result;
}

/**
 * The default chaining behavior can be implemented inside a base handler class.
 */
abstract class AbstractHandler implements Handler
{
    private nextHandler?: Handler;

    public setNext(handler: Handler): Handler {
        this.nextHandler = handler;
        // Returning a handler from here will let us link handlers in a
        // convenient way like this:
        // monkey.setNext(squirrel).setNext(dog);
        return handler;
    }

    public handle(request: string): string {
        if (this.nextHandler) {
            return this.nextHandler.handle(request);
        }

        return '';
    }
}

/**
 * All Concrete Handlers either handle a request or pass it to the next handler
 * in the chain.
 */
class MonkeyHandler extends AbstractHandler {
    public handle(request: string): string {
        if (request === 'Banana') {
            return `Monkey: I'll eat the ${request}.`;
        }
        return super.handle(request);
    }
}

class SquirrelHandler extends AbstractHandler {
    public handle(request: string): string {
        if (request === 'Nut') {
            return `Squirrel: I'll eat the ${request}.`;
        }
        return super.handle(request);
    }
}

class DogHandler extends AbstractHandler {
    public handle(request: string): string {
        if (request === 'MeatBall') {
            return `Dog: I'll eat the ${request}.`;
        }
        return super.handle(request);
    }
}

/**
 * The client code is usually suited to work with a single handler. In most
 * cases, it is not even aware that the handler is part of a chain.
 */
function clientCode(handler: Handler) {
    const foods = ['Nut', 'Banana', 'Cup of coffee'];

    for (const food of foods) {
        console.log(`Client: Who wants a ${food}?`);

        const result = handler.handle(food);
        if (result) {
            console.log(`  ${result}`);
        } else {
            console.log(`  ${food} was left untouched.`);
        }
    }
}

const monkey = new MonkeyHandler();
const squirrel = new SquirrelHandler();
const dog = new DogHandler();

monkey.setNext(squirrel).setNext(dog);

console.log('Chain: Monkey > Squirrel > Dog\n');
clientCode(monkey);
console.log('');

console.log('Subchain: Squirrel > Dog\n');
clientCode(squirrel);
```

**Output:**

```text
Chain: Monkey > Squirrel > Dog

Client: Who wants a Nut?
  Squirrel: I'll eat the Nut.
Client: Who wants a Banana?
  Monkey: I'll eat the Banana.
Client: Who wants a Cup of coffee?
  Cup of coffee was left untouched.

Subchain: Squirrel > Dog

Client: Who wants a Nut?
  Squirrel: I'll eat the Nut.
Client: Who wants a Banana?
  Banana was left untouched.
Client: Who wants a Cup of coffee?
  Cup of coffee was left untouched.
```

### When to use

- Process different request types in sequences known only at runtime
- Execute several handlers in a specific order that may change
- Add or reorder handler sets dynamically

### When NOT to use

- The pipeline is fixed and small — a direct sequence of calls is clearer
- All handlers always run — a regular collection iteration without short-circuiting is simpler
- The pipeline state mutates and order coupling is high — Chain hides dependencies

### Implementation Steps

1. Declare the handler interface with the request-handling method
2. Create an abstract base handler with a `nextHandler` reference and default forwarding behavior
3. Implement concrete handlers; each decides whether to process or forward
4. Assemble chains statically (init time) or dynamically (factory)
5. Allow requests to enter the chain at any position, not necessarily the head
6. Decide what happens when no handler processes a request

### Pros

- Control the order of request handling
- Decouple invoker from receiver (Single Responsibility)
- Introduce new handlers without breaking existing code (Open/Closed)

### Cons

- Requests may end up unhandled if no handler matches

### Related Patterns

- **Command** — handlers can execute Commands, or the request itself can be a Command
- **Composite** — leaf components pass requests through parent chains to the root
- **Decorator** — same wrapping shape; decorators don't stop propagation while CoR handlers may
- **Mediator** / **Observer** — alternative coordination mechanisms; Mediator centralizes communication, Observer broadcasts to many subscribers

Reference: [refactoring.guru/design-patterns/chain-of-responsibility](https://refactoring.guru/design-patterns/chain-of-responsibility)
