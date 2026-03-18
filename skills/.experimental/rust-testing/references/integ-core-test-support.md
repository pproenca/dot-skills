---
title: Use core_test_support for End-to-End Tests
impact: LOW-MEDIUM
impactDescription: reduces integration test boilerplate by 80%
tags: integ, core-test-support, end-to-end, utilities
---

## Use core_test_support for End-to-End Tests

Use the `core_test_support` crate for end-to-end integration tests. It provides `TestCodexBuilder`, `ResponseMock`, SSE helpers, `wait_for_event`, `load_default_config_for_test`, and sandbox skip macros. Building on this shared infrastructure ensures consistent test behavior and reduces duplicated setup code.

**Incorrect (reimplementing test infrastructure per crate):**

```rust
// Custom helpers duplicated across test files
async fn setup_mock_server() -> MockServer { /* ... */ }
async fn create_test_codex(server: &MockServer) -> CodexThread { /* ... */ }
fn build_sse_response(events: Vec<Value>) -> String { /* ... */ }
// 50+ lines of custom infrastructure in each integration test file
```

**Correct (reusing core_test_support utilities):**

```rust
use core_test_support::responses;
use core_test_support::test_codex::TestCodexBuilder;
use core_test_support::wait_for_event;
use core_test_support::load_default_config_for_test;

#[tokio::test]
async fn test_agent_flow() -> anyhow::Result<()> {
    let server = MockServer::start().await;
    let mock = responses::mount_sse_once(&server, /* ... */).await;
    let mut codex = TestCodexBuilder::new().build(&server).await?;
    // All shared infrastructure from core_test_support
    Ok(())
}
```
