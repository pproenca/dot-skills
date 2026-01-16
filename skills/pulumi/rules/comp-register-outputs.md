---
title: Register Component Outputs Explicitly
impact: HIGH
impactDescription: enables stack outputs and cross-stack references
tags: comp, outputs, register, exports
---

## Register Component Outputs Explicitly

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
