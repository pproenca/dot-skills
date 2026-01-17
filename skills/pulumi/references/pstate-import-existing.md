---
title: Import Existing Resources Before Managing
impact: CRITICAL
impactDescription: prevents duplicate resource creation
tags: pstate, import, existing, migration
---

## Import Existing Resources Before Managing

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
