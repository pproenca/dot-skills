# Pulumi

**Version 0.1.0**  
Pulumi Community  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring Pulumi infrastructure code. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance and reliability guide for Pulumi infrastructure as code, designed for AI agents and LLMs. Contains 46 rules across 8 categories, prioritized by impact from critical (state management, resource graph optimization) to incremental (automation and CI/CD). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [State Management and Backend](#1-state-management-and-backend) — **CRITICAL**
   - 1.1 [Enable Checkpoint Skipping for Large Production Stacks](#11-enable-checkpoint-skipping-for-large-production-stacks)
   - 1.2 [Import Existing Resources Before Managing](#12-import-existing-resources-before-managing)
   - 1.3 [Keep Stacks Under 500 Resources](#13-keep-stacks-under-500-resources)
   - 1.4 [Use Managed Backend for Production Stacks](#14-use-managed-backend-for-production-stacks)
   - 1.5 [Use State Export/Import for Migrations](#15-use-state-exportimport-for-migrations)
   - 1.6 [Use Targeted Refresh Instead of Full Stack Refresh](#16-use-targeted-refresh-instead-of-full-stack-refresh)
2. [Resource Graph Optimization](#2-resource-graph-optimization) — **CRITICAL**
   - 2.1 [Avoid Side Effects in Apply Functions](#21-avoid-side-effects-in-apply-functions)
   - 2.2 [Minimize Stack Reference Depth](#22-minimize-stack-reference-depth)
   - 2.3 [Structure Resources for Maximum Parallelism](#23-structure-resources-for-maximum-parallelism)
   - 2.4 [Use Conditional Logic at Resource Level](#24-use-conditional-logic-at-resource-level)
   - 2.5 [Use dependsOn Only for External Dependencies](#25-use-dependson-only-for-external-dependencies)
   - 2.6 [Use Outputs to Express True Dependencies](#26-use-outputs-to-express-true-dependencies)
3. [Component Design](#3-component-design) — **HIGH**
   - 3.1 [Design Components for Multi-Language Consumption](#31-design-components-for-multi-language-consumption)
   - 3.2 [Pass Parent Option to Child Resources](#32-pass-parent-option-to-child-resources)
   - 3.3 [Register Component Outputs Explicitly](#33-register-component-outputs-explicitly)
   - 3.4 [Use ComponentResource for Reusable Abstractions](#34-use-componentresource-for-reusable-abstractions)
   - 3.5 [Use Name Prefix Pattern for Unique Resource Names](#35-use-name-prefix-pattern-for-unique-resource-names)
   - 3.6 [Use Transformations for Cross-Cutting Concerns](#36-use-transformations-for-cross-cutting-concerns)
4. [Secrets and Configuration](#4-secrets-and-configuration) — **HIGH**
   - 4.1 [Generate Secrets with Random Provider](#41-generate-secrets-with-random-provider)
   - 4.2 [Isolate Secrets by Environment](#42-isolate-secrets-by-environment)
   - 4.3 [Prevent Secret Leakage in State](#43-prevent-secret-leakage-in-state)
   - 4.4 [Rotate Secrets Provider When Team Members Leave](#44-rotate-secrets-provider-when-team-members-leave)
   - 4.5 [Use External Secret Managers for Production](#45-use-external-secret-managers-for-production)
   - 4.6 [Use Secret Config for Sensitive Values](#46-use-secret-config-for-sensitive-values)
5. [Stack Organization](#5-stack-organization) — **MEDIUM-HIGH**
   - 5.1 [Export Only Required Outputs](#51-export-only-required-outputs)
   - 5.2 [Parameterize Stack References](#52-parameterize-stack-references)
   - 5.3 [Separate Stacks by Deployment Lifecycle](#53-separate-stacks-by-deployment-lifecycle)
   - 5.4 [Use Consistent Stack Naming Convention](#54-use-consistent-stack-naming-convention)
6. [Resource Options and Lifecycle](#6-resource-options-and-lifecycle) — **MEDIUM**
   - 6.1 [Protect Stateful Resources](#61-protect-stateful-resources)
   - 6.2 [Set Custom Timeouts for Long-Running Resources](#62-set-custom-timeouts-for-long-running-resources)
   - 6.3 [Use Aliases for Safe Resource Renaming](#63-use-aliases-for-safe-resource-renaming)
   - 6.4 [Use deleteBeforeReplace for Unique Constraints](#64-use-deletebeforereplace-for-unique-constraints)
   - 6.5 [Use ignoreChanges for Externally Managed Properties](#65-use-ignorechanges-for-externally-managed-properties)
   - 6.6 [Use replaceOnChanges for Immutable Dependencies](#66-use-replaceonchanges-for-immutable-dependencies)
   - 6.7 [Use retainOnDelete for Shared Resources](#67-use-retainondelete-for-shared-resources)
7. [Testing and Validation](#7-testing-and-validation) — **MEDIUM**
   - 7.1 [Assert on Preview Results Before Deployment](#71-assert-on-preview-results-before-deployment)
   - 7.2 [Mock Stack References in Unit Tests](#72-mock-stack-references-in-unit-tests)
   - 7.3 [Use Ephemeral Stacks for Integration Tests](#73-use-ephemeral-stacks-for-integration-tests)
   - 7.4 [Use Mocks for Fast Unit Tests](#74-use-mocks-for-fast-unit-tests)
   - 7.5 [Use Policy as Code for Property Testing](#75-use-policy-as-code-for-property-testing)
8. [Automation and CI/CD](#8-automation-and-cicd) — **LOW-MEDIUM**
   - 8.1 [Enable Drift Detection for Production](#81-enable-drift-detection-for-production)
   - 8.2 [Run Preview in PR Checks](#82-run-preview-in-pr-checks)
   - 8.3 [Use Automation API for Complex Workflows](#83-use-automation-api-for-complex-workflows)
   - 8.4 [Use Inline Programs for Dynamic Infrastructure](#84-use-inline-programs-for-dynamic-infrastructure)
   - 8.5 [Use Pulumi Deployments for GitOps](#85-use-pulumi-deployments-for-gitops)
   - 8.6 [Use Review Stacks for PR Environments](#86-use-review-stacks-for-pr-environments)

---

## 1. State Management and Backend

**Impact: CRITICAL**

State operations run on every preview/update. Poor backend choice or state bloat causes 10-50× slowdowns on large stacks.

### 1.1 Enable Checkpoint Skipping for Large Production Stacks

**Impact: CRITICAL (up to 20× faster deployments)**

Pulumi saves state snapshots at every operation step for fault tolerance. For large stacks (1000+ resources), this creates significant overhead. Use journaling mode or checkpoint skipping for production stacks with proper recovery procedures.

**Incorrect (default checkpointing on large stack):**

```bash
# Every resource operation triggers full state upload
pulumi up
# Stack with 5000 resources takes 40+ minutes
# Most time spent on state persistence, not resource provisioning
```

**Correct (checkpoint skipping with journaling):**

```bash
# Enable journaling for diff-based state updates
export PULUMI_OPTIMIZED_CHECKPOINT_WRITE=true

# For very large stacks with proper recovery procedures
export PULUMI_SKIP_CHECKPOINTS=true
pulumi up
# Same stack completes in 2-5 minutes
```

**When NOT to skip checkpoints:**
- Development or staging environments where recovery is simple
- Stacks with frequent failures requiring mid-operation recovery
- When you lack a backup strategy for state corruption

Reference: [Speeding up Pulumi Operations by up to 20x](https://www.pulumi.com/blog/journaling/)

### 1.2 Import Existing Resources Before Managing

**Impact: CRITICAL (prevents duplicate resource creation)**

When adopting Pulumi for existing infrastructure, import resources into state before defining them in code. Without import, Pulumi creates duplicates.

**Incorrect (defining without import):**

```typescript
// Existing VPC in AWS: vpc-12345678
// Defining in Pulumi without import
const vpc = new aws.ec2.Vpc("existing-vpc", {
  cidrBlock: "10.0.0.0/16",
});
// Pulumi creates NEW vpc-87654321
// Now you have two VPCs, one unmanaged
```

**Correct (import then define):**

```bash
# Step 1: Import existing resource
pulumi import aws:ec2/vpc:Vpc existing-vpc vpc-12345678

# Pulumi outputs code suggestion:
# const existing_vpc = new aws.ec2.Vpc("existing-vpc", {
#     cidrBlock: "10.0.0.0/16",
#     ...
# });
```

```typescript
// Step 2: Add to code (matching import)
const vpc = new aws.ec2.Vpc("existing-vpc", {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  enableDnsSupport: true,
  tags: { Name: "production-vpc" },
});
// Pulumi now manages the existing VPC
```

**Correct (bulk import with JSON):**

```json
// resources.json
{
  "resources": [
    {
      "type": "aws:ec2/vpc:Vpc",
      "name": "main-vpc",
      "id": "vpc-12345678"
    },
    {
      "type": "aws:ec2/subnet:Subnet",
      "name": "public-subnet-1",
      "id": "subnet-11111111"
    },
    {
      "type": "aws:ec2/subnet:Subnet",
      "name": "private-subnet-1",
      "id": "subnet-22222222"
    }
  ]
}
```

```bash
pulumi import --file resources.json
```

Reference: [Importing Infrastructure](https://www.pulumi.com/docs/iac/guides/adopting/import/)

### 1.3 Keep Stacks Under 500 Resources

**Impact: CRITICAL (10-100× faster preview and deployment)**

State operations scale with resource count. Stacks exceeding 500 resources experience exponential slowdown in preview, refresh, and update operations. Split large infrastructure into multiple focused stacks connected via stack references.

**Incorrect (monolithic stack with thousands of resources):**

```typescript
// Single stack managing entire infrastructure
const vpc = new aws.ec2.Vpc("main-vpc", { cidrBlock: "10.0.0.0/16" });

// 200 EC2 instances
for (let i = 0; i < 200; i++) {
  new aws.ec2.Instance(`instance-${i}`, { /* ... */ });
}

// 50 RDS databases
for (let i = 0; i < 50; i++) {
  new aws.rds.Instance(`db-${i}`, { /* ... */ });
}

// 100 Lambda functions, 500 IAM roles, etc.
// Preview takes 20+ minutes, updates take hours
```

**Correct (split into focused stacks):**

```typescript
// networking/index.ts - ~50 resources
const vpc = new aws.ec2.Vpc("main-vpc", { cidrBlock: "10.0.0.0/16" });
export const vpcId = vpc.id;
export const subnetIds = subnets.map(s => s.id);

// compute/index.ts - ~200 resources
const networkStack = new pulumi.StackReference("org/networking/prod");
const vpcId = networkStack.getOutput("vpcId");
// EC2 instances reference networking outputs

// databases/index.ts - ~50 resources
// RDS instances in separate stack with its own lifecycle
```

**Benefits:**
- Preview completes in seconds instead of minutes
- Teams can deploy independently without blocking each other
- Blast radius limited to single domain on failures

Reference: [Organizing Projects & Stacks](https://www.pulumi.com/docs/iac/using-pulumi/organizing-projects-stacks/)

### 1.4 Use Managed Backend for Production Stacks

**Impact: CRITICAL (10-50× faster state operations vs self-managed)**

Pulumi Cloud provides transactional checkpointing, concurrent state locking, and optimized diff-based syncing. Self-managed backends require additional operational overhead and lack these optimizations.

**Incorrect (self-managed S3 backend without optimization):**

```typescript
// Pulumi.yaml
name: production-infrastructure
runtime: nodejs
backend:
  url: s3://my-state-bucket/pulumi-state
// No concurrent locking, full state uploads on every operation
// Team members can corrupt state with simultaneous updates
```

**Correct (Pulumi Cloud with automatic optimization):**

```typescript
// Pulumi.yaml
name: production-infrastructure
runtime: nodejs
// Default backend uses Pulumi Cloud
// Automatic diff-based uploads, concurrent locking, audit history
```

**When NOT to use managed backend:**
- Air-gapped environments with no internet access
- Strict data residency requirements prohibiting external storage
- Organizations with existing state management infrastructure (PostgreSQL backend)

Reference: [State and Backends](https://www.pulumi.com/docs/iac/concepts/state-and-backends/)

### 1.5 Use State Export/Import for Migrations

**Impact: CRITICAL (prevents resource recreation during refactoring)**

When refactoring code structure or moving resources between stacks, use state export/import to preserve resource identity. Without this, Pulumi treats renamed resources as delete-and-create operations.

**Incorrect (renaming resource in code):**

```typescript
// Before: resource has URN ending in "old-bucket"
const bucket = new aws.s3.Bucket("old-bucket", { /* ... */ });

// After: changing name triggers delete + create
const bucket = new aws.s3.Bucket("new-bucket", { /* ... */ });
// Pulumi will DELETE old-bucket and CREATE new-bucket
// All data in the bucket is LOST
```

**Correct (state manipulation for rename):**

```bash
# Step 1: Export current state
pulumi stack export --file state.json

# Step 2: Update URN in state.json
# Change "old-bucket" to "new-bucket" in resource URN

# Step 3: Import modified state
pulumi stack import --file state.json

# Step 4: Update code to match new name
# Now pulumi preview shows no changes
```

**Alternative (using aliases):**

```typescript
const bucket = new aws.s3.Bucket("new-bucket", {
  // ...bucket config
}, {
  aliases: [{ name: "old-bucket" }],
});
// Pulumi recognizes this as the same resource
```

Reference: [Resource Aliases](https://www.pulumi.com/docs/iac/concepts/resources/options/aliases/)

### 1.6 Use Targeted Refresh Instead of Full Stack Refresh

**Impact: CRITICAL (10-100× faster refresh operations)**

Full stack refresh queries every resource's current state from cloud providers. For large stacks, this means thousands of API calls. Target specific resources when you know what changed.

**Incorrect (full stack refresh):**

```bash
# Refreshes all 2000 resources in the stack
pulumi refresh
# Takes 15-30 minutes, makes 2000+ API calls
# Most resources haven't changed
```

**Correct (targeted refresh):**

```bash
# Refresh only the resources that may have drifted
pulumi refresh --target "urn:pulumi:prod::myapp::aws:ec2/instance:Instance::web-server"

# Refresh resources matching a pattern
pulumi refresh --target "**:aws:s3/bucket:Bucket::*"
# Takes seconds, queries only relevant resources
```

**Alternative (skip refresh entirely when safe):**

```bash
# When you know state matches reality
pulumi up --skip-preview
# Useful in CI/CD after successful previous deployment
```

**When to use full refresh:**
- After manual changes in cloud console
- Recovering from failed deployments
- Initial sync after importing existing resources

---

## 2. Resource Graph Optimization

**Impact: CRITICAL**

Dependency chains determine deployment parallelism. Sequential dependencies cascade into multiplicative deployment times.

### 2.1 Avoid Side Effects in Apply Functions

**Impact: CRITICAL (prevents unpredictable behavior and resource leaks)**

Apply functions run during preview and update operations. Side effects like creating resources, writing files, or making API calls inside apply lead to unpredictable behavior and resources not tracked in state.

**Incorrect (creating resources inside apply):**

```typescript
const config = new pulumi.Config();
const clusterName = config.require("clusterName");

const cluster = new aws.eks.Cluster("cluster", { name: clusterName });

cluster.endpoint.apply(endpoint => {
  // WRONG: Resource created inside apply is not tracked
  new aws.ec2.SecurityGroupRule("allow-cluster", {
    securityGroupId: cluster.vpcConfig.clusterSecurityGroupId,
    type: "ingress",
    fromPort: 443,
    toPort: 443,
    cidrBlocks: ["10.0.0.0/8"],
  });
});
// Security group rule exists but isn't in Pulumi state
```

**Correct (resource at top level with output dependencies):**

```typescript
const config = new pulumi.Config();
const clusterName = config.require("clusterName");

const cluster = new aws.eks.Cluster("cluster", { name: clusterName });

// Resource at top level, properly tracked
const allowCluster = new aws.ec2.SecurityGroupRule("allow-cluster", {
  securityGroupId: cluster.vpcConfig.clusterSecurityGroupId,
  type: "ingress",
  fromPort: 443,
  toPort: 443,
  cidrBlocks: ["10.0.0.0/8"],
});
```

**When apply is appropriate:**
- Transforming output values (string manipulation, formatting)
- Logging or debugging during development
- Computing derived values that don't create resources

### 2.2 Minimize Stack Reference Depth

**Impact: CRITICAL (reduces deployment coupling and cascade failures)**

Deep stack reference chains create deployment bottlenecks. Each reference adds latency and failure points. Keep reference depth to 2-3 levels maximum.

**Incorrect (deep reference chain):**

```typescript
// networking/index.ts
export const vpcId = vpc.id;

// security/index.ts
const networkStack = new pulumi.StackReference("org/networking/prod");
export const securityGroupId = sg.id;

// database/index.ts
const securityStack = new pulumi.StackReference("org/security/prod");
export const dbEndpoint = db.endpoint;

// cache/index.ts
const dbStack = new pulumi.StackReference("org/database/prod");
export const cacheEndpoint = cache.endpoint;

// application/index.ts
const cacheStack = new pulumi.StackReference("org/cache/prod");
// 5 stacks deep - any failure blocks entire chain
// Deploying application requires all 4 upstream stacks to be healthy
```

**Correct (shallow reference structure):**

```typescript
// platform/index.ts - shared infrastructure layer
const vpc = new aws.ec2.Vpc("main", { /* ... */ });
const sg = new aws.ec2.SecurityGroup("shared", { vpcId: vpc.id });
const db = new aws.rds.Instance("main", { /* ... */ });
const cache = new aws.elasticache.Cluster("main", { /* ... */ });

export const vpcId = vpc.id;
export const securityGroupId = sg.id;
export const dbEndpoint = db.endpoint;
export const cacheEndpoint = cache.endpoint;

// application/index.ts - single reference to platform
const platform = new pulumi.StackReference("org/platform/prod");

const app = new aws.lambda.Function("api", {
  vpcConfig: {
    subnetIds: platform.getOutput("privateSubnetIds"),
    securityGroupIds: [platform.getOutput("securityGroupId")],
  },
  environment: {
    variables: {
      DB_HOST: platform.getOutput("dbEndpoint"),
      CACHE_HOST: platform.getOutput("cacheEndpoint"),
    },
  },
});
// 2 levels deep - platform changes don't cascade through multiple stacks
```

### 2.3 Structure Resources for Maximum Parallelism

**Impact: CRITICAL (N× faster deployments where N is parallelism factor)**

Pulumi deploys independent resources in parallel. Unnecessary dependencies create sequential bottlenecks. Structure resource graphs wide rather than deep.

**Incorrect (artificial sequential dependencies):**

```typescript
// Each resource waits for the previous one
const bucket1 = new aws.s3.Bucket("bucket-1", {});
const bucket2 = new aws.s3.Bucket("bucket-2", {
  tags: { after: bucket1.id }, // Unnecessary dependency
});
const bucket3 = new aws.s3.Bucket("bucket-3", {
  tags: { after: bucket2.id }, // Unnecessary dependency
});
// Total time: bucket1 + bucket2 + bucket3 = 30 seconds
```

**Correct (independent parallel resources):**

```typescript
// All buckets deploy simultaneously
const buckets = ["logs", "assets", "backups"].map(name =>
  new aws.s3.Bucket(`bucket-${name}`, {
    tags: { purpose: name },
  })
);
// Total time: max(bucket creation) = 10 seconds
```

**Correct (explicit parallelism control):**

```bash
# Increase parallelism for large stacks
pulumi up --parallel 50
# Default is 10, increase for stacks with many independent resources
```

**When sequential is necessary:**
- Database must exist before schema migration
- VPC must exist before subnets
- IAM role must exist before assuming it

### 2.4 Use Conditional Logic at Resource Level

**Impact: CRITICAL (prevents graph instability and state drift)**

Conditionally creating resources based on configuration should happen at resource instantiation, not by wrapping in apply or runtime conditionals. This ensures stable resource graphs across deployments.

**Incorrect (conditional inside apply):**

```typescript
const config = new pulumi.Config();
const enableMonitoring = config.requireBoolean("enableMonitoring");

const instance = new aws.ec2.Instance("server", { /* ... */ });

instance.id.apply(id => {
  if (enableMonitoring) {
    // Resource may or may not exist depending on config
    // Not tracked properly in state
    new aws.cloudwatch.MetricAlarm("cpu-alarm", {
      dimensions: { InstanceId: id },
      // ...
    });
  }
});
```

**Correct (conditional at resource level):**

```typescript
const config = new pulumi.Config();
const enableMonitoring = config.requireBoolean("enableMonitoring");

const instance = new aws.ec2.Instance("server", { /* ... */ });

// Resource created conditionally but properly tracked
const cpuAlarm = enableMonitoring
  ? new aws.cloudwatch.MetricAlarm("cpu-alarm", {
      dimensions: { InstanceId: instance.id },
      metricName: "CPUUtilization",
      namespace: "AWS/EC2",
      comparisonOperator: "GreaterThanThreshold",
      threshold: 80,
      evaluationPeriods: 2,
      period: 300,
      statistic: "Average",
    })
  : undefined;
```

**Correct (using component for conditional groups):**

```typescript
class MonitoredInstance extends pulumi.ComponentResource {
  constructor(name: string, args: MonitoredInstanceArgs, opts?: pulumi.ComponentResourceOptions) {
    super("pkg:index:MonitoredInstance", name, {}, opts);

    this.instance = new aws.ec2.Instance(`${name}-instance`, args.instanceArgs, { parent: this });

    if (args.enableMonitoring) {
      this.alarm = new aws.cloudwatch.MetricAlarm(`${name}-alarm`, {
        dimensions: { InstanceId: this.instance.id },
        // ...
      }, { parent: this });
    }

    this.registerOutputs({});
  }
}
```

### 2.5 Use dependsOn Only for External Dependencies

**Impact: CRITICAL (prevents hidden ordering issues)**

The `dependsOn` option creates explicit ordering when Pulumi cannot infer dependencies from outputs. Overuse creates unnecessary sequential execution. Use it only for external or implicit dependencies.

**Incorrect (redundant dependsOn):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

const subnet = new aws.ec2.Subnet("subnet", {
  vpcId: vpc.id, // Already creates dependency
  cidrBlock: "10.0.1.0/24",
}, {
  dependsOn: [vpc], // Redundant - slows down graph resolution
});
```

**Correct (dependsOn for implicit dependency):**

```typescript
const dbInstance = new aws.rds.Instance("db", {
  engine: "postgres",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
});

// Migration must run after database is ready
// But migration doesn't use any db outputs
const migration = new command.local.Command("migrate", {
  create: "npm run db:migrate",
  environment: {
    DATABASE_URL: dbInstance.endpoint,
  },
}, {
  dependsOn: [dbInstance], // Necessary - ensures db is fully ready
});
```

**Correct (dependsOn for eventual consistency):**

```typescript
const iamRole = new aws.iam.Role("role", { /* ... */ });
const policy = new aws.iam.RolePolicy("policy", {
  role: iamRole.name,
  policy: JSON.stringify({ /* ... */ }),
});

// AWS IAM has eventual consistency - role may not be assumable immediately
const lambda = new aws.lambda.Function("fn", {
  role: iamRole.arn,
  // ...
}, {
  dependsOn: [policy], // Wait for policy attachment to propagate
});
```

### 2.6 Use Outputs to Express True Dependencies

**Impact: CRITICAL (eliminates false dependencies and enables parallelism)**

Pulumi tracks dependencies through Output values. Pass outputs directly to dependent resources instead of using `apply()` to extract values prematurely.

**Incorrect (breaking dependency chain with apply):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

// apply() extracts value but loses dependency tracking
vpc.id.apply(vpcId => {
  // This subnet has no tracked dependency on vpc
  const subnet = new aws.ec2.Subnet("subnet", {
    vpcId: vpcId, // String, not Output - dependency lost
    cidrBlock: "10.0.1.0/24",
  });
});
// Subnet may attempt creation before VPC exists
```

**Correct (preserving Output chain):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

const subnet = new aws.ec2.Subnet("subnet", {
  vpcId: vpc.id, // Output<string> - dependency tracked
  cidrBlock: "10.0.1.0/24",
});
// Pulumi knows subnet depends on vpc
```

**Correct (combining multiple outputs):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const sg = new aws.ec2.SecurityGroup("sg", { vpcId: vpc.id });

const instance = new aws.ec2.Instance("server", {
  subnetId: subnet.id,
  vpcSecurityGroupIds: [sg.id],
  // Dependencies automatically tracked through outputs
});
```

Reference: [Inputs and Outputs](https://www.pulumi.com/docs/iac/concepts/inputs-outputs/)

---

## 3. Component Design

**Impact: HIGH**

Well-designed components enable reuse and enforce standards. Poor abstractions leak complexity and cause maintenance overhead.

### 3.1 Design Components for Multi-Language Consumption

**Impact: HIGH (5× fewer component implementations)**

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

### 3.2 Pass Parent Option to Child Resources

**Impact: HIGH (prevents orphaned resources and enables cascading deletes)**

When creating resources inside a ComponentResource, pass `{ parent: this }` to establish the parent-child relationship. Without this, child resources appear as top-level resources and won't inherit component options.

**Incorrect (missing parent relationship):**

```typescript
class VpcNetwork extends pulumi.ComponentResource {
  constructor(name: string, args: VpcNetworkArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:network:VpcNetwork", name, {}, opts);

    // Resources created without parent
    const vpc = new aws.ec2.Vpc(`${name}-vpc`, {
      cidrBlock: args.cidrBlock,
    }); // No parent - appears as top-level resource

    const subnet = new aws.ec2.Subnet(`${name}-subnet`, {
      vpcId: vpc.id,
      cidrBlock: args.subnetCidr,
    }); // No parent - won't inherit component's protect option
  }
}

// If component has protect: true, children are NOT protected
const network = new VpcNetwork("prod", args, { protect: true });
```

**Correct (proper parent hierarchy):**

```typescript
class VpcNetwork extends pulumi.ComponentResource {
  public readonly vpcId: pulumi.Output<string>;
  public readonly subnetIds: pulumi.Output<string>[];

  constructor(name: string, args: VpcNetworkArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:network:VpcNetwork", name, {}, opts);

    const vpc = new aws.ec2.Vpc(`${name}-vpc`, {
      cidrBlock: args.cidrBlock,
    }, { parent: this }); // Inherits protect, provider, transformations

    const subnets = args.availabilityZones.map((az, i) =>
      new aws.ec2.Subnet(`${name}-subnet-${i}`, {
        vpcId: vpc.id,
        availabilityZone: az,
        cidrBlock: `10.0.${i}.0/24`,
      }, { parent: this })
    );

    this.vpcId = vpc.id;
    this.subnetIds = subnets.map(s => s.id);
    this.registerOutputs({ vpcId: this.vpcId, subnetIds: this.subnetIds });
  }
}
```

**Benefits:**
- Child resources appear nested under component in console
- Options like `protect`, `provider`, `transformations` cascade to children
- Deleting component deletes all children

### 3.3 Register Component Outputs Explicitly

**Impact: HIGH (enables stack outputs and cross-stack references)**

Call `registerOutputs()` at the end of your component constructor to declare which values should be accessible externally. Without this, component outputs may not serialize correctly for stack references.

**Incorrect (missing registerOutputs):**

```typescript
class ApiGateway extends pulumi.ComponentResource {
  public readonly url: pulumi.Output<string>;
  public readonly apiId: pulumi.Output<string>;

  constructor(name: string, args: ApiGatewayArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:api:ApiGateway", name, {}, opts);

    const api = new aws.apigateway.RestApi(`${name}-api`, {
      description: args.description,
    }, { parent: this });

    const deployment = new aws.apigateway.Deployment(`${name}-deployment`, {
      restApi: api.id,
    }, { parent: this });

    this.url = deployment.invokeUrl;
    this.apiId = api.id;
    // Missing registerOutputs - outputs may not work in stack references
  }
}
```

**Correct (explicit output registration):**

```typescript
class ApiGateway extends pulumi.ComponentResource {
  public readonly url: pulumi.Output<string>;
  public readonly apiId: pulumi.Output<string>;

  constructor(name: string, args: ApiGatewayArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:api:ApiGateway", name, {}, opts);

    const api = new aws.apigateway.RestApi(`${name}-api`, {
      description: args.description,
    }, { parent: this });

    const stage = new aws.apigateway.Stage(`${name}-stage`, {
      restApi: api.id,
      stageName: args.stageName ?? "v1",
      deployment: deployment.id,
    }, { parent: this });

    this.url = stage.invokeUrl;
    this.apiId = api.id;

    // Explicitly register outputs for external consumption
    this.registerOutputs({
      url: this.url,
      apiId: this.apiId,
    });
  }
}

// Stack can export component outputs
export const apiUrl = gateway.url;
```

### 3.4 Use ComponentResource for Reusable Abstractions

**Impact: HIGH (enables sharing, consistency, and maintainability)**

ComponentResource groups related resources into a single logical unit with a parent-child hierarchy. This enables reuse across projects, consistent naming, and clean resource organization in the Pulumi console.

**Incorrect (flat resources without abstraction):**

```typescript
// Repeated across multiple projects without consistency
const bucket = new aws.s3.Bucket("website-bucket", {
  website: { indexDocument: "index.html" },
});
const bucketPolicy = new aws.s3.BucketPolicy("website-policy", {
  bucket: bucket.id,
  policy: bucket.arn.apply(arn => JSON.stringify({
    Version: "2012-10-17",
    Statement: [{ /* public read */ }],
  })),
});
const distribution = new aws.cloudfront.Distribution("website-cdn", {
  origins: [{ domainName: bucket.bucketRegionalDomainName }],
  // 50 more lines of CloudFront config
});
```

**Correct (encapsulated component):**

```typescript
class StaticWebsite extends pulumi.ComponentResource {
  public readonly bucketName: pulumi.Output<string>;
  public readonly cdnUrl: pulumi.Output<string>;

  constructor(name: string, args: StaticWebsiteArgs, opts?: pulumi.ComponentResourceOptions) {
    super("acme:web:StaticWebsite", name, {}, opts);

    const bucket = new aws.s3.Bucket(`${name}-bucket`, {
      website: { indexDocument: args.indexDocument ?? "index.html" },
    }, { parent: this });

    const bucketPolicy = new aws.s3.BucketPolicy(`${name}-policy`, {
      bucket: bucket.id,
      policy: this.createPublicReadPolicy(bucket.arn),
    }, { parent: this });

    const distribution = new aws.cloudfront.Distribution(`${name}-cdn`, {
      origins: [{ domainName: bucket.bucketRegionalDomainName }],
      enabled: true,
      defaultRootObject: args.indexDocument ?? "index.html",
      // Standardized CloudFront configuration
    }, { parent: this });

    this.bucketName = bucket.id;
    this.cdnUrl = distribution.domainName;
    this.registerOutputs({ bucketName: this.bucketName, cdnUrl: this.cdnUrl });
  }
}

// Usage across projects
const marketing = new StaticWebsite("marketing", { domain: "marketing.acme.com" });
const docs = new StaticWebsite("docs", { domain: "docs.acme.com" });
```

Reference: [Component Resources](https://www.pulumi.com/docs/iac/concepts/components/)

### 3.5 Use Name Prefix Pattern for Unique Resource Names

**Impact: HIGH (prevents naming collisions across instances)**

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

### 3.6 Use Transformations for Cross-Cutting Concerns

**Impact: HIGH (100% compliance with zero code changes)**

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

---

## 4. Secrets and Configuration

**Impact: HIGH**

Improper secret handling creates security vulnerabilities. Unencrypted secrets in state or logs expose credentials.

### 4.1 Generate Secrets with Random Provider

**Impact: HIGH (eliminates manual secret management)**

Instead of manually creating and storing secrets, use Pulumi's random provider to generate passwords, keys, and other sensitive values. Generated secrets are automatically marked as secret in state.

**Incorrect (manual secret management):**

```bash
# Manual process: generate password externally
openssl rand -base64 32
# Copy output, paste into config
pulumi config set --secret dbPassword "generated-password"
# Repeat for every environment
```

```typescript
const config = new pulumi.Config();
const dbPassword = config.requireSecret("dbPassword");
// Manual rotation requires updating config and redeploying
```

**Correct (generated secrets):**

```typescript
import * as random from "@pulumi/random";

const dbPassword = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
  overrideSpecial: "!#$%&*()-_=+[]{}:?",
});

const database = new aws.rds.Instance("db", {
  username: "admin",
  password: dbPassword.result, // Automatically secret
  // ...
});

// Store in Secrets Manager for application access
const secret = new aws.secretsmanager.Secret("db-password", {});
const secretVersion = new aws.secretsmanager.SecretVersion("db-password-v1", {
  secretId: secret.id,
  secretString: dbPassword.result,
});
```

**Correct (keepers for controlled rotation):**

```typescript
const dbPassword = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
  keepers: {
    // Change this value to trigger password rotation
    rotation: "2024-01-15",
  },
});
// Updating rotation date generates new password
```

Reference: [Random Provider](https://www.pulumi.com/registry/packages/random/)

### 4.2 Isolate Secrets by Environment

**Impact: HIGH (prevents production credential access from development)**

Each environment should have its own secrets with separate access controls. Never share production secrets with development environments.

**Incorrect (shared secrets across environments):**

```yaml
# Pulumi.yaml - same secrets for all stacks
config:
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...

# Pulumi.dev.yaml
config:
  myapp:environment: dev

# Pulumi.prod.yaml
config:
  myapp:environment: prod

# Developers with dev access can see production secrets
# Compromise of dev environment exposes production credentials
```

**Correct (environment-specific secrets):**

```yaml
# Pulumi.dev.yaml
config:
  myapp:environment: dev
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...dev-encrypted...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...dev-encrypted...

# Pulumi.prod.yaml
config:
  myapp:environment: prod
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...prod-encrypted...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...prod-encrypted...
```

**Correct (Pulumi ESC environment isolation):**

```yaml
# environments/dev.yaml
values:
  database:
    fn::open::aws-secrets:
      name: dev/database-credentials
      region: us-west-2

# environments/prod.yaml
imports:
  - base  # Shared non-secret config
values:
  database:
    fn::open::aws-secrets:
      name: prod/database-credentials
      region: us-west-2
      # Different IAM roles control who can access prod secrets
```

```bash
# Developers can only access dev environment
pulumi env open dev  # Works
pulumi env open prod # Access denied (RBAC)
```

Reference: [Pulumi ESC Environments](https://www.pulumi.com/docs/esc/environments/)

### 4.3 Prevent Secret Leakage in State

**Impact: HIGH (prevents credential exposure in checkpoints)**

Pulumi marks outputs as secrets when they derive from secret inputs. However, using apply() to extract secret values can break this tracking. Ensure secrets propagate correctly through transformations.

**Incorrect (secret leakage through apply):**

```typescript
const config = new pulumi.Config();
const apiKey = config.requireSecret("apiKey");

// apply() loses secret marking if not careful
const keyPrefix = apiKey.apply(key => key.substring(0, 4));
// keyPrefix is NOT marked as secret, may appear in state/logs

const functionEnv = {
  API_KEY_PREFIX: keyPrefix, // Leaks partial secret to state
};
```

**Correct (preserving secret marking):**

```typescript
const config = new pulumi.Config();
const apiKey = config.requireSecret("apiKey");

// Use pulumi.secret() to explicitly mark derived values
const keyPrefix = apiKey.apply(key => key.substring(0, 4));
const secretPrefix = pulumi.secret(keyPrefix);

// Or use Output.secret() for transformations
const maskedKey = pulumi.all([apiKey]).apply(([key]) =>
  pulumi.secret(`${key.substring(0, 4)}****`)
);
```

**Correct (secret in resource outputs):**

```typescript
const password = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
});

// RandomPassword.result is automatically secret
const database = new aws.rds.Instance("db", {
  password: password.result, // Stays secret in state
});

// Export as secret
export const dbPassword = pulumi.secret(password.result);
```

Reference: [Secrets](https://www.pulumi.com/docs/iac/concepts/secrets/)

### 4.4 Rotate Secrets Provider When Team Members Leave

**Impact: HIGH (prevents unauthorized access to encrypted config)**

Pulumi encrypts secrets using a secrets provider (Pulumi Cloud, AWS KMS, etc.). When team members with access leave, rotate the provider to re-encrypt all secrets with new keys.

**Incorrect (never rotating secrets provider):**

```bash
# Engineer leaves company but still has access to:
# - Encryption passphrase (if using passphrase provider)
# - AWS KMS key (if using AWS KMS provider)
# - Pulumi Cloud organization secrets

# All secrets encrypted with old keys remain accessible
```

**Correct (rotating secrets provider):**

```bash
# Step 1: Check current secrets provider
pulumi stack --show-secrets-provider
# Output: Current secrets provider: passphrase

# Step 2: Change to new provider (re-encrypts all secrets)
pulumi stack change-secrets-provider "awskms://alias/pulumi-secrets?region=us-west-2"

# Step 3: Verify secrets are re-encrypted
pulumi config
# All secrets now encrypted with new KMS key
```

**Correct (using organization-managed keys):**

```bash
# Use Pulumi Cloud's managed secrets (rotate via org settings)
pulumi stack change-secrets-provider "pulumi"

# Or use customer-managed KMS with key rotation
pulumi stack change-secrets-provider \
  "awskms://arn:aws:kms:us-west-2:123456789:key/abcd-1234?region=us-west-2"
```

**When to rotate:**
- Team member with secrets access leaves organization
- Suspected credential compromise
- Regular rotation schedule (quarterly/annually)
- Compliance requirements

Reference: [Rotating Secret Providers](https://www.pulumi.com/blog/rotating-secret-providers/)

### 4.5 Use External Secret Managers for Production

**Impact: HIGH (eliminates static secrets and enables rotation)**

Static secrets in config files cannot be rotated without redeployment. Use Pulumi ESC or external secret managers like HashiCorp Vault for dynamic secret retrieval and automatic rotation.

**Incorrect (static secrets in config):**

```typescript
const config = new pulumi.Config();
const awsAccessKey = config.requireSecret("awsAccessKey");
const awsSecretKey = config.requireSecret("awsSecretKey");

// Static credentials - cannot rotate without config update
// Leaked credentials require manual rotation
```

**Correct (Pulumi ESC for dynamic secrets):**

```yaml
# environments/production.yaml
values:
  aws:
    login:
      fn::open::aws-login:
        oidc:
          roleArn: arn:aws:iam::123456789:role/pulumi-deploy
          sessionName: pulumi-deploy
  pulumiConfig:
    aws:region: us-west-2
```

```typescript
// Credentials fetched dynamically via OIDC
// No static secrets, automatic token refresh
const bucket = new aws.s3.Bucket("data", {});
```

**Correct (HashiCorp Vault integration):**

```typescript
import * as vault from "@pulumi/vault";

// Fetch dynamic database credentials
const dbCreds = vault.database.getSecretBackendConnection({
  backend: "database",
  name: "postgres",
});

const database = new aws.rds.Instance("db", {
  username: dbCreds.then(c => c.username),
  password: pulumi.secret(dbCreds.then(c => c.password)),
});
// Credentials auto-rotate based on Vault policy
```

**Benefits:**
- No static credentials to leak
- Automatic credential rotation
- Centralized secret audit trail

Reference: [Pulumi ESC](https://www.pulumi.com/docs/esc/)

### 4.6 Use Secret Config for Sensitive Values

**Impact: HIGH (prevents credential exposure in state and logs)**

Use `pulumi config set --secret` to encrypt sensitive configuration values. Secret values are encrypted in the config file and marked as secrets throughout the Pulumi program.

**Incorrect (plaintext secrets in config):**

```bash
# Stores password in plaintext in Pulumi.prod.yaml
pulumi config set dbPassword "super-secret-password"
```

```yaml
# Pulumi.prod.yaml - visible to anyone with repo access
config:
  myapp:dbPassword: super-secret-password
```

**Correct (encrypted secrets):**

```bash
# Encrypts password before storing
pulumi config set --secret dbPassword "super-secret-password"
```

```yaml
# Pulumi.prod.yaml - encrypted, safe to commit
config:
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...encrypted...
```

**Correct (using secret config in code):**

```typescript
const config = new pulumi.Config();

// Use requireSecret to ensure value stays encrypted
const dbPassword = config.requireSecret("dbPassword");

const database = new aws.rds.Instance("db", {
  password: dbPassword, // Automatically marked as secret in state
  // ...
});

// WRONG: getSecret returns plain Output, use requireSecret
const password = config.get("dbPassword"); // Not marked as secret
```

**Note:** Secrets are encrypted in config and state but decrypted during deployment. Avoid logging or exporting secret values.

Reference: [Secrets Handling](https://www.pulumi.com/docs/iac/concepts/secrets/)

---

## 5. Stack Organization

**Impact: MEDIUM-HIGH**

Stack boundaries affect blast radius, deployment speed, and team autonomy. Over-consolidated stacks become deployment bottlenecks.

### 5.1 Export Only Required Outputs

**Impact: MEDIUM-HIGH (reduces coupling and speeds up stack references)**

Stack outputs are the contract between stacks. Exporting unnecessary values creates tight coupling and larger state files. Export only what downstream stacks actually need.

**Incorrect (exporting everything):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const subnets = createSubnets(vpc);
const natGateway = createNatGateway(subnets);
const routeTables = createRouteTables(vpc, natGateway);

// Exporting internal implementation details
export const vpcId = vpc.id;
export const vpcArn = vpc.arn;
export const vpcCidrBlock = vpc.cidrBlock;
export const vpcDefaultSecurityGroupId = vpc.defaultSecurityGroupId;
export const subnetIds = subnets.map(s => s.id);
export const subnetArns = subnets.map(s => s.arn);
export const subnetCidrs = subnets.map(s => s.cidrBlock);
export const natGatewayId = natGateway.id;
export const routeTableIds = routeTables.map(r => r.id);
// Downstream stacks coupled to internal structure
```

**Correct (minimal contract):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const subnets = createSubnets(vpc);

// Export only what consumers need
export const vpcId = vpc.id;
export const publicSubnetIds = subnets.filter(s => s.mapPublicIpOnLaunch).map(s => s.id);
export const privateSubnetIds = subnets.filter(s => !s.mapPublicIpOnLaunch).map(s => s.id);

// Internal implementation (NAT, route tables) stays internal
// Consumers don't need to know about routing details
```

**Benefits:**
- Smaller state transfers for stack references
- Freedom to refactor internal implementation
- Clear interface between infrastructure layers

### 5.2 Parameterize Stack References

**Impact: MEDIUM-HIGH (enables environment promotion without code changes)**

Hardcoded stack reference names prevent environment promotion. Use configuration to specify source stacks, allowing the same code to reference different environments.

**Incorrect (hardcoded stack names):**

```typescript
// Hardcoded to production - cannot test against staging
const networkStack = new pulumi.StackReference("acme/networking/prod");
const vpcId = networkStack.getOutput("vpcId");

// Different code needed for each environment
// staging/index.ts has different stack reference
// Drift between environments is inevitable
```

**Correct (parameterized references):**

```typescript
const config = new pulumi.Config();
const environment = config.require("environment");
const orgName = config.get("orgName") ?? "acme";

// Stack reference constructed from config
const networkStack = new pulumi.StackReference(
  `${orgName}/networking/${environment}`
);
const vpcId = networkStack.getOutput("vpcId");

const dataStack = new pulumi.StackReference(
  `${orgName}/data/${environment}`
);
const dbEndpoint = dataStack.getOutput("dbEndpoint");
```

```yaml
# Pulumi.staging.yaml
config:
  myapp:environment: staging

# Pulumi.prod.yaml
config:
  myapp:environment: prod
```

**Correct (with validation):**

```typescript
const validEnvironments = ["dev", "staging", "prod"];
const environment = config.require("environment");

if (!validEnvironments.includes(environment)) {
  throw new Error(`Invalid environment: ${environment}`);
}

const networkStack = new pulumi.StackReference(
  `acme/networking/${environment}`
);
```

Reference: [Stack References](https://www.pulumi.com/docs/iac/concepts/stacks/#stackreferences)

### 5.3 Separate Stacks by Deployment Lifecycle

**Impact: MEDIUM-HIGH (reduces blast radius and enables independent deployments)**

Resources with different change frequencies should live in separate stacks. Networking changes rarely, applications change frequently. Mixing them creates unnecessary risk and deployment friction.

**Incorrect (everything in one stack):**

```typescript
// infrastructure/index.ts - monolithic stack
// VPC changes yearly
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const subnets = createSubnets(vpc);

// Database changes monthly
const database = new aws.rds.Instance("main", { /* ... */ });

// Application changes daily
const appFunction = new aws.lambda.Function("api", {
  code: new pulumi.asset.FileArchive("./dist"),
  // ...
});

// Deploying app change risks touching VPC and database
// All team members need access to sensitive networking config
```

**Correct (lifecycle-based separation):**

```typescript
// stacks/networking/index.ts - changes rarely
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
export const vpcId = vpc.id;
export const subnetIds = subnets.map(s => s.id);

// stacks/data/index.ts - changes occasionally
const networkStack = new pulumi.StackReference("org/networking/prod");
const database = new aws.rds.Instance("main", {
  dbSubnetGroupName: subnetGroup.name,
});
export const dbEndpoint = database.endpoint;

// stacks/application/index.ts - changes frequently
const dataStack = new pulumi.StackReference("org/data/prod");
const appFunction = new aws.lambda.Function("api", {
  environment: {
    variables: { DB_HOST: dataStack.getOutput("dbEndpoint") },
  },
});
```

**Benefits:**
- Application deploys don't risk networking changes
- Teams can deploy independently
- Smaller stacks = faster previews

### 5.4 Use Consistent Stack Naming Convention

**Impact: MEDIUM-HIGH (enables automation and reduces human error)**

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

---

## 6. Resource Options and Lifecycle

**Impact: MEDIUM**

Resource options control replacement, protection, and deletion behavior. Incorrect options cause data loss or stuck deployments.

### 6.1 Protect Stateful Resources

**Impact: MEDIUM (prevents accidental data loss)**

Resources containing data (databases, storage, encryption keys) should be marked with `protect: true`. This prevents accidental deletion from code changes or `pulumi destroy`.

**Incorrect (unprotected stateful resources):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  instanceClass: "db.t3.large",
  allocatedStorage: 100,
  // No protection - accidentally deleted if removed from code
});

const encryptionKey = new aws.kms.Key("data-key", {
  description: "Encryption key for sensitive data",
  // Deletion destroys all encrypted data permanently
});
```

**Correct (protected stateful resources):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  instanceClass: "db.t3.large",
  allocatedStorage: 100,
}, {
  protect: true, // Cannot be deleted without explicit removal
});

const encryptionKey = new aws.kms.Key("data-key", {
  description: "Encryption key for sensitive data",
  deletionWindowInDays: 30, // AWS-level protection
}, {
  protect: true, // Pulumi-level protection
});

const bucket = new aws.s3.Bucket("data-lake", {
  versioning: { enabled: true },
}, {
  protect: true,
});
```

**To delete a protected resource:**

```bash
# Step 1: Remove protect in code
# Step 2: Run pulumi up to update state
# Step 3: Remove resource from code
# Step 4: Run pulumi up to delete

# Or use --target with explicit confirmation
pulumi destroy --target "urn:pulumi:prod::app::aws:rds/instance:Instance::main"
```

Reference: [Resource Options: protect](https://www.pulumi.com/docs/iac/concepts/resources/options/protect/)

### 6.2 Set Custom Timeouts for Long-Running Resources

**Impact: MEDIUM (prevents premature deployment failures)**

Some resources (RDS, EKS clusters, CloudFront distributions) take longer to create than default timeouts. Set custom timeouts to prevent false failures.

**Incorrect (default timeouts for slow resources):**

```typescript
const cluster = new aws.eks.Cluster("main", {
  name: "production",
  roleArn: eksRole.arn,
  vpcConfig: { subnetIds: subnets.map(s => s.id) },
});
// Default timeout: 30 minutes
// EKS cluster creation can take 20-40 minutes
// Intermittent timeout failures on slow days
```

**Correct (custom timeouts):**

```typescript
const cluster = new aws.eks.Cluster("main", {
  name: "production",
  roleArn: eksRole.arn,
  vpcConfig: { subnetIds: subnets.map(s => s.id) },
}, {
  customTimeouts: {
    create: "60m", // Allow up to 60 minutes for creation
    update: "60m",
    delete: "30m",
  },
});
```

**Correct (RDS with custom timeouts):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  engineVersion: "14.9",
  instanceClass: "db.r5.2xlarge",
  allocatedStorage: 500,
  storageType: "io1",
  iops: 10000,
}, {
  customTimeouts: {
    create: "90m", // Large databases take time to provision
    update: "90m", // Storage modifications are slow
    delete: "60m",
  },
});
```

**Resources that commonly need custom timeouts:**
- AWS EKS Cluster (30-45 minutes)
- AWS RDS Instance (15-60 minutes depending on size)
- AWS CloudFront Distribution (15-30 minutes)
- AWS ElastiCache Cluster (10-20 minutes)
- Azure AKS Cluster (10-20 minutes)
- GCP GKE Cluster (10-15 minutes)

### 6.3 Use Aliases for Safe Resource Renaming

**Impact: MEDIUM (prevents delete-and-recreate on refactoring)**

When renaming resources or moving them between components, use aliases to preserve identity. Without aliases, Pulumi treats renamed resources as new resources and deletes the old ones.

**Incorrect (renaming without alias):**

```typescript
// Before: resource named "old-bucket"
const bucket = new aws.s3.Bucket("old-bucket", {});

// After: renaming to "data-bucket"
const bucket = new aws.s3.Bucket("data-bucket", {});
// Pulumi will DELETE old-bucket and CREATE data-bucket
// All data in old-bucket is LOST
```

**Correct (alias preserves identity):**

```typescript
// Rename with alias pointing to old name
const bucket = new aws.s3.Bucket("data-bucket", {}, {
  aliases: [{ name: "old-bucket" }],
});
// Pulumi recognizes this as the same resource
// No deletion, no data loss
```

**Correct (moving between components):**

```typescript
// Before: bucket in root stack
// URN: urn:pulumi:prod::myapp::aws:s3/bucket:Bucket::data

// After: bucket moved into component
class DataStorage extends pulumi.ComponentResource {
  constructor(name: string) {
    super("acme:storage:DataStorage", name, {});

    const bucket = new aws.s3.Bucket("data", {}, {
      parent: this,
      aliases: [{
        // Alias to old URN before component existed
        name: "data",
        parent: pulumi.rootStackResource,
      }],
    });
  }
}
```

**Correct (multiple aliases during migration):**

```typescript
const bucket = new aws.s3.Bucket("data-bucket-v2", {}, {
  aliases: [
    { name: "data-bucket" },      // Previous name
    { name: "old-bucket" },        // Original name
    { type: "aws:s3/bucket:Bucket", name: "legacy-bucket" }, // Type alias
  ],
});
```

Reference: [Resource Aliases](https://www.pulumi.com/docs/iac/concepts/resources/options/aliases/)

### 6.4 Use deleteBeforeReplace for Unique Constraints

**Impact: MEDIUM (prevents deployment failures from naming conflicts)**

Some resources have globally unique identifiers (DNS names, IAM role names). Default create-before-delete replacement fails when the new resource cannot coexist with the old. Use `deleteBeforeReplace` for these cases.

**Incorrect (default replacement behavior):**

```typescript
const role = new aws.iam.Role("service-role", {
  name: "my-service-role", // Globally unique in AWS account
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
});

// Changing assumeRolePolicy triggers replacement
// Pulumi tries to create new role with same name → FAILS
// Error: EntityAlreadyExists: Role with name my-service-role already exists
```

**Correct (delete-before-replace):**

```typescript
const role = new aws.iam.Role("service-role", {
  name: "my-service-role",
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
}, {
  deleteBeforeReplace: true, // Delete old before creating new
});

// Replacement sequence:
// 1. Delete existing role
// 2. Create new role with same name
// Brief downtime but succeeds
```

**Correct (auto-naming to avoid issue):**

```typescript
const role = new aws.iam.Role("service-role", {
  // No explicit name - Pulumi generates unique name
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
});

// Pulumi names it "service-role-a1b2c3d"
// Replacement creates "service-role-e4f5g6h"
// No naming conflict, no downtime
```

**When to use deleteBeforeReplace:**
- IAM roles/users with explicit names
- Route53 hosted zones
- CloudFront distributions with aliases
- Any resource with unique name constraints

### 6.5 Use ignoreChanges for Externally Managed Properties

**Impact: MEDIUM (prevents drift from external automation)**

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

### 6.6 Use replaceOnChanges for Immutable Dependencies

**Impact: MEDIUM (prevents 100% of inconsistent state issues)**

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

### 6.7 Use retainOnDelete for Shared Resources

**Impact: MEDIUM (prevents orphaned dependencies across stacks)**

Resources referenced by other stacks or external systems should use `retainOnDelete`. This prevents cascading failures when refactoring infrastructure organization.

**Incorrect (hard delete of shared resource):**

```typescript
// networking/index.ts
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
});
export const vpcId = vpc.id;

// Multiple other stacks reference this VPC
// Deleting this stack destroys the VPC
// All dependent resources in other stacks break
```

**Correct (retain shared resources):**

```typescript
// networking/index.ts
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
}, {
  retainOnDelete: true, // VPC remains when stack is destroyed
});

export const vpcId = vpc.id;

// Destroying networking stack:
// - Pulumi removes VPC from state
// - VPC continues to exist in AWS
// - Dependent stacks continue working
```

**Correct (with deletedWith for child resources):**

```typescript
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
}, {
  retainOnDelete: true,
});

// Subnets should be retained along with VPC
const subnet = new aws.ec2.Subnet("shared-subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
}, {
  retainOnDelete: true,
  deletedWith: vpc, // If VPC is somehow deleted, don't call subnet delete API
});
```

**Use cases:**
- VPCs shared across multiple applications
- KMS keys used by multiple services
- S3 buckets with cross-account access
- Resources being migrated to another stack

---

## 7. Testing and Validation

**Impact: MEDIUM**

Testing catches misconfigurations before deployment. Unit tests run in milliseconds while integration tests validate real behavior.

### 7.1 Assert on Preview Results Before Deployment

**Impact: MEDIUM (prevents unintended destructive changes)**

Use Automation API to run previews and assert on planned changes before applying. This catches unexpected modifications in CI/CD pipelines.

**Incorrect (blind deployment):**

```bash
# CI/CD pipeline
pulumi up --yes
# Deploys whatever changes exist
# No validation of change scope
# Accidental destructive changes possible
```

**Correct (preview with assertions):**

```typescript
// scripts/safe-deploy.ts
import { LocalWorkspace } from "@pulumi/pulumi/automation";

async function safeDeploy() {
  const stack = await LocalWorkspace.selectStack({
    stackName: "prod",
    workDir: ".",
  });

  // Run preview first
  const preview = await stack.preview();

  // Assert on changes
  const changes = preview.changeSummary;

  // Fail if any resources will be deleted
  if (changes.delete && changes.delete > 0) {
    throw new Error(
      `Deployment would delete ${changes.delete} resources. ` +
      `Review changes and use --target for intentional deletions.`
    );
  }

  // Fail if too many resources changing
  const totalChanges = (changes.create ?? 0) + (changes.update ?? 0);
  if (totalChanges > 10) {
    throw new Error(
      `Deployment would modify ${totalChanges} resources. ` +
      `Large changes require manual approval.`
    );
  }

  // Safe to proceed
  console.log("Preview passed safety checks, deploying...");
  await stack.up();
}
```

**Correct (require specific change types):**

```typescript
const preview = await stack.preview();

// For a migration, require exactly these changes
const expectedCreates = ["aws:rds/instance:Instance"];
const actualCreates = preview.steps
  .filter(s => s.op === "create")
  .map(s => s.type);

if (!arraysEqual(expectedCreates, actualCreates)) {
  throw new Error(
    `Expected to create: ${expectedCreates.join(", ")}\n` +
    `Actually creating: ${actualCreates.join(", ")}`
  );
}
```

### 7.2 Mock Stack References in Unit Tests

**Impact: MEDIUM (enables testing cross-stack dependencies)**

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

### 7.3 Use Ephemeral Stacks for Integration Tests

**Impact: MEDIUM (100% test isolation with automatic cleanup)**

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

### 7.4 Use Mocks for Fast Unit Tests

**Impact: MEDIUM (60× faster test execution)**

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

### 7.5 Use Policy as Code for Property Testing

**Impact: MEDIUM (100% policy compliance enforcement)**

CrossGuard policies validate resource properties during preview and update. Unlike unit tests, policies run against real values from the cloud provider and enforce invariants across all stacks.

**Incorrect (manual review for compliance):**

```typescript
// Relying on code review to catch issues
const bucket = new aws.s3.Bucket("data", {
  // Reviewer must check: is versioning enabled?
  // Reviewer must check: is encryption configured?
  // Reviewer must check: is public access blocked?
});
// Human error leads to non-compliant resources
```

**Correct (automated policy enforcement):**

```typescript
// policy/index.ts
import * as policy from "@pulumi/policy";

new policy.PolicyPack("aws-security", {
  policies: [
    {
      name: "s3-no-public-read",
      description: "S3 buckets must not allow public read access",
      enforcementLevel: "mandatory",
      validateResource: policy.validateResourceOfType(aws.s3.Bucket, (bucket, args, reportViolation) => {
        if (bucket.acl === "public-read" || bucket.acl === "public-read-write") {
          reportViolation("S3 bucket must not have public read ACL");
        }
      }),
    },
    {
      name: "s3-versioning-enabled",
      description: "S3 buckets must have versioning enabled",
      enforcementLevel: "mandatory",
      validateResource: policy.validateResourceOfType(aws.s3.Bucket, (bucket, args, reportViolation) => {
        if (!bucket.versioning?.enabled) {
          reportViolation("S3 bucket must have versioning enabled");
        }
      }),
    },
  ],
});
```

```bash
# Run with policy pack
pulumi preview --policy-pack ./policy
# Deployment blocked if policies violated
```

Reference: [CrossGuard Policy as Code](https://www.pulumi.com/docs/iac/guides/crossguard/)

---

## 8. Automation and CI/CD

**Impact: LOW-MEDIUM**

Automation API enables programmatic infrastructure management. CI/CD integration ensures consistent, auditable deployments.

### 8.1 Enable Drift Detection for Production

**Impact: LOW-MEDIUM (reduces drift-related incidents by 80%)**

Drift occurs when cloud resources are modified outside of Pulumi. Enable scheduled drift detection to identify and remediate unauthorized changes.

**Incorrect (manual drift checks):**

```bash
# Occasional manual refresh
pulumi refresh
# Only catches drift when someone remembers to run it
# Manual changes accumulate unnoticed
# Deployment failures from unexpected state
```

**Correct (scheduled drift detection):**

```yaml
# .github/workflows/drift-detection.yml
name: Drift Detection
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:  # Manual trigger

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for Drift
        uses: pulumi/actions@v5
        with:
          command: refresh
          stack-name: org/project/prod
          expect-no-changes: true  # Fail if drift detected
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}

      - name: Alert on Drift
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "⚠️ Infrastructure drift detected in production!"
            }
```

**Correct (Pulumi Deployments drift detection):**

```typescript
// Enable via Pulumi Cloud API
const deployment = await pulumiService.createDeployment({
  organization: "my-org",
  project: "my-project",
  stack: "prod",
  operation: "refresh",
  // Schedule for automatic drift detection
  schedule: {
    cron: "0 */6 * * *",
  },
});
```

**Benefits:**
- Early detection of manual changes
- Audit trail of drift events
- Automated remediation option
- Compliance evidence

### 8.2 Run Preview in PR Checks

**Impact: LOW-MEDIUM (prevents 90% of deployment failures)**

Run `pulumi preview` in pull request checks to validate infrastructure changes before merge. This catches syntax errors, type mismatches, and policy violations early.

**Incorrect (preview only at deploy time):**

```yaml
# .github/workflows/deploy.yml
# Preview only runs when deploying to production
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pulumi up --yes
# Broken infrastructure code merged to main
# Production deployment fails
```

**Correct (preview in PR checks):**

```yaml
# .github/workflows/preview.yml
name: Preview Infrastructure
on:
  pull_request:
    branches: [main]
    paths:
      - 'infrastructure/**'
      - 'Pulumi*.yaml'
jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci
        working-directory: infrastructure

      - name: Pulumi Preview
        uses: pulumi/actions@v5
        with:
          command: preview
          stack-name: org/project/staging
          work-dir: infrastructure
          comment-on-pr: true  # Posts preview diff to PR
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Benefits:**
- Syntax errors caught before merge
- Team can review infrastructure changes in PR
- Policy violations block merge
- Preview diff visible in PR comments

Reference: [Pulumi GitHub Actions](https://www.pulumi.com/docs/using-pulumi/continuous-delivery/github-actions/)

### 8.3 Use Automation API for Complex Workflows

**Impact: LOW-MEDIUM (enables programmatic multi-stack orchestration)**

Automation API embeds Pulumi as a library, enabling programmatic control over deployments. Use it for multi-stack orchestration, custom CLIs, and integration with existing systems.

**Incorrect (shell scripts for orchestration):**

```bash
#!/bin/bash
# deploy.sh - brittle shell script orchestration
pulumi stack select networking
pulumi up --yes
NETWORK_OUTPUT=$(pulumi stack output vpcId)

pulumi stack select database
pulumi config set vpcId "$NETWORK_OUTPUT"
pulumi up --yes
DB_OUTPUT=$(pulumi stack output endpoint)

pulumi stack select application
pulumi config set dbEndpoint "$DB_OUTPUT"
pulumi up --yes

# Error handling is complex
# No type safety
# Difficult to test
```

**Correct (Automation API orchestration):**

```typescript
// deploy.ts
import { LocalWorkspace, Stack } from "@pulumi/pulumi/automation";

async function deployInfrastructure() {
  const workspace = await LocalWorkspace.create({ workDir: "." });

  // Deploy networking first
  const networkStack = await Stack.createOrSelect("networking", workspace);
  const networkResult = await networkStack.up();
  const vpcId = networkResult.outputs.vpcId.value;

  // Deploy database with networking outputs
  const dbStack = await Stack.createOrSelect("database", workspace);
  await dbStack.setConfig("vpcId", { value: vpcId });
  const dbResult = await dbStack.up();
  const dbEndpoint = dbResult.outputs.endpoint.value;

  // Deploy application with database outputs
  const appStack = await Stack.createOrSelect("application", workspace);
  await appStack.setConfig("dbEndpoint", { value: dbEndpoint });
  await appStack.up();

  console.log("Deployment complete!");
}

deployInfrastructure().catch(console.error);
```

**Benefits:**
- Type-safe orchestration
- Proper error handling with try/catch
- Testable deployment logic
- Integration with existing Node.js/Python tooling

Reference: [Automation API](https://www.pulumi.com/docs/iac/automation-api/)

### 8.4 Use Inline Programs for Dynamic Infrastructure

**Impact: LOW-MEDIUM (enables runtime-generated infrastructure definitions)**

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

### 8.5 Use Pulumi Deployments for GitOps

**Impact: LOW-MEDIUM (enables managed CI/CD without self-hosted runners)**

Pulumi Deployments provides managed infrastructure for running Pulumi operations. Use it to eliminate self-hosted CI/CD runners and enable click-to-deploy workflows.

**Incorrect (self-managed CI/CD complexity):**

```yaml
# .github/workflows/deploy.yml
# Requires: secrets management, runner maintenance, scaling
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
      - name: Install Pulumi
        run: curl -fsSL https://get.pulumi.com | sh
      - name: Configure AWS
        run: # Complex credential setup
      - name: Deploy
        run: pulumi up --yes
        env:
          # Multiple secrets to manage
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Correct (Pulumi Deployments):**

```yaml
# Pulumi.yaml
name: my-infrastructure
runtime: nodejs
backend:
  url: https://api.pulumi.com

# Configure deployment settings in Pulumi Cloud UI or via API
# No CI/CD configuration needed
```

```typescript
// Trigger deployment via API
import { PulumiService } from "@pulumi/pulumi-service";

const service = new PulumiService();
await service.createDeployment({
  organization: "my-org",
  project: "my-project",
  stack: "prod",
  operation: "update",
  // OIDC authentication - no static credentials
  operationContext: {
    oidc: {
      aws: { roleArn: "arn:aws:iam::123456:role/pulumi-deploy" },
    },
  },
});
```

**Benefits:**
- No CI/CD runners to maintain
- OIDC authentication eliminates static credentials
- Click-to-deploy from Pulumi Cloud console
- Automatic drift detection and remediation

Reference: [Pulumi Deployments](https://www.pulumi.com/docs/deployments/)

### 8.6 Use Review Stacks for PR Environments

**Impact: LOW-MEDIUM (enables testing in isolated environments per PR)**

Create ephemeral stacks for each pull request to test infrastructure changes in isolation. Destroy them when the PR is merged or closed.

**Incorrect (shared staging environment):**

```yaml
# All PRs deploy to same staging environment
name: Deploy PR
on:
  pull_request:
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: pulumi stack select staging && pulumi up --yes
# Multiple PRs overwrite each other
# Testing one PR breaks another
# Difficult to isolate issues
```

**Correct (per-PR review stacks):**

```yaml
# .github/workflows/review-stack.yml
name: Review Stack
on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  manage-stack:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create/Update Review Stack
        if: github.event.action != 'closed'
        uses: pulumi/actions@v5
        with:
          command: up
          stack-name: org/project/pr-${{ github.event.number }}
          work-dir: infrastructure
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}

      - name: Comment Stack URL
        if: github.event.action != 'closed'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '🚀 Review stack deployed: https://app-pr-${{ github.event.number }}.example.com'
            })

      - name: Destroy Review Stack
        if: github.event.action == 'closed'
        uses: pulumi/actions@v5
        with:
          command: destroy
          stack-name: org/project/pr-${{ github.event.number }}
          remove: true  # Also removes the stack
```

**Benefits:**
- Isolated testing environment per PR
- No interference between concurrent PRs
- Automatic cleanup on merge/close
- Reviewers can test actual infrastructure

---

## References

1. [https://www.pulumi.com/docs/](https://www.pulumi.com/docs/)
2. [https://www.pulumi.com/docs/iac/concepts/](https://www.pulumi.com/docs/iac/concepts/)
3. [https://www.pulumi.com/docs/iac/concepts/state-and-backends/](https://www.pulumi.com/docs/iac/concepts/state-and-backends/)
4. [https://www.pulumi.com/docs/iac/concepts/components/](https://www.pulumi.com/docs/iac/concepts/components/)
5. [https://www.pulumi.com/docs/iac/concepts/secrets/](https://www.pulumi.com/docs/iac/concepts/secrets/)
6. [https://www.pulumi.com/docs/iac/automation-api/](https://www.pulumi.com/docs/iac/automation-api/)
7. [https://www.pulumi.com/docs/iac/guides/testing/](https://www.pulumi.com/docs/iac/guides/testing/)
8. [https://www.pulumi.com/blog/amazing-performance/](https://www.pulumi.com/blog/amazing-performance/)
9. [https://www.pulumi.com/blog/journaling/](https://www.pulumi.com/blog/journaling/)