---
title: Use Client suffix for API clients
impact: HIGH
impactDescription: Clear identification of types that make external API calls
tags: name, api, client
---

# Use Client suffix for API clients

Types that make external API calls should use the `Client` suffix.

## Why This Matters

- Immediately identifies network I/O types
- Clear dependency on external services
- Easy to mock in tests
- Consistent pattern across codebase

**Incorrect (avoid this pattern):**

```rust
// Unclear these make network calls
pub struct Api { }
pub struct Backend { }
pub struct Service { }
pub struct Gateway { }
```

**Correct (recommended):**

```rust
/// HTTP client for the Codex backend API.
pub struct BackendClient {
    http: reqwest::Client,
    base_url: String,
    auth_token: String,
}

impl BackendClient {
    pub fn new(base_url: &str, auth_token: &str) -> Self { }

    pub async fn get_user(&self, id: &str) -> Result<User, ApiError> { }
    pub async fn create_task(&self, task: &Task) -> Result<TaskId, ApiError> { }
}

/// Client for OpenAI API.
pub struct OpenAIClient {
    api_key: String,
    http: reqwest::Client,
}

/// Client for GitHub API.
pub struct GitHubClient {
    token: String,
    http: reqwest::Client,
}

/// MCP (Model Context Protocol) client.
pub struct McpClient {
    transport: Transport,
}
```

## Client Trait Pattern

```rust
#[async_trait
pub trait ApiClient: Send + Sync {
    async fn request<T: DeserializeOwned>(
        &self,
        endpoint: &str,
        method: Method,
        body: Option<impl Serialize>,
    ) -> Result<T, ApiError>;
}

impl ApiClient for BackendClient {
    // ...
}
```

## Testing with Clients

```rust
#[cfg(test)
mod tests {
    struct MockClient { }

    impl ApiClient for MockClient {
        async fn request<T>(&self, ...) -> Result<T, ApiError> {
            // Return mock data
        }
    }
}
```
