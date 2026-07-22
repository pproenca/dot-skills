---
title: Encode updates as base64 when they travel through JSON
tags: wire, superjson, trpc, bandwidth
---

## Encode updates as base64 when they travel through JSON

A tRPC router configured with `superjson` handles `Uint8Array` correctly, so passing updates through untouched looks like the solved case — and it is correct, just expensive. superjson serializes a typed array by spreading it into a JSON array of decimal numbers (`v => [...v]`) and reconstructs it with the right constructor on arrival. Every byte becomes up to four characters of JSON. Measured on an 18,019-byte update from an 18,000-character document, superjson produced 66,522 bytes (3.69x the payload) where base64 produced 24,028 (1.33x). Both round-trip losslessly; one costs nearly three times the bandwidth of the other on the hot path of a collaborative editor.

**Incorrect (correct, but 3.69x the payload):**

```typescript
saveSnapshot: protectedProcedure
  .input(z.object({ briefId: z.string(), update: z.instanceof(Uint8Array) }))
  .mutation(async ({ input }) => {
    await saveBriefSnapshot(input.briefId, input.update)
  })
// wire: {"json":[1,1,202,194,150,135,1,0,4,1,4,98,111,100,121, ...
```

**Correct (base64 string, 1.33x the payload):**

```typescript
saveSnapshot: protectedProcedure
  .input(z.object({ briefId: z.string(), update: z.base64() }))
  .mutation(async ({ input }) => {
    await saveBriefSnapshot(input.briefId, Buffer.from(input.update, 'base64'))
  })
```

```typescript
await trpc.brief.saveSnapshot.mutate({
  briefId,
  update: Buffer.from(Y.encodeStateAsUpdate(doc)).toString('base64'),
})
```

The Yjs documentation names base64 as the intended escape hatch for text protocols: "you can't `JSON.stringify`/`JSON.parse` the data because there is no JSON representation for binary data... If you still need to transform the data into a string, you can use Base64 encoding."

**Alternative (raw bytes, no encoding overhead):** tRPC accepts `Uint8Array` as octet-stream input, but only on POST mutations and only through `httpLink` — `httpBatchLink` and `httpBatchStreamLink` require a `splitLink` to route such calls. Worth the wiring for large snapshot uploads; not worth it for small frequent writes.

Reference: [Yjs — Document Updates](https://docs.yjs.dev/api/document-updates)
