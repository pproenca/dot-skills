---
title: Use Transformations for Cross-Cutting Concerns
impact: HIGH
impactDescription: 100% compliance with zero code changes
tags: comp, transformations, cross-cutting, standards
---

## Use Transformations for Cross-Cutting Concerns

Transformations intercept resource creation to apply cross-cutting concerns like tagging, naming conventions, or security defaults. This enforces standards without modifying individual resource definitions.

**Incorrect (manual tagging everywhere):**

```typescript
// Every resource needs manual tagging
const bucket = new aws.s3.Bucket("data", {
  tags: {
    Environment: "production",
    Team: "platform",
    CostCenter: "infrastructure",
    ManagedBy: "pulumi",
  },
});

const instance = new aws.ec2.Instance("server", {
  tags: {
    Environment: "production",
    Team: "platform",
    CostCenter: "infrastructure",
    ManagedBy: "pulumi",
  },
});
// Repeated 100+ times
// Easy to forget or inconsistently apply
```

**Correct (transformation for automatic tagging):**

```typescript
// transformations/tagging.ts
const autoTagTransformation: pulumi.ResourceTransformation = (args) => {
  // Only apply to resources that support tags
  if (args.type.startsWith("aws:") && args.props.tags !== undefined) {
    const defaultTags = {
      Environment: pulumi.getStack(),
      Team: "platform",
      CostCenter: "infrastructure",
      ManagedBy: "pulumi",
    };

    return {
      props: {
        ...args.props,
        tags: { ...defaultTags, ...args.props.tags },
      },
      opts: args.opts,
    };
  }
  return undefined;
};

// Apply transformation at stack level
pulumi.runtime.registerStackTransformation(autoTagTransformation);

// Resources automatically get tags
const bucket = new aws.s3.Bucket("data", {});
const instance = new aws.ec2.Instance("server", {
  instanceType: "t3.micro",
});
// Both have standard tags without explicit definition
```

**Use cases:**
- Automatic resource tagging
- Enforcing encryption defaults
- Adding monitoring/logging configuration
- Applying naming conventions

Reference: [Transformations](https://www.pulumi.com/docs/iac/concepts/resources/options/transformations/)
