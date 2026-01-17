---
title: Use Name Prefix Pattern for Unique Resource Names
impact: HIGH
impactDescription: prevents naming collisions across instances
tags: pcomp, naming, uniqueness, conventions
---

## Use Name Prefix Pattern for Unique Resource Names

Every resource in Pulumi must have a unique logical name. When creating components that may be instantiated multiple times, prefix child resource names with the component name to ensure uniqueness.

**Incorrect (hardcoded child names):**

```typescript
class Database extends pulumi.ComponentResource {
  constructor(name: string, args: DatabaseArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:data:Database", name, {}, opts);

    // Hardcoded name - fails if component instantiated twice
    const instance = new aws.rds.Instance("database", {
      engine: "postgres",
      instanceClass: args.instanceClass,
    }, { parent: this });

    const paramGroup = new aws.rds.ParameterGroup("params", {
      family: "postgres14",
    }, { parent: this });
  }
}

// Second instance fails with "resource 'database' already exists"
const users = new Database("users-db", { instanceClass: "db.t3.micro" });
const orders = new Database("orders-db", { instanceClass: "db.t3.small" });
```

**Correct (prefixed unique names):**

```typescript
class Database extends pulumi.ComponentResource {
  public readonly endpoint: pulumi.Output<string>;

  constructor(name: string, args: DatabaseArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:data:Database", name, {}, opts);

    const paramGroup = new aws.rds.ParameterGroup(`${name}-params`, {
      family: "postgres14",
      parameters: [{ name: "log_statement", value: "all" }],
    }, { parent: this });

    const instance = new aws.rds.Instance(`${name}-instance`, {
      engine: "postgres",
      instanceClass: args.instanceClass,
      parameterGroupName: paramGroup.name,
    }, { parent: this });

    this.endpoint = instance.endpoint;
    this.registerOutputs({ endpoint: this.endpoint });
  }
}

// Both instances create successfully with unique names
const users = new Database("users-db", { instanceClass: "db.t3.micro" });
const orders = new Database("orders-db", { instanceClass: "db.t3.small" });
```
