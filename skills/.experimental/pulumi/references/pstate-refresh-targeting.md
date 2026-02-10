---
title: Use Targeted Refresh Instead of Full Stack Refresh
impact: CRITICAL
impactDescription: 10-100× faster refresh operations
tags: pstate, refresh, targeting, performance
---

## Use Targeted Refresh Instead of Full Stack Refresh

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

**When to use full refresh:**
- After manual changes in cloud console
- Recovering from failed deployments
- Initial sync after importing existing resources
