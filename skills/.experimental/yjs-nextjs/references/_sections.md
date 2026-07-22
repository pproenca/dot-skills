# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the decisions that come up most often and cost most when wrong go first.

---

## 1. Sync Topology & Dependencies (host)

**Description:** Where the sync loop actually runs in a Next.js deployment, which backend to build on, and which package versions belong to the Yjs 13 track. These decisions are made before any feature code and are the most expensive to reverse — a document model built against a transport that cannot deploy has to be rebuilt, not patched.

## 2. Binary Transport & Persistence (wire)

**Description:** Moving `Uint8Array` updates across the JSON boundary and into storage without silent corruption or wasted bandwidth. Yjs updates are binary; every layer of this stack — tRPC, `superjson`, JSON route handlers — is text-oriented, and the failure mode is usually silence rather than an error.

## 3. Modeling State in Shared Types (model)

**Description:** Choosing the shared type for each field. This is what decides whether concurrent edits merge correctly or silently destroy each other — the wrong type produces a document that syncs perfectly and still loses data.

## 4. Doc Lifecycle & React Binding (react)

**Description:** Keeping one `Y.Doc` alive across renders, surviving Strict Mode's double effect, and subscribing components to shared types without violating React's snapshot contract. Yjs ships no official React binding, so every one of these decisions is the application's to make.

## 5. Undo, Snapshots & Offline Load (hist)

**Description:** History that respects document ownership and load ordering that does not corrupt content. Undo scope is controlled by transaction origins rather than by locality, so the defaults do the wrong thing in a multi-user document.

## 6. Awareness & Cursors (pres)

**Description:** Presence state and positions that survive concurrent editing. Awareness lives outside the document with its own lifecycle and expiry, and positions expressed as integers stop meaning what they meant as soon as anyone else types.

## 7. Editor & Form Integration (ui)

**Description:** Wiring shadcn/ui form controls and Tiptap editors to a live CRDT. React's controlled-input idiom and a collaborative document are in direct conflict, and resolving it the obvious way destroys the user's caret.
