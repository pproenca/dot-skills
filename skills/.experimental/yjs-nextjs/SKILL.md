---
name: yjs-nextjs
description: Corrects the wrong defaults a capable model has when building Yjs collaborative editing into a Next.js 16 App Router app with tRPC v11 and shadcn/ui — pinned to Yjs 13.6.31. Covers the decisions whose failure mode is silence rather than an error — plain objects in a Y.Map discarding concurrent edits, updates that vanish because a JSON boundary turned a Uint8Array into a number array, undo that reverts a colleague's paragraph, initial content seeded once per client, and carets thrown to the end of a shadcn Input on every remote keystroke. Also covers where the sync loop can actually run, since route handlers cannot upgrade, Vercel Functions have no instance affinity, and tRPC subscriptions are one-way — plus which packages have already moved to the Yjs 14 prerelease track. Use when writing, reviewing, or debugging collaborative editing, presence, offline sync, or CRDT persistence in this stack.
---

# Yjs in Next.js 16, tRPC, and shadcn/ui

Yjs 13.6.31 in an App Router codebase — the decisions collaborative editing forces and how to settle them, written so an agent applies them while writing or reviewing code. Each rule names the wrong default it corrects; there is no rule for things the model already gets right.

Most of these failures are silent. Yjs converges, the editor keeps working, and the data loss surfaces later as "my change reverted" — so the rules below lead with the evidence of the failure, most of it measured directly against Yjs 13.6.31 rather than asserted.

## When to Apply

- Building collaborative editing, presence, or offline sync into a Next.js 16 App Router app
- Choosing shared types for a document model, or reviewing one that loses edits under concurrency
- Deciding where the sync backend runs, or wiring tRPC procedures alongside a Yjs provider
- Persisting `Y.Doc` state to a database, or compacting stored updates
- Binding a Yjs document to React — provider lifecycle, subscriptions, Strict Mode, SSR
- Wiring Tiptap or shadcn/ui form controls to a live document
- Debugging a document that syncs but duplicates, blanks, or reverts content

This skill does **not** cover general Next.js App Router patterns (use the `nextjs` skill), general tRPC usage (`trpc`), or shadcn/ui component conventions (`shadcn`) — only where those intersect with a CRDT.

## Version Pin

Rules target **Yjs 13.6.31** with `y-websocket` 3.0.0, `y-protocols` 1.0.7, and `y-indexeddb` 9.0.12. Yjs is mid-migration to v14 under the `@y/*` scope, and several packages have already moved `latest` or `main` onto that prerelease track — `@y/websocket-server@0.1.5` depends on `yjs@^14.0.0-7`. See [`host-pin-the-yjs-13-track`](references/host-pin-the-yjs-13-track.md) before installing anything.

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Sync Topology & Dependencies | `host-` | Where the sync loop runs, which backend to build on, where the trust boundary sits, which versions are on the v13 track |
| 2 | Binary Transport & Persistence | `wire-` | Moving `Uint8Array` updates across JSON boundaries and into storage |
| 3 | Modeling State in Shared Types | `model-` | Which shared type per field — decides whether concurrent edits merge or destroy each other |
| 4 | Doc Lifecycle & React Binding | `react-` | One document across renders, Strict Mode, subscriptions, the server boundary |
| 5 | Undo, Snapshots & Offline Load | `hist-` | Origin-scoped history, garbage collection, load ordering |
| 6 | Awareness & Cursors | `pres-` | Ephemeral presence and positions that survive concurrent edits |
| 7 | Editor & Form Integration | `ui-` | Tiptap and shadcn/ui form controls against a live document |

## Quick Reference

### 1. Sync Topology & Dependencies

- [`host-route-handlers-cannot-upgrade`](references/host-route-handlers-cannot-upgrade.md) — App Router has no socket-upgrade API; the sync server needs a life independent of a request
- [`host-vercel-lacks-instance-affinity`](references/host-vercel-lacks-instance-affinity.md) — Vercel serves WebSockets but does not pin a room to an instance; in-memory registries split one document in two
- [`host-websocket-server-is-not-production`](references/host-websocket-server-is-not-production.md) — the reference server is a starting point, and `YPERSISTENCE` no longer exists
- [`host-pin-the-yjs-13-track`](references/host-pin-the-yjs-13-track.md) — installing `latest` pulls a Yjs 14 prerelease into a v13 app
- [`host-trpc-is-not-the-sync-channel`](references/host-trpc-is-not-the-sync-channel.md) — SSE is one-way and binary input is POST-only; use tRPC for authorization and snapshots
- [`host-authorize-rooms-not-updates`](references/host-authorize-rooms-not-updates.md) — a CRDT update cannot be schema-validated or permission-checked, so the room is the trust boundary

### 2. Binary Transport & Persistence

- [`wire-rehydrate-to-uint8array`](references/wire-rehydrate-to-uint8array.md) — `applyUpdate` accepts a `number[]` and silently applies nothing
- [`wire-base64-not-superjson`](references/wire-base64-not-superjson.md) — superjson round-trips typed arrays at 3.69x payload; base64 costs 1.33x
- [`wire-send-updates-not-state`](references/wire-send-updates-not-state.md) — 24 bytes of delta versus 5041 bytes of full state for one keystroke
- [`wire-compaction-needs-a-doc-roundtrip`](references/wire-compaction-needs-a-doc-roundtrip.md) — `mergeUpdates` re-encodes but never reclaims deleted content

### 3. Modeling State in Shared Types

- [`model-nested-types-not-plain-objects`](references/model-nested-types-not-plain-objects.md) — a plain object in a `Y.Map` is one conflict unit; concurrent edits to different fields lose one
- [`model-yarray-has-no-move`](references/model-yarray-has-no-move.md) — delete-then-insert duplicates the row when two people drag it at once
- [`model-ytext-only-for-prose`](references/model-ytext-only-for-prose.md) — two people retyping a `Y.Text` title produce both values spliced together
- [`model-seed-the-document-once`](references/model-seed-the-document-once.md) — an emptiness check passes on every client, so the template lands twice

### 4. Doc Lifecycle & React Binding

- [`react-stable-doc-and-provider`](references/react-stable-doc-and-provider.md) — own creation and teardown in one effect, because Strict Mode runs setup, cleanup, setup
- [`react-subscribe-via-usesyncexternalstore`](references/react-subscribe-via-usesyncexternalstore.md) — no official binding exists, and `toJSON()` returns a new reference every call
- [`react-keep-yjs-client-only`](references/react-keep-yjs-client-only.md) — providers need browser globals, and `'use client'` still renders on the server

### 5. Undo, Snapshots & Offline Load

- [`hist-scope-undo-by-origin`](references/hist-scope-undo-by-origin.md) — the default undo manager tracks remote edits and will revert a colleague's work
- [`hist-snapshots-require-gc-disabled`](references/hist-snapshots-require-gc-disabled.md) — decided at construction; restoring a snapshot otherwise throws
- [`hist-wait-for-indexeddb-sync`](references/hist-wait-for-indexeddb-sync.md) — an unloaded document is indistinguishable from an empty one

### 6. Awareness & Cursors

- [`pres-awareness-is-ephemeral`](references/pres-awareness-is-ephemeral.md) — presence in the document is permanent, versioned, and never cleaned up
- [`pres-relative-positions-for-cursors`](references/pres-relative-positions-for-cursors.md) — an index stops meaning the same place as soon as anyone types above it

### 7. Editor & Form Integration

- [`ui-do-not-drive-inputs-from-the-doc`](references/ui-do-not-drive-inputs-from-the-doc.md) — assigning `value` is specified to throw the caret to the end of the field
- [`ui-tiptap-collaboration-wiring`](references/ui-tiptap-collaboration-wiring.md) — Tiptap v3 uses its own fork, and `content` re-seeds on every load

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way, with an incorrect/correct contrast where the wrong way is a real trap.

When debugging rather than writing, start from the symptom:

| Symptom | Read first |
|---------|-----------|
| Document loads blank | [`wire-rehydrate-to-uint8array`](references/wire-rehydrate-to-uint8array.md), [`hist-wait-for-indexeddb-sync`](references/hist-wait-for-indexeddb-sync.md) |
| Content appears twice | [`model-seed-the-document-once`](references/model-seed-the-document-once.md), [`ui-tiptap-collaboration-wiring`](references/ui-tiptap-collaboration-wiring.md) |
| Someone's edit silently reverted | [`model-nested-types-not-plain-objects`](references/model-nested-types-not-plain-objects.md), [`hist-scope-undo-by-origin`](references/hist-scope-undo-by-origin.md) |
| List items duplicate when dragged | [`model-yarray-has-no-move`](references/model-yarray-has-no-move.md) |
| Two editors never see each other | [`host-vercel-lacks-instance-affinity`](references/host-vercel-lacks-instance-affinity.md) |
| A user edited a field they should not reach | [`host-authorize-rooms-not-updates`](references/host-authorize-rooms-not-updates.md) |
| A collaborator's avatar lingers after they leave | [`pres-awareness-is-ephemeral`](references/pres-awareness-is-ephemeral.md) |
| Caret jumps to the end while typing | [`ui-do-not-drive-inputs-from-the-doc`](references/ui-do-not-drive-inputs-from-the-doc.md) |
| Infinite render loop or snapshot error | [`react-subscribe-via-usesyncexternalstore`](references/react-subscribe-via-usesyncexternalstore.md) |
| Works in production, broken in dev | [`react-stable-doc-and-provider`](references/react-stable-doc-and-provider.md) |

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [AGENTS.md](AGENTS.md) | Auto-built table of contents across all rules |
| [metadata.json](metadata.json) | Version and source references |

## Related Skills

- [`nextjs`](../../.curated/nextjs/SKILL.md) — App Router caching, Server Components, and routing outside the CRDT layer
- [`trpc`](../trpc/SKILL.md) — tRPC v11 router, link, and subscription rules in full
- [`shadcn`](../../.curated/shadcn/SKILL.md) — component composition and form patterns this skill builds on
- [`zod`](../../.curated/zod/SKILL.md) — the validators used in the tRPC procedure examples here
