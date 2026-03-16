# Principles

Three essays inform this skill's architectural decisions. Understanding
the *why* behind each principle helps you make better judgement calls
when the rules don't perfectly fit.

---

## "AI Is Forcing Us To Write Good Code" — Steve Krenzel

Krenzel's core insight: AI agents are only as effective as the
environment you place them in. Good code structure isn't optional
polish — it's the constraint system that makes agentic coding work.

### The structure IS the guardrail

> The only guardrails are the ones you set and enforce.

An agent with no constraints will produce unpredictable code. An agent
operating in a well-structured codebase with enforced rules (types,
tests, linting, dependency direction) is funneled toward correct
solutions. The structure removes degrees of freedom until the only
remaining path leads to the right answer.

**For domain-architect**: The layered architecture IS the guardrail.
The architecture spec (harness-spec.yml / dep4swift.json) IS the
enforcement. Once set up, every future agent session is constrained
to produce code that respects domain boundaries and dependency direction.

### Namespaces communicate intent

> `./billing/invoices/compute.ts` communicates much more than
> `./utils/helpers.ts`, even if the code inside is identical.

The file path tells the agent what it's looking at before reading a
single line. Domain-first folder structure means every path carries
context: `Domains/Booking/Repo/ListingRepository.swift` tells you the
domain (booking), the layer (repo), and the role (data access for
listings).

**For domain-architect**: When proposing folder structure, optimize for
path readability. The path alone should answer: what domain? what layer?
what responsibility?

### Small files, full context

> Prefer many small well-scoped files. Agents often summarize or
> truncate large files when they pull them into their working set.

A 50-line file stays fully in the agent's context window. A 500-line
god file gets truncated, and the agent misses critical details. Small,
focused files are both better engineering and better agent UX.

**For domain-architect**: When you find god files (files mixing multiple
layers), the migration plan should extract them into small, single-
responsibility files BEFORE moving them.

### End-to-end types with semantic names

> If the model sees a type like `UserId`, `WorkspaceSlug`, or
> `SignedWebhookPayload`, it can immediately understand what kind of
> thing it is dealing with.

Generic names like `T`, `data`, `result` force the agent to read
surrounding context. Semantic names are self-documenting: `BookingID`
can't be confused with `SitterID` even though both are strings.

**For domain-architect**: When classifying the Types layer, flag raw
primitive usage (`String`, `Int`, `[String: Any]`) that should become
semantic types. This is a restructuring opportunity.

---

## "Parse, Don't Validate" — Alexis King

King's core insight: the difference between validation and parsing is
entirely in whether you preserve the information learned. Parsing
produces structured output; validation just returns "ok" and throws
the knowledge away.

### Parse at the boundary, use typed results everywhere

> A parser is just a function that consumes less-structured input and
> produces more-structured output.

Validation: `func checkBooking(_ data: Data) throws` — returns `Void`,
knowledge discarded. Every downstream function must re-validate or
trust blindly.

Parsing: `func parseBooking(_ data: Data) throws -> Booking` — returns
a well-typed `Booking`. Every downstream function operates on the parsed
type. No re-validation needed.

**For domain-architect**: The Repo layer IS the parsing boundary. Raw
data enters (JSON, database rows, API responses), typed domain objects
exit. Everything above Repo receives already-parsed data. This is the
single most important architectural decision.

### Make illegal states unrepresentable

> Use a data structure that makes illegal states unrepresentable.

Instead of `status: String` (could be anything), use
`status: BookingStatus` (enum with known cases). Instead of `dates: [Date]`
(could be empty), use `dates: DateInterval` (always valid).

**For domain-architect**: When auditing the Types layer, look for:
- Booleans that should be enums (especially pairs of booleans)
- Optionals that are never nil in practice (strengthen the type)
- Strings used as identifiers (create newtype wrappers)
- Arrays that must be non-empty (use `NonEmpty<[T]>` or validate at construction)

### Push the burden of proof upward

> Get your data into the most precise representation you need as
> quickly as you can. Ideally, this should happen at the boundary
> of your system, before any of the data is acted upon.

Don't scatter validation throughout the codebase. Parse once at the
boundary, then trust the types. If you find `guard` statements or
`precondition` checks deep in Service or Runtime code, that's a
smell — the parsing should have happened earlier (in Repo).

**For domain-architect**: During layer classification, flag validation
code (guard statements, assertions, error throws for "impossible" cases)
that appears above the Repo layer. These are candidates for pushing
down to the parsing boundary.

### Avoid shotgun parsing

> Shotgun parsing is a programming antipattern whereby parsing and
> input-validating code is mixed with and spread across processing code.

When validation is scattered, you can never be sure all inputs were
actually validated. Moving validation earlier introduces gaps, and
removing "redundant" checks might break things. The system becomes
fragile and unpredictable.

**For domain-architect**: If you find the same validation repeated in
multiple places (e.g., nil-checking a value that "should never be nil"),
that's shotgun parsing. The fix: parse it once at the boundary, use a
non-optional type downstream.

---

## The serviceRepoWall — Dependency Inversion at Architecture Scale

This is the most counterintuitive invariant and the one most likely to
be questioned. It's formalized in `architecture.als` as an Alloy assertion.

### The invariant

Service **never** compileDependsOn Repo. But Repo data **does** reach
Service at runtime — through Config closures wired by Runtime.

### Why it exists

If Service imports Repo, testing Service requires standing up the entire
infrastructure: API clients, databases, keychain, network monitors.
By inserting Config (interfaces) between Service and Repo (implementations),
every Service test swaps Config clients for test doubles. Zero infrastructure.
Tests run in milliseconds.

### The formal guarantee

Import scanning checks: "Does this Service file import Repo?" → direct edge.

The Alloy model checks: "Is there ANY chain of imports through which a
Service file can transitively reach a Repo file?" → reachability.

This catches the gaming scenario: someone creates a Config file that imports
Repo and re-exports types. Every direct import is "legal." But the Alloy
analyzer finds the transitive path Service → Config → Repo and reports a
`serviceRepoWall` violation.

### How data flows without compile deps

```
Service ──compileDependsOn──→ Config ──compileDependsOn──→ Types
                                ↑ (at runtime)
Runtime ──wires──→ Config closures ←── Repo implementations
```

Config declares: `var fetch: @Sendable (ID) async throws -> Item`
Repo implements: `func fetch(id:) async throws -> Item { apiClient.execute(...) }`
Runtime wires: `client.fetch = { id in try await repo.fetch(id: id) }`

Service calls `client.fetch(id)` — Repo data arrives, but Service never
imported Repo. The compile graph and the data flow graph are different.

---

## How the principles combine

| Principle | Architecture decision |
|-----------|---------------------|
| Structure IS the guardrail (Krenzel) | Architecture spec enforces layers in CI |
| Namespaces communicate (Krenzel) | Domain-first folder structure |
| Small files (Krenzel) | Extract god files before restructuring |
| Semantic types (Krenzel) | Types layer uses `BookingID` not `String` |
| Parse at boundary (King) | Repo is the parsing layer |
| Illegal states unrepresentable (King) | Types layer uses enums and newtypes |
| Push proof upward (King) | All parsing lives in Repo, not Service/Runtime |
| No shotgun parsing (King) | One validation point per data source, in Repo |

Together: **the architecture makes the right thing easy and the wrong
thing hard**. Types encode invariants. Repo enforces them at the boundary.
The forward dependency chain (Types → Config → Repo → Service → Runtime → UI)
ensures each layer only sees what it needs. The architecture spec enforces
it all in CI. Agents operating in this environment are constrained toward
correct code by the structure itself.
