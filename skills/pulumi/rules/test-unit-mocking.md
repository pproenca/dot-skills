---
title: Use Mocks for Fast Unit Tests
impact: MEDIUM
impactDescription: 60× faster test execution
tags: test, unit, mocking, fast
---

## Use Mocks for Fast Unit Tests

Unit tests with mocks run in milliseconds without cloud API calls. Use `pulumi.runtime.setMocks()` to provide fake resource outputs for testing component logic.

**Incorrect (integration test for unit logic):**

```typescript
// test/infrastructure.test.ts
// Deploys real infrastructure for every test run
describe("VPC Configuration", () => {
  it("should create correct CIDR", async () => {
    const stack = await LocalWorkspace.createOrSelectStack({
      stackName: "test",
      projectName: "test",
      program: async () => { /* actual resources */ },
    });
    await stack.up();
    const outputs = await stack.outputs();
    expect(outputs.cidrBlock.value).toBe("10.0.0.0/16");
    await stack.destroy();
  });
});
// Takes 5+ minutes, costs money, flaky
```

**Correct (mocked unit test):**

```typescript
// test/infrastructure.test.ts
import * as pulumi from "@pulumi/pulumi";

pulumi.runtime.setMocks({
  newResource: (args: pulumi.runtime.MockResourceArgs) => {
    return {
      id: `${args.name}-id`,
      state: {
        ...args.inputs,
        arn: `arn:aws:ec2:us-east-1:123456789:vpc/${args.name}`,
      },
    };
  },
  call: (args: pulumi.runtime.MockCallArgs) => {
    return args.inputs;
  },
});

describe("VPC Configuration", () => {
  it("should create VPC with correct CIDR", async () => {
    const infra = await import("../index");

    const cidr = await new Promise<string>(resolve =>
      infra.vpc.cidrBlock.apply(resolve)
    );
    expect(cidr).toBe("10.0.0.0/16");
  });
});
// Runs in milliseconds, no cloud costs
```

**Benefits:**
- Tests run in CI without cloud credentials
- Fast feedback loop during development
- Isolated testing of component logic

Reference: [Unit Testing](https://www.pulumi.com/docs/iac/guides/testing/unit/)
