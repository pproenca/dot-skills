---
title: Rotate Secrets Provider When Team Members Leave
impact: HIGH
impactDescription: prevents unauthorized access to encrypted config
tags: secrets, rotation, provider, security
---

## Rotate Secrets Provider When Team Members Leave

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
