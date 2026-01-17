---
title: Use ComponentResource for Reusable Abstractions
impact: HIGH
impactDescription: enables sharing, consistency, and maintainability
tags: comp, component-resource, abstraction, reusability
---

## Use ComponentResource for Reusable Abstractions

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
