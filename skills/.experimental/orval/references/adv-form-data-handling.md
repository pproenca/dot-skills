---
title: Configure Form Data Serialization
impact: LOW
impactDescription: prevents 400 errors from incorrect array serialization in form uploads
tags: adv, formData, upload, multipart
---

## Configure Form Data Serialization

Configure form data handling for file upload and multipart form endpoints. The default serialization may not match your API's expectations for arrays and nested objects.

**Incorrect (default serialization):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // Default formData serialization
    },
  },
});
```

**Arrays serialized incorrectly:**
```typescript
// Sending: { files: [file1, file2], tags: ['a', 'b'] }

// Default sends:
// files=file1&files=file2&tags=a&tags=b

// But API expects:
// files[]=file1&files[]=file2&tags[0]=a&tags[1]=b
```

**Correct (explicit serialization):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        formData: {
          // How to serialize arrays
          array: 'serialize-with-brackets',  // files[]=value
        },
        formUrlEncoded: {
          array: 'explode',  // files[0]=value&files[1]=value
        },
      },
    },
  },
});
```

**Array serialization options:**
- `serialize` - Default: `key=value1&key=value2`
- `serialize-with-brackets` - PHP style: `key[]=value1&key[]=value2`
- `explode` - Indexed: `key[0]=value1&key[1]=value2`

**Per-operation override for file uploads:**

```typescript
export default defineConfig({
  api: {
    output: {
      override: {
        operations: {
          uploadDocuments: {
            formData: {
              array: 'serialize-with-brackets',
            },
          },
        },
      },
    },
  },
});
```

Reference: [Orval formData Options](https://orval.dev/reference/configuration/output)
