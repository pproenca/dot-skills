---
title: Send FormData as a native input, not through the experimental upload APIs
tags: mig, formdata, links, uploads
---

## Send FormData as a native input, not through the experimental upload APIs

Asked to accept a file upload, the reflex is to reach for the v10 experimental surface: `experimental_formDataLink` on the client, `experimental_parseMultipartFormData` in the procedure, plus `experimental_isMultipartFormDataRequest`, `experimental_composeUploadHandlers`, `experimental_createMemoryUploadHandler`, and `experimental_contentTypeHandlers` around it. All six were removed in v11 — the feature graduated. `FormData`, `File`, and `Blob` are now ordinary procedure inputs. The first symptom is an import error, and the usual next move is to hand-write a shim reproducing the removed helper rather than to notice that nothing needs replacing.

What still needs configuring is transport, not parsing. `httpBatchLink` serializes to JSON and cannot carry a multipart body, so the routing condition here is the *input*: `isNonJsonSerializable(op.input)` sends uploads down a plain `httpLink` and leaves everything else batched. See `link-route-subscriptions-separately` for the general `splitLink` shape this instantiates.

```ts
// trpc/client.ts
import {
  createTRPCClient,
  httpBatchLink,
  httpLink,
  isNonJsonSerializable,
  splitLink,
} from '@trpc/client';
import type { AppRouter } from '~/server/routers/_app';

const url = '/api/trpc';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => isNonJsonSerializable(op.input),
      true: httpLink({ url }),
      false: httpBatchLink({ url }),
    }),
  ],
});

// server/routers/invoice.ts
import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { publicProcedure, router } from '~/server/trpc';

export const invoiceRouter = router({
  uploadReceipt: publicProcedure
    .input(z.instanceof(FormData))
    .mutation(async ({ input }) => {
      const invoiceId = input.get('invoiceId');
      const receipt = input.get('receipt');
      if (typeof invoiceId !== 'string' || !(receipt instanceof File)) {
        throw new TRPCError({ code: 'BAD_REQUEST' });
      }
      return storeReceipt(invoiceId, receipt);
    }),
});
```

This works on mutations only. Queries are issued as GET and carry no body, so a `FormData` input on a `.query()` has nowhere to travel — model the upload as a mutation even when it reads like a lookup.

Reference: [tRPC — Non-JSON content types](https://trpc.io/docs/server/non-json-content-types)
