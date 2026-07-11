# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Client/Server Boundary (boundary)

**Description:** Where code and env vars execute in a TanStack Start app. Violations leak secrets into the client bundle or read `undefined` on edge runtimes — the highest-cost failure class because it ships credentials to the browser.

## 2. Server Functions & Routes (serverfn)

**Description:** Correct, current usage of `createServerFn` and server routes — input validation, HTTP method choice, static imports, and the post-rename v1 RC API surface. Server functions are public HTTP endpoints, so wrong defaults here are remotely exploitable.

## 3. Auth & Security (sec)

**Description:** Authorization boundaries, CSRF protection, response caching, session cookies, and account-enumeration behavior for server functions and server routes.

## 4. SSR & Data Loading (ssr)

**Description:** Per-request instance lifetimes, suspense-based query consumption, and deterministic render output. Violations bleed one user's state into another's response or break hydration.

## 5. Type Safety at Boundaries (types)

**Description:** Runtime validation where static types end — external data parsing, exhaustiveness checks, and the audit of compiler escape hatches that linters cannot judge for themselves.

## 6. Compiler Configuration (tscfg)

**Description:** The tsconfig baseline a Start app needs — strictness flags, erasable-syntax enforcement, and the Start-specific exception to generic TypeScript advice on `verbatimModuleSyntax`.
