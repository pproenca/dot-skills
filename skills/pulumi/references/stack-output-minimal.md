---
title: Export Only Required Outputs
impact: MEDIUM-HIGH
impactDescription: reduces coupling and speeds up stack references
tags: stack, outputs, exports, coupling
---

## Export Only Required Outputs

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
