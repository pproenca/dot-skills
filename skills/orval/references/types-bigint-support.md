---
title: Enable useBigInt for Large Integer Support
impact: MEDIUM
impactDescription: prevents precision loss for int64 values
tags: types, bigint, int64, precision
---

## Enable useBigInt for Large Integer Support

Enable `useBigInt` when your API uses int64 or uint64 formats. JavaScript's Number type loses precision beyond 2^53; BigInt preserves exact values.

**Incorrect (large integers as number):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // useBigInt not enabled - int64 becomes number
    },
  },
});
```

**Precision loss with large IDs:**
```typescript
interface Transaction {
  id: number;  // int64 in OpenAPI, but number in TS
  amount: number;
}

// API returns id: 9007199254740993
const tx = await getTransaction(id);
console.log(tx.id);  // 9007199254740992 - WRONG! Lost precision
```

**Correct (useBigInt enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      useBigInt: true,
    },
  },
});
```

**BigInt preserves precision:**
```typescript
interface Transaction {
  id: bigint;  // Proper type for int64
  amount: number;
}

const tx = await getTransaction(id);
console.log(tx.id);  // 9007199254740993n - Correct!
```

**Handle BigInt in mutator:**

```typescript
// mutator.ts
export const customInstance = async <T>(config: AxiosRequestConfig): Promise<T> => {
  const response = await axios({
    ...config,
    transformResponse: [(data) => {
      // Parse with BigInt support
      // 16+ digits exceeds Number.MAX_SAFE_INTEGER (9007199254740991)
      return JSON.parse(data, (key, value) => {
        if (typeof value === 'string' && /^\d{16,}$/.test(value)) {
          return BigInt(value);
        }
        return value;
      });
    }],
  });

  return response.data;
};
```

**When NOT to use this pattern:**
- API doesn't use int64/uint64 formats
- All IDs fit within Number.MAX_SAFE_INTEGER

Reference: [Orval useBigInt](https://orval.dev/reference/configuration/output)
