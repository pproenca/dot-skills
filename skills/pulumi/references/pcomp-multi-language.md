---
title: Design Components for Multi-Language Consumption
impact: HIGH
impactDescription: 5× fewer component implementations
tags: comp, multi-language, sdk, package
---

## Design Components for Multi-Language Consumption

Pulumi components can be consumed from any supported language if properly configured. Add a PulumiPlugin.yaml to enable SDK generation for TypeScript, Python, Go, C#, and Java consumers.

**Incorrect (single-language component):**

```typescript
// components/database.ts
// Only usable from TypeScript/JavaScript projects
export class Database extends pulumi.ComponentResource {
  constructor(name: string, args: DatabaseArgs) {
    super("myorg:database:Database", name, {});
    // Implementation
  }
}

// Python team cannot use this component
// Go team cannot use this component
```

**Correct (multi-language component package):**

```typescript
// components/database.ts
export interface DatabaseArgs {
  /** The database engine type */
  engine: pulumi.Input<"postgres" | "mysql">;
  /** Instance size for the database */
  instanceClass: pulumi.Input<string>;
  /** Enable automated backups */
  backupRetentionDays?: pulumi.Input<number>;
}

export class Database extends pulumi.ComponentResource {
  /** The database connection endpoint */
  public readonly endpoint: pulumi.Output<string>;
  /** The database port */
  public readonly port: pulumi.Output<number>;

  constructor(name: string, args: DatabaseArgs, opts?: pulumi.ComponentResourceOptions) {
    super("myorg:database:Database", name, args, opts);
    // Implementation with proper types
    this.registerOutputs({ endpoint: this.endpoint, port: this.port });
  }
}
```

```yaml
# PulumiPlugin.yaml
runtime: nodejs
```

```bash
# Generate SDKs for all languages
pulumi package gen-sdk ./components --out ./sdk
# Produces: sdk/python/, sdk/go/, sdk/dotnet/, sdk/java/
```

**Benefits:**
- Platform team writes in preferred language
- Application teams consume in their language
- Consistent interface across all consumers

Reference: [Multi-Language Components](https://www.pulumi.com/docs/iac/guides/building-extending/components/build-a-component/)
