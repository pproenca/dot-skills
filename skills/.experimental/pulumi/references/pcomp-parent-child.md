---
title: Pass Parent Option to Child Resources
impact: HIGH
impactDescription: prevents orphaned resources and enables cascading deletes
tags: pcomp, parent, hierarchy, resource-options
---

## Pass Parent Option to Child Resources

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
