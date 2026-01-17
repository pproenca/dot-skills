---
title: Mock Stack References in Unit Tests
impact: MEDIUM
impactDescription: enables testing cross-stack dependencies
tags: test, mocking, stack-references, unit
---

## Mock Stack References in Unit Tests

Stack references fetch outputs from other stacks. In unit tests, mock these references to provide predictable test data without requiring actual stacks.

**Incorrect (tests fail without dependent stacks):**

```typescript
// index.ts
const networkStack = new pulumi.StackReference("org/networking/prod");
const vpcId = networkStack.getOutput("vpcId");

const instance = new aws.ec2.Instance("server", {
  subnetId: networkStack.getOutput("privateSubnetIds").apply(ids => ids[0]),
});

// test/index.test.ts
// Test fails: "Stack 'org/networking/prod' not found"
// Cannot test without deploying networking stack first
```

**Correct (mocked stack references):**

```typescript
// test/index.test.ts
import * as pulumi from "@pulumi/pulumi";

pulumi.runtime.setMocks({
  newResource: (args: pulumi.runtime.MockResourceArgs) => {
    // Mock regular resources
    return { id: `${args.name}-id`, state: args.inputs };
  },
  call: (args: pulumi.runtime.MockCallArgs) => {
    // Mock stack reference calls
    if (args.token === "pulumi:pulumi:StackReference") {
      return {
        outputs: {
          vpcId: "vpc-mock-12345",
          privateSubnetIds: ["subnet-mock-1", "subnet-mock-2"],
          publicSubnetIds: ["subnet-mock-3", "subnet-mock-4"],
        },
      };
    }
    return args.inputs;
  },
});

describe("Application Stack", () => {
  it("should create instance in private subnet", async () => {
    const infra = await import("../index");

    const subnetId = await new Promise<string>(resolve =>
      infra.instance.subnetId.apply(resolve)
    );

    expect(subnetId).toBe("subnet-mock-1");
  });
});
```

**Benefits:**
- Tests run without dependent stacks
- Consistent test data across runs
- Fast execution (no API calls)
- Tests document expected stack outputs

Reference: [Unit Testing](https://www.pulumi.com/docs/iac/guides/testing/unit/)
