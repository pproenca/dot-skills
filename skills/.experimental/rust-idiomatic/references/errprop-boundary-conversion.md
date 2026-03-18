---
title: Convert Errors at Module Boundaries
impact: CRITICAL
impactDescription: isolates error domains, prevents leaking internal types
tags: errprop, boundary, conversion, from, encapsulation
---

## Convert Errors at Module Boundaries

Convert errors at module boundaries using `From` implementations or `.map_err()`. Internal error types from dependencies should not leak through public APIs. Each module should expose its own error type and convert upstream errors at the boundary.

**Incorrect (leaks reqwest error through public API):**

```rust
pub async fn fetch_model_list(client: &Client) -> Result<Vec<Model>, reqwest::Error> {
    let response = client.get("/models").send().await?;
    let models: Vec<Model> = response.json().await?;
    Ok(models)
}
```

**Correct (converts to domain error at boundary):**

```rust
pub async fn fetch_model_list(client: &Client) -> Result<Vec<Model>, ApiClientError> {
    let response = client.get("/models").send().await
        .map_err(|e| ApiClientError::Connection(ConnectionFailedError { source: e }))?;
    let models: Vec<Model> = response.json().await
        .map_err(|e| ApiClientError::Deserialization(e.to_string()))?;
    Ok(models)
}
```
