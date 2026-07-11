---
title: Collapse parallel Option fields into the enum they encode
tags: type, option, result, sum-types
---

## Collapse parallel Option fields into the enum they encode

A struct carrying `data: Option<T>` next to `error: Option<E>` (often with a `loading: bool` alongside) is a product type standing in for a sum type — the reflex of languages where "one of several shapes" can only be modeled as nullable fields. Two of its four representable states (`Some`/`Some`, `None`/`None`) are meaningless, and every consumer must decide, without help from the compiler, what to do when both or neither is set. The data is one value in one of a few states: say so with an enum (or plain `Result`), and the nonsense states stop existing.

**Incorrect (four representable states, two of them nonsense):**

```rust
struct FetchOutcome {
    body: Option<Response>,
    error: Option<ApiError>,
    in_flight: bool,
}
```

**Correct (exactly the three states that exist):**

```rust
enum FetchOutcome {
    InFlight,
    Done(Response),
    Failed(ApiError),
}
```

If there are only the two terminal states, don't even define a type — that is `Result<Response, ApiError>`.

Reference: [The Rust Book — Defining an Enum](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html)
