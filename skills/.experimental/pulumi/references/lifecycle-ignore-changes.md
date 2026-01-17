---
title: Use ignoreChanges for Externally Managed Properties
impact: MEDIUM
impactDescription: prevents drift from external automation
tags: lifecycle, ignore, drift, external
---

## Use ignoreChanges for Externally Managed Properties

Some resource properties are managed by external systems (auto-scaling, deployments, external tools). Use `ignoreChanges` to prevent Pulumi from reverting these changes.

**Incorrect (fighting with auto-scaling):**

```typescript
const asg = new aws.autoscaling.Group("app", {
  desiredCapacity: 2,
  minSize: 1,
  maxSize: 10,
  // Auto-scaling policies adjust desiredCapacity
});

// Next pulumi up resets desiredCapacity to 2
// Auto-scaling increases to 8 for load
// Pulumi resets to 2 → application overwhelmed
```

**Correct (ignoring auto-managed properties):**

```typescript
const asg = new aws.autoscaling.Group("app", {
  desiredCapacity: 2, // Initial value only
  minSize: 1,
  maxSize: 10,
}, {
  ignoreChanges: ["desiredCapacity"], // Let auto-scaling manage
});

// Pulumi manages min/max bounds
// Auto-scaling manages current capacity
// No conflicts
```

**Correct (ECS task definition with external deployment):**

```typescript
const taskDefinition = new aws.ecs.TaskDefinition("app", {
  family: "my-app",
  containerDefinitions: JSON.stringify([{ /* ... */ }]),
});

const service = new aws.ecs.Service("app", {
  taskDefinition: taskDefinition.arn,
  desiredCount: 2,
}, {
  ignoreChanges: [
    "taskDefinition", // CI/CD pipeline deploys new task definitions
    "desiredCount",   // Auto-scaling manages count
  ],
});
```

**When to use ignoreChanges:**
- Auto-scaling managed capacity
- CI/CD managed container images
- External tag management systems
- Properties modified by AWS services (last modified timestamps)
