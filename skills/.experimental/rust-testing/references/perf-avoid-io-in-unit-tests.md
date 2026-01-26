---
title: Avoid Real IO in Unit Tests
impact: LOW-MEDIUM
impactDescription: 10-100× faster test execution
tags: perf, io, mocking, unit-tests, speed
---

## Avoid Real IO in Unit Tests

Use in-memory implementations instead of real files, networks, or databases in unit tests. Real IO adds latency and flakiness.

**Incorrect (real file IO in unit tests):**

```rust
#[test]
fn test_parse_config() {
    // Creates real file on disk
    std::fs::write("/tmp/test_config.toml", "[app]\nname = \"test\"").unwrap();

    let config = parse_config("/tmp/test_config.toml").unwrap();

    assert_eq!(config.app.name, "test");
    std::fs::remove_file("/tmp/test_config.toml").unwrap();
}

#[test]
fn test_fetch_user() {
    // Real HTTP request
    let user = fetch_user_from_api("http://localhost:8080/users/1").unwrap();
    assert_eq!(user.name, "Alice");
}
```

**Correct (in-memory implementations):**

```rust
// Abstract over IO
trait ConfigReader {
    fn read(&self, path: &str) -> Result<String, Error>;
}

// Production implementation
struct FileConfigReader;
impl ConfigReader for FileConfigReader {
    fn read(&self, path: &str) -> Result<String, Error> {
        std::fs::read_to_string(path).map_err(Into::into)
    }
}

// Test implementation - no disk IO
struct MockConfigReader {
    content: String,
}
impl ConfigReader for MockConfigReader {
    fn read(&self, _path: &str) -> Result<String, Error> {
        Ok(self.content.clone())
    }
}

#[test]
fn test_parse_config() {
    let reader = MockConfigReader {
        content: "[app]\nname = \"test\"".to_string(),
    };

    let config = parse_config_with_reader(&reader, "any/path").unwrap();
    assert_eq!(config.app.name, "test");
    // No file created, no cleanup needed, runs in microseconds
}
```

**In-memory HTTP testing:**

```rust
// Use wiremock for HTTP mocking
use wiremock::{MockServer, Mock, ResponseTemplate};
use wiremock::matchers::{method, path};

#[tokio::test]
async fn test_fetch_user() {
    let mock_server = MockServer::start().await;

    Mock::given(method("GET"))
        .and(path("/users/1"))
        .respond_with(ResponseTemplate::new(200)
            .set_body_json(json!({"id": 1, "name": "Alice"})))
        .mount(&mock_server)
        .await;

    let client = ApiClient::new(&mock_server.uri());
    let user = client.fetch_user(1).await.unwrap();

    assert_eq!(user.name, "Alice");
}
```

**In-memory database testing:**

```rust
#[test]
fn test_user_repository() {
    // Use SQLite in-memory for tests
    let conn = Connection::open_in_memory().unwrap();
    conn.execute(SCHEMA, []).unwrap();

    let repo = UserRepository::new(conn);
    repo.create(&User { name: "Alice".into() }).unwrap();

    let users = repo.list().unwrap();
    assert_eq!(users.len(), 1);
}
```

**Speed comparison:**

| Test Type | With Real IO | With Mocks |
|-----------|-------------|------------|
| File read | 1-10ms | <0.001ms |
| HTTP request | 50-500ms | <1ms |
| Database query | 5-50ms | <0.1ms |

Reference: [wiremock-rs documentation](https://docs.rs/wiremock)
