---
title: Use Automation API for Complex Workflows
impact: LOW-MEDIUM
impactDescription: enables programmatic multi-stack orchestration
tags: auto, automation-api, workflows, orchestration
---

## Use Automation API for Complex Workflows

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
