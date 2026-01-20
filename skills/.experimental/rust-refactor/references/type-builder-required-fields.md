---
title: Use Typestate Builders for Required Fields
impact: CRITICAL
impactDescription: prevents constructing incomplete objects at compile time
tags: type, builder, typestate, required-fields, constructor
---

## Use Typestate Builders for Required Fields

Use typestate pattern in builders to ensure required fields are set before building. The `build()` method only exists when all required fields are present.

**Incorrect (runtime check for required fields):**

```rust
#[derive(Default)]
struct RequestBuilder {
    url: Option<String>,
    method: Option<String>,
    timeout: Option<u64>,
}

impl RequestBuilder {
    fn url(mut self, url: &str) -> Self {
        self.url = Some(url.to_string());
        self
    }

    fn build(self) -> Result<Request, &'static str> {
        let url = self.url.ok_or("URL is required")?;  // Runtime error
        let method = self.method.ok_or("Method is required")?;
        Ok(Request { url, method, timeout: self.timeout })
    }
}
```

**Correct (compile-time enforcement of required fields):**

```rust
use std::marker::PhantomData;

struct Missing;
struct Present;

struct RequestBuilder<Url, Method> {
    url: Option<String>,
    method: Option<String>,
    timeout: Option<u64>,
    _url: PhantomData<Url>,
    _method: PhantomData<Method>,
}

impl RequestBuilder<Missing, Missing> {
    fn new() -> Self {
        RequestBuilder {
            url: None, method: None, timeout: None,
            _url: PhantomData, _method: PhantomData,
        }
    }
}

impl<Method> RequestBuilder<Missing, Method> {
    fn url(self, url: &str) -> RequestBuilder<Present, Method> {
        RequestBuilder {
            url: Some(url.to_string()), method: self.method, timeout: self.timeout,
            _url: PhantomData, _method: PhantomData,
        }
    }
}

impl<Url> RequestBuilder<Url, Missing> {
    fn method(self, method: &str) -> RequestBuilder<Url, Present> {
        RequestBuilder {
            url: self.url, method: Some(method.to_string()), timeout: self.timeout,
            _url: PhantomData, _method: PhantomData,
        }
    }
}

impl RequestBuilder<Present, Present> {
    fn build(self) -> Request {
        // build() only exists when both URL and Method are Present
        Request {
            url: self.url.unwrap(),
            method: self.method.unwrap(),
            timeout: self.timeout,
        }
    }
}
```

**Alternative:** Use `typed-builder` or `derive_builder` crates for automatic generation.

Reference: [Builder Pattern - Rust Design Patterns](https://rust-unofficial.github.io/patterns/patterns/creational/builder.html)
