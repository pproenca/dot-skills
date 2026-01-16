---
title: Use Conditional Logic at Resource Level
impact: CRITICAL
impactDescription: prevents graph instability and state drift
tags: graph, conditionals, dynamic, stability
---

## Use Conditional Logic at Resource Level

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

Reference: [Inputs and Outputs](https://www.pulumi.com/docs/iac/concepts/inputs-outputs/)
