---
title: Use Ephemeral Stacks for Integration Tests
impact: MEDIUM
impactDescription: 100% test isolation with automatic cleanup
tags: test, integration, ephemeral, automation-api
---

## Use Ephemeral Stacks for Integration Tests

Integration tests deploy real infrastructure to validate end-to-end behavior. Use Automation API to create ephemeral stacks that are automatically destroyed after tests complete.

**Incorrect (shared test environment):**

```bash
# Tests run against persistent staging environment
pulumi stack select staging
pulumi up
npm test
# Multiple test runs interfere with each other
# Failed tests leave dirty state
# Staging drift from production
```

**Correct (ephemeral test stacks):**

```typescript
// test/integration.test.ts
import { LocalWorkspace } from "@pulumi/pulumi/automation";

describe("API Gateway Integration", () => {
  let stack: Stack;
  let apiUrl: string;

  beforeAll(async () => {
    const stackName = `test-${Date.now()}`;

    stack = await LocalWorkspace.createStack({
      stackName,
      projectName: "api-test",
      program: async () => {
        const api = new ApiGateway("test-api", { /* ... */ });
        return { url: api.url };
      },
    });

    await stack.setConfig("aws:region", { value: "us-west-2" });
    const result = await stack.up();
    apiUrl = result.outputs.url.value;
  }, 300000); // 5 minute timeout for infrastructure

  afterAll(async () => {
    await stack.destroy();
    await stack.workspace.removeStack(stack.name);
  });

  it("should return 200 for health check", async () => {
    const response = await fetch(`${apiUrl}/health`);
    expect(response.status).toBe(200);
  });

  it("should return user data", async () => {
    const response = await fetch(`${apiUrl}/users/1`);
    const data = await response.json();
    expect(data.id).toBe(1);
  });
});
```

**Benefits:**
- Isolated test environment per run
- Automatic cleanup prevents resource leaks
- Tests validate real cloud behavior

Reference: [Integration Testing](https://www.pulumi.com/docs/iac/guides/testing/integration/)
