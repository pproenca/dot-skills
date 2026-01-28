---
title: Use Provider suffix for service implementations
impact: MEDIUM
impactDescription: Clear identification of service provider types
tags: name, services, types
---

# Use Provider suffix for service implementations

Types that provide services should use the `Provider` suffix.

## Why This Matters

- Identifies service abstraction
- Clear dependency injection pattern
- Easy to find all providers
- Distinguishes from consumers

**Incorrect (avoid this pattern):**

```rust
// Unclear these are service providers
pub struct Auth { }
pub struct Telemetry { }
pub struct ModelBackend { }
```

**Correct (recommended):**

```rust
/// Provides authentication services.
pub trait AuthProvider: Send + Sync {
    fn authenticate(&self, token: &str) -> Result<User, AuthError>;
    fn refresh_token(&self, token: &str) -> Result<String, AuthError>;
}

pub struct OAuthProvider {
    client: OAuthClient,
}

impl AuthProvider for OAuthProvider {
    // ...
}

/// Provides telemetry/observability services.
pub struct OtelProvider {
    tracer: Tracer,
    meter: Meter,
}

/// Provides model inference services.
pub trait ModelProvider: Send + Sync {
    async fn complete(&self, prompt: &str) -> Result<String, ModelError>;
}

pub struct OpenAIProvider {
    client: OpenAIClient,
}

pub struct OllamaProvider {
    client: OllamaClient,
}
```

## Provider Pattern

```rust
// Application setup
pub struct App {
    auth_provider: Arc<dyn AuthProvider>,
    model_provider: Arc<dyn ModelProvider>,
    otel_provider: OtelProvider,
}

impl App {
    pub fn new(
        auth: impl AuthProvider + 'static,
        model: impl ModelProvider + 'static,
    ) -> Self {
        Self {
            auth_provider: Arc::new(auth),
            model_provider: Arc::new(model),
            otel_provider: OtelProvider::new(),
        }
    }
}
```
