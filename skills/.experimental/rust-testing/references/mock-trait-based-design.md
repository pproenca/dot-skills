---
title: Design for Testability with Traits
impact: CRITICAL
impactDescription: enables dependency injection and mocking
tags: mock, traits, dependency-injection, testability
---

## Design for Testability with Traits

Define traits for external dependencies and accept them as generic parameters. This enables injecting mock implementations during testing without runtime overhead.

**Incorrect (concrete types, not mockable):**

```rust
// src/service.rs
use reqwest::Client;

pub struct UserService {
    client: Client,
    base_url: String,
}

impl UserService {
    pub fn new(base_url: &str) -> Self {
        Self {
            client: Client::new(),
            base_url: base_url.to_string(),
        }
    }

    pub async fn get_user(&self, id: u64) -> Result<User, Error> {
        // Cannot test without making real HTTP requests
        let response = self.client
            .get(format!("{}/users/{}", self.base_url, id))
            .send()
            .await?;
        response.json().await
    }
}
```

**Correct (trait-based design, mockable):**

```rust
// src/service.rs
#[async_trait]
pub trait HttpClient: Send + Sync {
    async fn get(&self, url: &str) -> Result<String, Error>;
}

pub struct UserService<C: HttpClient> {
    client: C,
    base_url: String,
}

impl<C: HttpClient> UserService<C> {
    pub fn new(client: C, base_url: &str) -> Self {
        Self {
            client,
            base_url: base_url.to_string(),
        }
    }

    pub async fn get_user(&self, id: u64) -> Result<User, Error> {
        let url = format!("{}/users/{}", self.base_url, id);
        let body = self.client.get(&url).await?;
        serde_json::from_str(&body).map_err(Into::into)
    }
}

// Production implementation
pub struct ReqwestClient(reqwest::Client);

#[async_trait]
impl HttpClient for ReqwestClient {
    async fn get(&self, url: &str) -> Result<String, Error> {
        Ok(self.0.get(url).send().await?.text().await?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    struct MockHttpClient {
        response: String,
    }

    #[async_trait]
    impl HttpClient for MockHttpClient {
        async fn get(&self, _url: &str) -> Result<String, Error> {
            Ok(self.response.clone())
        }
    }

    #[tokio::test]
    async fn get_user_parses_response() {
        let mock = MockHttpClient {
            response: r#"{"id": 1, "name": "Alice"}"#.to_string(),
        };
        let service = UserService::new(mock, "http://api");

        let user = service.get_user(1).await.unwrap();
        assert_eq!(user.name, "Alice");
    }
}
```

**Benefits:**
- Zero runtime cost (monomorphization)
- Tests run fast without network calls
- Clear separation between business logic and I/O

Reference: [Rust API Guidelines - Traits](https://rust-lang.github.io/api-guidelines/)
