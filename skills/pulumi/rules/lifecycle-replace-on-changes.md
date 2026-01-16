---
title: Use replaceOnChanges for Immutable Dependencies
impact: MEDIUM
impactDescription: prevents 100% of inconsistent state issues
tags: lifecycle, replace, immutable, dependencies
---

## Use replaceOnChanges for Immutable Dependencies

Some resources depend on values that cannot be updated in-place. Use `replaceOnChanges` to force replacement when these dependencies change, ensuring consistent state.

**Incorrect (in-place update fails silently):**

```typescript
const launchTemplate = new aws.ec2.LaunchTemplate("app", {
  imageId: ami.id,
  instanceType: "t3.medium",
});

const asg = new aws.autoscaling.Group("app", {
  launchTemplate: {
    id: launchTemplate.id,
    version: "$Latest",
  },
  // Changing AMI updates launch template
  // But existing instances keep old AMI
  // New instances get new AMI → inconsistent fleet
});
```

**Correct (replace ASG when AMI changes):**

```typescript
const launchTemplate = new aws.ec2.LaunchTemplate("app", {
  imageId: ami.id,
  instanceType: "t3.medium",
});

const asg = new aws.autoscaling.Group("app", {
  launchTemplate: {
    id: launchTemplate.id,
    version: launchTemplate.latestVersion,
  },
}, {
  replaceOnChanges: ["launchTemplate"], // Replace ASG when template changes
});
// All instances recreated with new AMI
```

**Correct (Lambda layer changes):**

```typescript
const layer = new aws.lambda.LayerVersion("deps", {
  code: new pulumi.asset.FileArchive("./layer.zip"),
  compatibleRuntimes: ["nodejs18.x"],
});

const lambda = new aws.lambda.Function("api", {
  runtime: "nodejs18.x",
  handler: "index.handler",
  code: new pulumi.asset.FileArchive("./dist"),
  layers: [layer.arn],
}, {
  replaceOnChanges: ["layers"], // Replace function when layer changes
});
```

Reference: [replaceOnChanges](https://www.pulumi.com/docs/iac/concepts/options/replaceonchanges/)
