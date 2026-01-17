---
title: Use Consistent Stack Naming Convention
impact: MEDIUM-HIGH
impactDescription: enables automation and reduces human error
tags: stack, naming, convention, organization
---

## Use Consistent Stack Naming Convention

Consistent stack names enable automation, simplify navigation, and reduce errors. Use a pattern that encodes project, environment, and optionally region.

**Incorrect (inconsistent naming):**

```bash
# Different naming patterns across teams
pulumi stack ls
# NAME                     LAST UPDATE
# prod                     ...
# staging-us-east          ...
# my-app-production        ...
# dev_environment          ...
# BACKEND-PROD             ...
# Automation scripts cannot reliably find stacks
```

**Correct (consistent pattern):**

```bash
# Pattern: {project}/{environment} or {project}/{environment}-{region}
pulumi stack ls
# NAME                     LAST UPDATE
# networking/dev           ...
# networking/staging       ...
# networking/prod          ...
# application/dev          ...
# application/staging      ...
# application/prod-us-east ...
# application/prod-eu-west ...
```

**Correct (in Pulumi.yaml):**

```yaml
# Pulumi.yaml
name: networking  # Project name

# Stack names follow convention automatically
# pulumi stack init dev → networking/dev
# pulumi stack init prod → networking/prod
```

**Correct (automation-friendly):**

```typescript
// scripts/deploy-all.ts
const environments = ["dev", "staging", "prod"];
const projects = ["networking", "data", "application"];

for (const project of projects) {
  for (const env of environments) {
    const stackName = `${org}/${project}/${env}`;
    // Predictable stack names enable automation
    await deployStack(stackName);
  }
}
```

Reference: [Organizing Projects & Stacks](https://www.pulumi.com/docs/iac/using-pulumi/organizing-projects-stacks/)
