# Yjs in Next.js 16 with tRPC and shadcn/ui

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Corrects the wrong defaults a capable model has when building Yjs collaborative editing into a Next.js 16 App Router app with tRPC v11 and shadcn/ui, pinned to Yjs 13.6.31. Concentrates on the failures that are silent rather than loud — shared-type choices that discard concurrent edits, Uint8Array updates that vanish across a JSON boundary, undo that reverts other users' work, and controlled inputs that destroy the caret — alongside the deployment and trust-boundary decisions that determine whether the sync loop can run at all.

---

## Table of Contents

1. [Sync Topology & Dependencies](references/_sections.md#1-sync-topology-&-dependencies)
   - 1.1 [Authorize at the room boundary because updates cannot be validated](references/host-authorize-rooms-not-updates.md)
   - 1.2 [Keep room state outside the function instance on Vercel](references/host-vercel-lacks-instance-affinity.md)
   - 1.3 [Pin the Yjs 13 dependency track explicitly](references/host-pin-the-yjs-13-track.md)
   - 1.4 [Run the sync backend outside the Next.js request lifecycle](references/host-route-handlers-cannot-upgrade.md)
   - 1.5 [Treat the reference WebSocket server as a starting point](references/host-websocket-server-is-not-production.md)
   - 1.6 [Use tRPC for authorization and snapshots, not for the sync loop](references/host-trpc-is-not-the-sync-channel.md)
2. [Binary Transport & Persistence](references/_sections.md#2-binary-transport-&-persistence)
   - 2.1 [Broadcast incremental updates rather than whole document state](references/wire-send-updates-not-state.md)
   - 2.2 [Compact stored updates by loading them into a document](references/wire-compaction-needs-a-doc-roundtrip.md)
   - 2.3 [Encode updates as base64 when they travel through JSON](references/wire-base64-not-superjson.md)
   - 2.4 [Rehydrate updates into a Uint8Array before applying](references/wire-rehydrate-to-uint8array.md)
3. [Modeling State in Shared Types](references/_sections.md#3-modeling-state-in-shared-types)
   - 3.1 [Order lists by a sort key instead of moving array entries](references/model-yarray-has-no-move.md)
   - 3.2 [Reserve Y.Text for prose that two people type into together](references/model-ytext-only-for-prose.md)
   - 3.3 [Seed initial content once and record that it happened](references/model-seed-the-document-once.md)
   - 3.4 [Store structured values as nested shared types](references/model-nested-types-not-plain-objects.md)
4. [Doc Lifecycle & React Binding](references/_sections.md#4-doc-lifecycle-&-react-binding)
   - 4.1 [Create the document and provider once per room](references/react-stable-doc-and-provider.md)
   - 4.2 [Keep provider construction behind the client boundary](references/react-keep-yjs-client-only.md)
   - 4.3 [Subscribe to shared types through a cached snapshot](references/react-subscribe-via-usesyncexternalstore.md)
5. [Undo, Snapshots & Offline Load](references/_sections.md#5-undo,-snapshots-&-offline-load)
   - 5.1 [Disable garbage collection on documents you snapshot](references/hist-snapshots-require-gc-disabled.md)
   - 5.2 [Scope undo to local edits with transaction origins](references/hist-scope-undo-by-origin.md)
   - 5.3 [Wait for local persistence before reading or seeding](references/hist-wait-for-indexeddb-sync.md)
6. [Awareness & Cursors](references/_sections.md#6-awareness-&-cursors)
   - 6.1 [Express cursor positions relative to document content](references/pres-relative-positions-for-cursors.md)
   - 6.2 [Keep presence in awareness rather than in the document](references/pres-awareness-is-ephemeral.md)
7. [Editor & Form Integration](references/_sections.md#7-editor-&-form-integration)
   - 7.1 [Avoid driving text inputs from the document on every change](references/ui-do-not-drive-inputs-from-the-doc.md)
   - 7.2 [Wire Tiptap collaboration through its own Yjs binding](references/ui-tiptap-collaboration-wiring.md)

---

## References

1. [https://docs.yjs.dev/api/about-awareness](https://docs.yjs.dev/api/about-awareness)
2. [https://docs.yjs.dev/api/document-updates](https://docs.yjs.dev/api/document-updates)
3. [https://docs.yjs.dev/api/relative-positions](https://docs.yjs.dev/api/relative-positions)
4. [https://docs.yjs.dev/api/shared-types/y.array](https://docs.yjs.dev/api/shared-types/y.array)
5. [https://docs.yjs.dev/api/shared-types/y.text](https://docs.yjs.dev/api/shared-types/y.text)
6. [https://docs.yjs.dev/api/undo-manager](https://docs.yjs.dev/api/undo-manager)
7. [https://docs.yjs.dev/api/y.doc](https://docs.yjs.dev/api/y.doc)
8. [https://docs.yjs.dev/ecosystem/database-provider/y-indexeddb](https://docs.yjs.dev/ecosystem/database-provider/y-indexeddb)
9. [https://docs.yjs.dev/getting-started/working-with-shared-types](https://docs.yjs.dev/getting-started/working-with-shared-types)
10. [https://github.com/cloudflare/partykit](https://github.com/cloudflare/partykit)
11. [https://github.com/yjs/y-protocols/blob/v1.0.7/awareness.js](https://github.com/yjs/y-protocols/blob/v1.0.7/awareness.js)
12. [https://github.com/yjs/y-websocket-server/blob/main/README.md](https://github.com/yjs/y-websocket-server/blob/main/README.md)
13. [https://github.com/yjs/y-websocket/blob/master/README.md](https://github.com/yjs/y-websocket/blob/master/README.md)
14. [https://github.com/yjs/yhub](https://github.com/yjs/yhub)
15. [https://html.spec.whatwg.org/multipage/input.html#dom-input-value](https://html.spec.whatwg.org/multipage/input.html#dom-input-value)
16. [https://liveblocks.io](https://liveblocks.io)
17. [https://nextjs.org/docs/app/getting-started/server-and-client-components](https://nextjs.org/docs/app/getting-started/server-and-client-components)
18. [https://nextjs.org/docs/app/guides/backend-for-frontend](https://nextjs.org/docs/app/guides/backend-for-frontend)
19. [https://react.dev/reference/react/StrictMode](https://react.dev/reference/react/StrictMode)
20. [https://react.dev/reference/react/useSyncExternalStore](https://react.dev/reference/react/useSyncExternalStore)
21. [https://tiptap.dev/docs/collaboration/getting-started/install](https://tiptap.dev/docs/collaboration/getting-started/install)
22. [https://tiptap.dev/docs/editor/extensions/functionality/collaboration](https://tiptap.dev/docs/editor/extensions/functionality/collaboration)
23. [https://tiptap.dev/hocuspocus](https://tiptap.dev/hocuspocus)
24. [https://trpc.io/docs/client/links/httpSubscriptionLink](https://trpc.io/docs/client/links/httpSubscriptionLink)
25. [https://vercel.com/docs/functions/websockets](https://vercel.com/docs/functions/websockets)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |