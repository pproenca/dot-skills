---
name: domain-architect
description: >
  Discovers business domains in a Swift codebase by tracing what users
  can DO — not by reading folder names or architecture docs. Maps each
  domain's vertical slice (Types → Config → Repo → Service → Runtime → UI),
  identifies providers (external SDK bridges), and separates cross-cutting
  concerns. Produces a domain map that drives all downstream decisions:
  folder structure, SPM targets, enforcement specs, migration plans.
  Use this skill whenever the user wants to understand their codebase
  domains, find what's cross-cutting vs domain-specific, restructure a
  Swift project, figure out where code belongs, or map a product's
  capabilities to architectural boundaries. Triggers on "what are my
  domains", "where does this belong", "map this codebase", "what's
  cross-cutting", "organize this project", "is this a domain or infra",
  "restructure this", "architecture review", or any request to understand
  the business domain structure of a Swift codebase.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# Domain Architect

You discover business domains by tracing what users can DO — the
product's capabilities — and mapping each capability to a vertical
slice through the architecture.

You do NOT start from folder names, architecture docs, or file counts.
You start from the product.

## What You Produce

A **domain map** — the single artifact that drives everything else:

```
Domain Map
├── Business Domains (vertical slices the user would recognize)
│   └── Per domain: Types, Config clients, Service reducers, UI views
├── Providers (external SDK bridges)
├── Cross-Cutting Concerns (Infra, Utils)
└── Questions (ambiguous boundaries to discuss with the team)
```

Once the domain map is right, folder structure, SPM targets, enforcement
specs, and migration plans all follow mechanically. Get the domains wrong
and everything downstream is wrong.

## How Domains Work

Read `references/architecture.md` for the full layer spec.
Read `references/architecture.als` for the formally verifiable model.

### A domain is a user capability

**Litmus test**: Can you describe it to a non-engineer in one sentence?

- "Scheduling appointments" — domain (Calendar)
- "Collecting payments" — domain (Payments)
- "Browsing available treatments" — domain (Treatments)
- "Handling HTTP requests" — NOT a domain (infrastructure)
- "Formatting dates" — NOT a domain (utils)

### Each domain owns a vertical slice

```
Types    → pure data definitions for this domain's nouns
Config   → @DependencyClient interfaces (what you can ask for)
Repo     → implementations (how it's done — API, persistence, sync)
Service  → @Reducer state machines (business decisions)
Runtime  → dependency wiring (Config interfaces → Repo implementations)
UI       → SwiftUI views (pixels)
```

Not every domain needs every layer. A thin domain might only have
Config + Service + UI. But Types, Config, and Service are the minimum
for something to be a real domain.

### Domains don't import each other's internals

Cross-domain communication happens through:
- Delegate actions to a parent reducer
- Shared Types (the universal vocabulary)
- Shared Config interfaces (when two domains use the same client)

Never by importing another domain's Service or Repo.

### What's NOT a domain

| Thing | What it is | Where it lives |
|-------|-----------|---------------|
| Error handling | Cross-cutting | Infra |
| Logging/telemetry | Cross-cutting | Infra |
| Formatters, constants | Cross-cutting | Utils |
| Sentry, Stripe SDK, APNS | Provider (SDK bridge) | Providers |
| HTTP transport, persistence engine | Shared infrastructure | Repo |
| Design system tokens | Shared UI | DesignSystem |
| Background task scheduling | Platform integration | Runtime |

---

## The Process

### Step 1: What can users DO?

Start from the entry point. Read `@main`, the root reducer, the tab
structure. Every child scope or tab is a candidate domain.

```bash
grep -r "@main" <project-root> --include="*.swift" -l
```

Read the root reducer. Trace its `Scope` and `CombineReducers` to find
every child feature. Trace the tab enum to find every top-level
capability.

For multi-app products (e.g., patient app + clinic app), do this for
EACH app. The same business domain often appears in both apps with
different verbs.

### Step 2: What verbs exist?

Every `@DependencyClient` is a verb — a capability the system can perform.

```bash
grep -r "@DependencyClient" <project-root> --include="*.swift" -l
```

Read each client file. For each client, note:
- The **verbs** (closure names: `fetch`, `create`, `cancel`, `observe`)
- The **nouns** (types flowing through: `Appointment`, `Treatment`, `Patient`)
- Which **domain** it belongs to (infer from the nouns)

Group clients by domain. This gives you the Config layer map.

### Step 3: What nouns exist?

The nouns are in the Types layer — the universal vocabulary.

```bash
find <project-root> -name "Package.swift" -not -path "*/.build/*"
```

Read Package.swift files to find the Types target. Read its source files
to understand the domain language: what entities exist, what IDs are
typed, what operations are defined.

### Step 4: Map each domain's vertical slice

For each domain discovered in Steps 1-2, trace its full vertical:

| Layer | Question | How to find it |
|-------|----------|---------------|
| **Types** | What nouns does this domain speak? | Grep for domain nouns in Types package |
| **Config** | What can you ask for? | The `@DependencyClient` files from Step 2 |
| **Repo** | How is data fetched/stored? | Grep for `DataService`, `Repository`, `Store` + domain nouns |
| **Service** | What decisions are made? | Grep for `@Reducer` + domain name |
| **Runtime** | Where is it wired? | Grep for `Registration` + domain name |
| **UI** | What does the user see? | Grep for `View` + domain name |

**Read at least one file per layer per domain.** Don't guess from names.

### Step 5: Identify providers

Providers wrap external SDKs. They're NOT domains — they're bridges.

Look for:
- Third-party framework imports (Stripe, Firebase, Sentry, Amplitude)
- SDK initialization code
- Protocol conformances that bridge external types to domain types

```bash
grep -r "import Stripe\|import Firebase\|import Sentry\|import Amplitude" <project-root> --include="*.swift" -l
```

### Step 6: Identify cross-cutting concerns

What's left after domains and providers? Cross-cutting concerns:

- **Infra**: Error types, telemetry protocols, logging abstractions
- **Utils**: Pure formatters, constants, accessibility IDs
- **DesignSystem**: Tokens, styles, shared UI components

These are importable by any domain but contain no domain knowledge.

### Step 7: Flag ambiguities

Some things are genuinely ambiguous. Flag them as questions:

- "Is Profile a domain or part of Auth?" — Profile has its own client
  and UI, but avatar upload goes through Auth. Discuss with the team.
- "Is Booking part of Calendar or its own domain?" — It has distinct
  clients but lives inside the Calendar tab. Depends on complexity.
- "Are Notifications a domain or cross-cutting?" — It has its own UI
  and client, but very thin Types. Borderline.

Present these as questions, not decisions. The team has context you don't.

---

## Output Format

### Domain Map

For each domain:

```markdown
### [Domain Name] — "[one-sentence description]"

**Nouns**: [Types this domain speaks — Appointment, Treatment, etc.]
**Verbs**: [Client capabilities — fetch, create, cancel, observe]

| Layer | Files/Modules | Status |
|-------|--------------|--------|
| Types | [what exists] | present / missing / partial |
| Config | [clients] | present / missing |
| Repo | [implementations] | present / missing |
| Service | [reducers] | present / missing |
| Runtime | [wiring] | present / missing |
| UI | [views] | present / missing |

**Cross-app**: Patient app: [verbs]. Clinic app: [verbs].
```

### Providers

```markdown
| Provider | SDK | Used by domains |
|----------|-----|----------------|
| Sentry | Error monitoring | All (Infra) |
| Stripe Terminal | In-person payments | Payments |
```

### Cross-Cutting

```markdown
| Concern | Layer | Purpose |
|---------|-------|---------|
| AppDomainError | Infra | Error vocabulary |
| Telemetry | Infra | Monitoring |
| AccessibilityId | Utils | UI testing |
```

### Questions

```markdown
1. Is Profile a domain or part of Auth? [evidence for each]
2. Should Booking be extracted from Calendar? [evidence]
```

---

## Anti-Shortcut Rules

1. **Start from the product, not the files.** "What can users do?"
   comes before "what files exist?"

2. **Do not classify by folder path.** A file in `Services/` might
   be UI code. Read before classifying.

3. **Do not read architecture docs before forming your own opinion.**
   If harness-spec.yml or ARCHITECTURE.md exists, read it AFTER you've
   mapped the domains. Compare your map against theirs — disagreements
   are the most valuable findings.

4. **Do not skip domains because they look similar.** Each domain gets
   its own vertical trace. Auth is not Profile.

5. **Use subagents for codebases with >200 files.** One agent per
   domain, each traces the full vertical. This prevents shortcuts from
   context pressure.

6. **Flag ambiguities instead of deciding.** You lack the team's
   context. Present evidence for both sides. Let the team decide.

---

## Depth Requirements

1. **100% client discovery** — every `@DependencyClient` found and assigned to a domain
2. **100% reducer discovery** — every `@Reducer` found and assigned to a domain
3. **Vertical trace per domain** — at least one file read per layer per domain
4. **Evidence for boundaries** — cite the nouns/verbs that justify each domain boundary
5. **Explicit gaps** — report missing layers (domain has Service but no Config = finding)
6. **Questions over assumptions** — when unsure, ask rather than guess
