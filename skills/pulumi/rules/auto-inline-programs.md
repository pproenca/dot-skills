---
title: Use Inline Programs for Dynamic Infrastructure
impact: LOW-MEDIUM
impactDescription: enables runtime-generated infrastructure definitions
tags: auto, inline, dynamic, automation-api
---

## Use Inline Programs for Dynamic Infrastructure

Inline programs define infrastructure as functions rather than files. Use them for dynamically generated infrastructure based on runtime inputs like user requests or API responses.

**Incorrect (static programs for dynamic needs):**

```typescript
// Static Pulumi program that requires file changes for each variation
// infrastructure/index.ts
const config = new pulumi.Config();
const instanceCount = config.requireNumber("instanceCount");

for (let i = 0; i < instanceCount; i++) {
  new aws.ec2.Instance(`server-${i}`, { /* ... */ });
}
// Every configuration change requires updating Pulumi.yaml
// Cannot generate infrastructure from API responses
```

**Correct (inline program for dynamic generation):**

```typescript
// api/create-environment.ts
import { LocalWorkspace } from "@pulumi/pulumi/automation";
import * as aws from "@pulumi/aws";

interface EnvironmentRequest {
  name: string;
  instanceType: string;
  instanceCount: number;
}

async function createEnvironment(request: EnvironmentRequest) {
  const stack = await LocalWorkspace.createOrSelectStack({
    stackName: request.name,
    projectName: "dynamic-env",
    // Inline program - infrastructure defined as function
    program: async () => {
      const instances = [];
      for (let i = 0; i < request.instanceCount; i++) {
        instances.push(
          new aws.ec2.Instance(`server-${i}`, {
            instanceType: request.instanceType,
            ami: "ami-0123456789",
            tags: { Environment: request.name },
          })
        );
      }
      return {
        instanceIds: instances.map(i => i.id),
      };
    },
  });

  await stack.setConfig("aws:region", { value: "us-west-2" });
  const result = await stack.up();
  return result.outputs;
}

// Called from REST API, CLI, or other systems
await createEnvironment({ name: "dev-john", instanceType: "t3.micro", instanceCount: 2 });
```

Reference: [Inline Programs](https://www.pulumi.com/docs/iac/automation-api/concepts-terminology/#inline-programs)
