# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
architectural mistakes with the widest blast radius (and the biggest refactor
payoff) go first.

This is an adversarial review/refactor skill for correctness and architecture,
not a performance skill, so there are no impact tiers. Each rule names an alien
mental model — imported from OO/enterprise, garbage-collected, or
exception-based ecosystems — and the refactor that collapses it back to
idiomatic Rust. Every rule is grounded in the codex-rs workspace
(github.com/openai/codex, `codex-rs/` at commit `f1affbac5e`, ~125 crates):
the Correct side is what that production codebase actually does, the
enforcement evidence is its workspace lint config, and the carve-outs are the
real exceptions it keeps.

---

## 1. Enterprise Ceremony & Fake OO (arch)

**Description:** Whole structures ported from Java/C# codebases that have no reason to exist in Rust. Dependency-injection traits defined for a single implementation, `Deref` abuse to simulate inheritance, stateless `*Manager`/`*Service` structs wrapping what should be free functions, getter/setter boilerplate on plain data, and a builder for every struct. codex-rs keeps `ModelClient`, `AuthManager`, and `Session` concrete, writes stateless operations as module functions (`git-utils`, `apply-patch`), gives `Config` and every protocol type plain `pub` fields, and uses struct literals with `..Default::default()` 1,787 times against 16 builder structs. Delete the layer.

## 2. Ownership Fought, Not Used (own)

**Description:** Code that treats the borrow checker as an adversary instead of a design tool. `.clone()` sprinkled until it compiles, `Rc<RefCell<T>>` reproducing a garbage-collected object graph, and doomed self-referential structs. codex-rs has zero `Rc<RefCell>` across ~2,500 files and denies `clippy::redundant_clone` workspace-wide; its clones are designed (Copy IDs, Arc pointer bumps, snapshots extracted from locks), its graphs live in ID-keyed owning maps (`HashMap<ThreadId, Arc<CodexThread>>`), and cross-references are stored as IDs, never as references.

## 3. Anemic & Stringly Data (type)

**Description:** Data modeled as if `enum` and `match` did not exist. Booleans and strings encoding a state machine, parallel `Option` fields that are really one enum, raw primitives carrying domain meaning, and god-structs where half the fields are `None` at any given time. codex-rs models every mode as a data-carrying enum (`SandboxPolicy`, `AskForApproval`, `ReviewDecision` — on the external-sandbox variant even network access is a two-variant enum, not a bool), parses untrusted input once into validated newtypes (`ThreadId`, `AgentPath`, `AbsolutePathBuf`), and confines Option-heavy shapes to the serde wire layer, resolving them once into rich domain types.

## 4. Exception-Style Control Flow (flow)

**Description:** Error handling transliterated from exception-based languages. `.unwrap()`/`panic!` on expected failures, sentinel values (`-1`, empty string, `bool` success flags) instead of `Option`/`Result`, `catch_unwind` used as try/catch, and opaque `anyhow` errors on library API surfaces. codex-rs denies `clippy::unwrap_used` and `expect_used` workspace-wide (tests exempt), routes expected failures through structured `thiserror` enums (`CodexErr`, `ApiError`, `TransportError`), returns `Option`/`Result<Option<_>>` where other languages return null/−1, and uses `catch_unwind` exclusively at panic-isolation seams (thread supervisors, FFI, telemetry init) — in 14 call sites, never once as try/catch.

## 5. Dynamic Dispatch by Habit (dyn)

**Description:** `Box<dyn Trait>` reached for reflexively — the Java-interface habit of "program to an interface" — where the set of implementors is closed and known at compile time, or where a generic parameter would do. codex-rs draws the line precisely: every closed wire shape is a tagged enum matched exhaustively (`Op`, `EventMsg`, `TurnItem`, `ToolPayload`), while `dyn` is reserved for the genuinely open sets — the tool registry (`HashMap<ToolName, Arc<dyn CoreToolRuntime>>` fed by MCP servers and extensions at runtime) and host-supplied boundaries (`HttpClient`, `ThreadStore`, `ExecBackend`). Callbacks take generic `F: Fn` parameters at API surfaces and erase to `Box<dyn Fn>` only for storage.

## 6. Imperative Iteration (iter)

**Description:** Loops transliterated from C or Python. Index-based `for i in 0..v.len()` access, `let mut acc` + push loops re-implementing named combinators, and `.collect()` called between every step of what should be one lazy chain. codex-rs mechanically denies 13 `manual_*` clippy lints plus `needless_collect`; `.enumerate()` appears ~280 times in production while genuine element-indexing loops are rare, and `collect::<Result<Vec<_>, _>>()` is its standard idiom for fallible pipelines (49 production uses). Plain `for` survives exactly where combinators can't go — `.await` in the body, side-effecting I/O with `?`, index-as-coordinate, and by-index FFI.

## 7. Concurrency From Another Runtime (conc)

**Description:** Concurrency habits imported from Go, JavaScript, or thread-per-request servers. Blocking calls inside `async fn`, a `MutexGuard` held across an `.await`, async task fan-out for CPU-bound parallelism, and fire-and-forget spawns whose handles nobody owns. codex-rs wraps every blocking operation in `spawn_blocking` (~50 sites: git, file locks, zstd, OAuth callback servers), configures clippy so even *tokio* async guards may not cross an `.await` (escapes require `#[expect]` with a written atomicity reason), runs CPU fan-out on a dedicated thread pool reached via `spawn_blocking` (no rayon anywhere), and stores every spawned task's handle in `AbortOnDropHandle` with child `CancellationToken`s for structured cancel.
