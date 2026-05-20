---
title: Minimize and Avoid Restricted Data Inputs
impact: MEDIUM-HIGH
impactDescription: prevents privacy-policy rejection
tags: sec, privacy, restricted-data, inputs
---

## Minimize and Avoid Restricted Data Inputs

Do not request restricted categories — payment card numbers, health records, government IDs, or precise location — in your input schema. Collect the minimum a task needs and take coarse, host-supplied metadata for location rather than raw coordinates. Over-collection is both a safety risk and a documented review-rejection reason, so design schemas defensively from the start.

**Incorrect (collects restricted financial and precise-location fields directly):**

```typescript
const inputSchema = {
  creditCardNumber: z.string(),
  cvv: z.string(),
  exactLatLng: z.tuple([z.number(), z.number()]),
};
```

**Correct (take a tokenized reference and coarse location):**

```typescript
const inputSchema = {
  paymentRef: z.string(),         // tokenized at the payment provider
  city: z.string().optional(),    // precise location via client metadata, not a tool input
};
```

Reference: [App submission guidelines – Apps SDK](https://developers.openai.com/apps-sdk/app-submission-guidelines)
