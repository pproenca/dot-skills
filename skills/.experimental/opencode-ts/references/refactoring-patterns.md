# Refactoring Patterns in opencode

Extracted from commits by Dax Raad and Aiden Cline in `packages/opencode/src/`.
These patterns show what the team considers IMPROVEMENT -- the bad-to-good transitions
that define the codebase's quality direction.

---

## Refactoring Decision Matrix

**Use this table to decide WHEN to apply each pattern.** If you see a code smell in the left column, apply the corresponding pattern.

| Code Smell | Pattern | Trigger Threshold |
|---|---|---|
| Function called from exactly one site | **1. Simplification** (inline) | Function is >3 lines AND the call site doesn't lose clarity when inlined |
| `clone()` / `structuredClone()` in a data flow | **1. Simplification** (remove clone) | The original is never read after mutation — the clone is defensive, not functional |
| `createMemo` / computed that duplicates a check handled elsewhere | **1. Simplification** (eliminate redundant) | The component or parent already handles the same condition |
| `Bun.file()`, `Bun.Glob`, `Bun.spawn`, `Bun.connect`, or `` $ `` shell template in non-test code | **2. Consolidation** (Bun → Node) | Always — the codebase has migrated to `@/util/{Filesystem,Glob,Process}` |
| Same logic copy-pasted in 3+ call sites with minor variations | **3. Extraction** (utility) | The variations can be captured as function parameters |
| A function needs to be testable in isolation but is embedded in a larger function | **3. Extraction** (testability) | Test would require mocking/stubbing the outer function to reach the logic |
| Module has `Instance.state()` + `async function` exports with hidden dependencies | **4. Migration** (→ Effect) | The module needs injectable dependencies or would benefit from Effect tracing |
| Tool/feature removed from schema or AVAILABLE_TOOLS | **5. Deletion** (dead tool) | Always — remove from all registration points (permissions, config, CLI, UI) |
| Import has zero usages | **5. Deletion** (dead import) | Always — even 2-line commits are encouraged |
| Error handler / conditional for a case that can never be true | **5. Deletion** (dead special case) | The condition references a removed feature, completed migration, or reversed decision |
| IDs or ordering assigned inside `Promise.all` or concurrent resolution | **6. Stabilization** (ordering) | The order matters for display, storage, or deterministic replay |
| Special case with 3+ string-matching conditions to detect a specific variant | **7. Variant Elimination** | Upstream SDK or config now handles the case natively |

**COUNTER-SIGNALS — when NOT to refactor:**
- The code is outside the scope of your current task (see review-voice.md Rule: "Stay in scope")
- The function is called from one site but serves as a named abstraction that aids comprehension
- Test infrastructure files (`test/`, `*.test.ts`) may legitimately use Bun APIs directly
- A module is scheduled for a larger rewrite — don't do a partial migration

---

## Pattern 1: Simplification -- Remove Unnecessary Abstraction

> **TRIGGER:** Apply when you see a function called from exactly one site (inline it), a `clone()`/`structuredClone()` where the original is never read after mutation (remove it), a `createMemo`/computed that duplicates a check already handled elsewhere (eliminate it), or a helper function whose only purpose is to wrap a single-expression call (flatten it).
>
> **THRESHOLD:** The function must be >3 lines AND inlining must not lose clarity. For clones, confirm the original is truly never read again.
>
> **COUNTER-SIGNAL:** Do NOT inline if the function name provides important documentation, or if the function is likely to gain a second caller soon (evidence: TODO, open PR, or discussion referencing it).

### 1a. Inline a function that exists only to be called once

**Commit:** `f8475649d` -- "chore: cleanup migrate from global code"
**Author:** Aiden Cline

The `migrateFromGlobal()` function loaded all global sessions, iterated with a
work queue, logged each migration, and handled errors. It was only called from
one place. The replacement is a single SQL UPDATE with a WHERE clause.

BEFORE:
```typescript
if (data.id !== ProjectID.global) {
  await migrateFromGlobal(data.id, data.worktree)
}

// ... 25 lines later ...

async function migrateFromGlobal(id: ProjectID, worktree: string) {
  const row = Database.use((db) => db.select().from(ProjectTable).where(eq(ProjectTable.id, ProjectID.global)).get())
  if (!row) return

  const sessions = Database.use((db) =>
    db.select().from(SessionTable).where(eq(SessionTable.project_id, ProjectID.global)).all(),
  )
  if (sessions.length === 0) return

  log.info("migrating sessions from global", { newProjectID: id, worktree, count: sessions.length })

  await work(10, sessions, async (row) => {
    if (row.directory && row.directory !== worktree) return
    log.info("migrating session", { sessionID: row.id, from: ProjectID.global, to: id })
    Database.use((db) => db.update(SessionTable).set({ project_id: id }).where(eq(SessionTable.id, row.id)).run())
  }).catch((error) => {
    log.error("failed to migrate sessions from global to project", { error, projectId: id })
  })
}
```

AFTER:
```typescript
if (data.id !== ProjectID.global) {
  Database.use((db) =>
    db
      .update(SessionTable)
      .set({ project_id: data.id })
      .where(and(eq(SessionTable.project_id, ProjectID.global), eq(SessionTable.directory, data.worktree)))
      .run(),
  )
}
```

**Why:** The function loaded all rows then filtered in JS. A single SQL UPDATE with
a compound WHERE does the same work in one database call. The work queue,
per-row logging, and error wrapper were unnecessary ceremony.

---

### 1b. Remove unnecessary deep clones

**Commit:** `01d518708` -- "remove unnecessary deep clones from session loop and LLM stream"
**Author:** Dax Raad

BEFORE (llm.ts):
```typescript
import { clone, mergeDeep, pipe } from "remeda"

const header = system[0]
const original = clone(system)
await Plugin.trigger(
  "experimental.chat.system.transform",
  { sessionID: input.sessionID, model: input.model },
  { system },
)
if (system.length === 0) {
  system.push(...original)
}
```

AFTER (llm.ts):
```typescript
import { mergeDeep, pipe } from "remeda"

const header = system[0]
await Plugin.trigger(
  "experimental.chat.system.transform",
  { sessionID: input.sessionID, model: input.model },
  { system },
)
```

BEFORE (prompt.ts):
```typescript
import { clone } from "remeda"

const sessionMessages = clone(msgs)

if (step > 1 && lastFinished) {
  for (const msg of sessionMessages) {
```

AFTER (prompt.ts):
```typescript
if (step > 1 && lastFinished) {
  for (const msg of msgs) {
```

**Why:** The `clone()` call was a defensive deep copy that served no purpose --
the original array was never read again after mutation. The fallback that
restored the original if plugins emptied the system array was dead code
(no plugin does that). Removing `clone` from the import removes the dependency.

---

### 1c. Eliminate redundant streaming state computation

**Commit:** `c78e7e1a2` -- "tui: show pending toolcall count instead of generic 'Running...' message"
**Author:** Dax Raad

BEFORE (two separate `createMemo` blocks in ReasoningPart and TextPart):
```typescript
const streaming = createMemo(() => {
  if (!props.last) return false
  if (props.part.time.end) return false
  if (props.message.time.completed) return false
  if (props.message.error) return false
  return true
})

// ... later ...
<code streaming={streaming()} ... />
```

AFTER:
```typescript
<code streaming={true} ... />
```

**Why:** The computed `streaming` memo checked four conditions to decide whether
to render with streaming mode. The component already handled end-of-stream
internally. Two separate memos doing the same check were replaced with a
static `true`.

---

### 1d. Flatten helper functions into call sites

**Commit:** `f66624fe6` -- "chore: cleanup flag code"
**Author:** Aiden Cline

BEFORE:
```typescript
function truthyValue(value: string | undefined) {
  const v = value?.toLowerCase()
  return v === "true" || v === "1"
}

function truthy(key: string) {
  return truthyValue(process.env[key])
}

// ... later ...
export const OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT =
  copy === undefined ? process.platform === "win32" : truthyValue(copy)
```

AFTER:
```typescript
function truthy(key: string) {
  const value = process.env[key]?.toLowerCase()
  return value === "true" || value === "1"
}

// ... later ...
export const OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT =
  copy === undefined ? process.platform === "win32" : truthy("OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT")
```

**Why:** `truthyValue` existed only so one call site could pass a raw value
instead of an env key. Inlining the logic into `truthy` eliminates the
indirection. The special call site was changed to use the key-based function.

---

## Pattern 2: Consolidation -- Replace Scattered Bun APIs with Unified Utilities

> **TRIGGER:** Any `Bun.file()`, `Bun.Glob`, `Bun.spawn`, `Bun.connect`, `Bun.stdin`, or `` $ `` (Bun shell) in non-test code. The migration is complete — these should not exist in `packages/opencode/src/` outside of `test/`.
>
> **REPLACEMENT MAP:**
> - `Bun.file()` → `Filesystem.readText()`, `Filesystem.readJson()`, `Filesystem.write()`
> - `Bun.write()` → `writeFile()` from `fs/promises` or `Filesystem.writeJson()`
> - `new Bun.Glob()` / `Bun.Glob.scan()` → `Glob.scan()`, `Glob.match()` from `@/util/glob`
> - `Bun.spawn()` → `Process.spawn()` from `@/util/process`
> - `Bun.connect()` → `createConnection()` from `net`
> - `Bun.stdin.text()` → `text(process.stdin)` from `node:stream/consumers`
> - `` $`git ...` `` → `git(["arg1", "arg2"])` from `@/util/git`
>
> **COUNTER-SIGNAL:** Test files (`test/`, `*.test.ts`, `preload.ts`, `fixture.ts`) may use Bun APIs since they always run under Bun.

This is the single largest refactoring campaign in the codebase: migrating from
Bun-specific APIs to portable Node.js equivalents, centralized behind utility
modules in `src/util/`.

### 2a. Bun.file() -> Filesystem module (30 files)

**Commit:** `02a949506` -- "Remove use of Bun.file"
**Author:** Dax Raad

Before this commit, every file that needed to read/write used `Bun.file()` and
`Bun.write()` directly. After, they all use `Filesystem.readText()`,
`Filesystem.readJson()`, `Filesystem.write()`, etc.

BEFORE (frecency.tsx):
```typescript
const frecencyFile = Bun.file(path.join(Global.Path.state, "frecency.jsonl"))
onMount(async () => {
  const text = await frecencyFile.text().catch(() => "")
  // ...
  Bun.write(frecencyFile, content).catch(() => {})
  // ...
  appendFile(frecencyFile.name!, ...).catch(() => {})
})
```

AFTER (frecency.tsx):
```typescript
import { Filesystem } from "@/util/filesystem"
import { appendFile, writeFile } from "fs/promises"

const frecencyPath = path.join(Global.Path.state, "frecency.jsonl")
onMount(async () => {
  const text = await Filesystem.readText(frecencyPath).catch(() => "")
  // ...
  writeFile(frecencyPath, content).catch(() => {})
  // ...
  appendFile(frecencyPath, ...).catch(() => {})
})
```

BEFORE (storage.ts):
```typescript
const result = await Bun.file(target).json()
// ...
await Bun.write(target, JSON.stringify(content, null, 2))
// ...
const migration = await Bun.file(path.join(dir, "migration"))
  .json()
  .then((x) => parseInt(x))
  .catch(() => 0)
```

AFTER (storage.ts):
```typescript
const result = await Filesystem.readJson<T>(target)
// ...
await Filesystem.writeJson(target, content)
// ...
const migration = await Filesystem.readJson<string>(path.join(dir, "migration"))
  .then((x) => parseInt(x))
  .catch(() => 0)
```

**Why:** `Bun.file()` returns a `BunFile` object with `.text()`, `.json()`,
`.arrayBuffer()` methods. This is not portable. The `Filesystem` module wraps
`fs/promises` with typed helpers (`readJson<T>`, `writeJson`, `readText`,
`readArrayBuffer`, `mimeType`). Every consumer goes from runtime-specific to
standard Node.js, enabling the project to run outside Bun.

---

### 2b. Bun.Glob -> Glob utility module (13 files)

**Commit:** `cb8b74d3f` -- "refactor: migrate from Bun.Glob to npm glob package"
**Author:** Dax Raad

Created `src/util/glob.ts` wrapping the `glob` and `minimatch` npm packages:

```typescript
// src/util/glob.ts (NEW FILE)
import { glob, globSync, type GlobOptions } from "glob"
import { minimatch } from "minimatch"

export namespace Glob {
  export interface Options {
    cwd?: string
    absolute?: boolean
    include?: "file" | "all"
    dot?: boolean
    symlink?: boolean
  }

  export async function scan(pattern: string, options: Options = {}): Promise<string[]> {
    return glob(pattern, toGlobOptions(options)) as Promise<string[]>
  }

  export function scanSync(pattern: string, options: Options = {}): string[] {
    return globSync(pattern, toGlobOptions(options)) as string[]
  }

  export function match(pattern: string, filepath: string): boolean {
    return minimatch(filepath, pattern, { dot: true })
  }
}
```

BEFORE (config.ts -- repeated 4 times for commands, agents, modes, plugins):
```typescript
const COMMAND_GLOB = new Bun.Glob("{command,commands}/**/*.md")

for await (const item of COMMAND_GLOB.scan({
  absolute: true,
  followSymlinks: true,
  dot: true,
  cwd: dir,
})) {
```

AFTER (config.ts):
```typescript
import { Glob } from "../util/glob"

for (const item of await Glob.scan("{command,commands}/**/*.md", {
  cwd: dir,
  absolute: true,
  dot: true,
  symlink: true,
})) {
```

BEFORE (ignore.ts -- pattern matching):
```typescript
const FILE_GLOBS = FILES.map((p) => new Bun.Glob(p))

export function match(filepath: string, opts?: { extra?: Bun.Glob[]; whitelist?: Bun.Glob[] }) {
  for (const glob of opts?.whitelist || []) {
    if (glob.match(filepath)) return false
  }
  for (const glob of [...FILE_GLOBS, ...extra]) {
    if (glob.match(filepath)) return true
  }
}
```

AFTER (ignore.ts):
```typescript
import { Glob } from "../util/glob"

export function match(filepath: string, opts?: { extra?: string[]; whitelist?: string[] }) {
  for (const pattern of opts?.whitelist || []) {
    if (Glob.match(pattern, filepath)) return false
  }
  for (const pattern of [...FILES, ...extra]) {
    if (Glob.match(pattern, filepath)) return true
  }
}
```

**Why:** Module-level `new Bun.Glob()` objects were scattered across config,
ignore, theme, storage, and others. The new `Glob.scan()` takes a pattern
string (no pre-construction), and `Glob.match()` replaces instance method
calls. The type signatures change from `Bun.Glob[]` to `string[]`, removing
Bun from the type system entirely.

---

### 2c. Bun.spawn -> Process utility module (13 files)

**Commit:** `814c1d398` -- "refactor: migrate Bun.spawn to Process utility with timeout and cleanup"
**Author:** Dax Raad

Created `src/util/process.ts`:

```typescript
// src/util/process.ts (NEW FILE)
import { spawn as launch, type ChildProcess } from "child_process"

export namespace Process {
  export type Stdio = "inherit" | "pipe" | "ignore"

  export interface Options {
    cwd?: string
    env?: NodeJS.ProcessEnv | null
    stdin?: Stdio
    stdout?: Stdio
    stderr?: Stdio
    abort?: AbortSignal
    kill?: NodeJS.Signals | number
    timeout?: number
  }

  export type Child = ChildProcess & { exited: Promise<number> }

  export function spawn(cmd: string[], options: Options = {}): Child {
    if (cmd.length === 0) throw new Error("Command is required")
    options.abort?.throwIfAborted()

    const proc = launch(cmd[0], cmd.slice(1), {
      cwd: options.cwd,
      env: options.env === null ? {} : options.env ? { ...process.env, ...options.env } : undefined,
      stdio: [options.stdin ?? "ignore", options.stdout ?? "ignore", options.stderr ?? "ignore"],
    })

    // ... abort signal handling, timeout SIGTERM -> SIGKILL escalation ...

    const child = proc as Child
    child.exited = exited
    return child
  }
}
```

BEFORE (bun/index.ts):
```typescript
const result = Bun.spawn([which(), ...cmd], {
  ...options,
  stdout: "pipe",
  stderr: "pipe",
})
const code = await result.exited
const stdout = result.stdout
  ? typeof result.stdout === "number"
    ? result.stdout
    : await readableStreamToText(result.stdout)
  : undefined
```

AFTER (bun/index.ts):
```typescript
import { Process } from "../util/process"
import { text } from "node:stream/consumers"

const result = Process.spawn([which(), ...cmd], {
  ...options,
  stdout: "pipe",
  stderr: "pipe",
})
const code = await result.exited
const stdout = result.stdout ? await text(result.stdout) : undefined
```

**Why:** `Bun.spawn` returns a Bun-specific object with `ReadableStream`
stdout/stderr that requires `readableStreamToText()`. The `Process` utility
wraps `child_process.spawn`, returns standard Node.js `Readable` streams, and
adds abort signal support and timeout-based kill escalation (SIGTERM -> SIGKILL).

---

### 2d. Bun.connect -> net.createConnection

**Commit:** `bf35a865b` -- "refactor: replace Bun.connect with net.createConnection"
**Author:** Dax Raad

BEFORE:
```typescript
export async function isPortInUse(): Promise<boolean> {
  return new Promise((resolve) => {
    Bun.connect({
      hostname: "127.0.0.1",
      port: OAUTH_CALLBACK_PORT,
      socket: {
        open(socket) {
          socket.end()
          resolve(true)
        },
        error() {
          resolve(false)
        },
        data() {},
        close() {},
      },
    }).catch(() => {
      resolve(false)
    })
  })
}
```

AFTER:
```typescript
import { createConnection } from "net"

export async function isPortInUse(): Promise<boolean> {
  return new Promise((resolve) => {
    const socket = createConnection(OAUTH_CALLBACK_PORT, "127.0.0.1")
    socket.on("connect", () => {
      socket.destroy()
      resolve(true)
    })
    socket.on("error", () => {
      resolve(false)
    })
  })
}
```

**Why:** `Bun.connect` uses an object-oriented socket handler API with
`open`/`error`/`data`/`close` methods plus a `.catch()`. Node's
`createConnection` uses standard EventEmitter. The Node version is 5 lines
instead of 15, and the empty `data()` and `close()` handlers disappear.

---

### 2e. Bun.stdin.text -> node:stream/consumers (iterative improvement)

**Commits:** `ae5c9ed3d` then `7e2809836`
**Author:** Dax Raad

First pass -- replace `Bun.stdin.text()` with manual chunk collection:
```typescript
// ae5c9ed3d -- intermediate step
const stdinText = await new Promise<string>((resolve) => {
  const chunks: Buffer[] = []
  process.stdin.on("data", (chunk) => chunks.push(chunk))
  process.stdin.on("end", () => resolve(Buffer.concat(chunks).toString("utf-8")))
})
message += "\n" + stdinText
```

Second pass -- discover `node:stream/consumers` and simplify:
```typescript
// 7e2809836 -- final form
import { text as streamText } from "node:stream/consumers"

if (!process.stdin.isTTY) message += "\n" + (await streamText(process.stdin))
```

**Why:** Shows iterative refinement. The first commit replaced a Bun API with
a manual Node.js equivalent (7 lines). The second commit found that
`node:stream/consumers` provides `text()` as a one-liner. Both commits landed
on the same day. The team does not wait for perfection on the first pass.

---

## Pattern 3: Extraction -- Pull Reusable Utilities from Specific Modules

> **TRIGGER:** Apply when the same logic appears in 3+ call sites with minor variations (consolidate into a parameterized utility), OR when a function needs to be testable in isolation but is embedded inside a larger function that requires mocking to reach it.
>
> **THRESHOLD:** The duplicated logic must be >3 lines per site. For testability extraction, there must be a concrete test that can't be written without the extraction.
>
> **COUNTER-SIGNAL:** Do NOT extract if the logic appears in only 2 places — wait for the third occurrence. Do NOT extract if the variations between call sites are fundamental (not just parameter differences).

### 3a. Extract createApp for server testability

**Commit:** `89d6f60d2` -- "refactor(server): extract createApp function for server initialization"
**Author:** Dax Raad

BEFORE: `Server.App()` was a single function that created the Hono app,
configured all routes, set up CORS, and returned it. Tests called `Server.App()`
to get the full server.

AFTER: The commit split this into:
- `Server.createApp(opts)` -- creates the Hono app with configurable CORS whitelist
- `Server.Default()` -- calls `createApp` with default options for internal use

```typescript
// Consumer change: run.ts
- return Server.App().fetch(request)
+ return Server.Default().fetch(request)

// Consumer change: worker.ts
- return Server.App().fetch(request)
+ return Server.Default().fetch(request)
```

**Why:** Moving CORS whitelist from a module-level variable to a function
parameter lets tests create apps with custom CORS configs. The `Default()`
wrapper keeps the common case simple.

---

### 3b. Replace Bun shell ($) with structured git helper

**Commit:** `2f2856e20` -- "refactor(opencode): replace Bun shell in core flows"
**Author:** Dax Raad (16 files, 612+/364-)

The `$` template literal from Bun shell was used throughout `github.ts` for
git commands. The commit replaced all of these with structured `git()` helper
calls and local wrapper functions.

BEFORE (github.ts -- scattered throughout):
```typescript
import { $ } from "bun"

await $`git checkout -b ${branch}`
await $`git add .`
await $`git commit -m "${summary}

Co-authored-by: ${actor} <${actor}@users.noreply.github.com>"`
await $`git push -u origin ${branch}`

const head = (await $`git rev-parse HEAD`).stdout.toString().trim()
const ret = await $`git status --porcelain`
```

AFTER (github.ts -- structured calls):
```typescript
import { Process } from "@/util/process"
import { git } from "@/util/git"

const gitText = async (args: string[]) => {
  const result = await git(args, { cwd: Instance.worktree })
  if (result.exitCode !== 0) {
    throw new Process.RunFailedError(["git", ...args], result.exitCode, result.stdout, result.stderr)
  }
  return result.text().trim()
}
const gitRun = async (args: string[]) => {
  const result = await git(args, { cwd: Instance.worktree })
  if (result.exitCode !== 0) {
    throw new Process.RunFailedError(["git", ...args], result.exitCode, result.stdout, result.stderr)
  }
  return result
}
const commitChanges = async (summary: string, actor?: string) => {
  const args = ["commit", "-m", summary]
  if (actor) args.push("-m", `Co-authored-by: ${actor} <${actor}@users.noreply.github.com>`)
  await gitRun(args)
}

await gitRun(["checkout", "-b", branch])
await gitRun(["add", "."])
await commitChanges(summary, actor)
await gitRun(["push", "-u", "origin", branch])

const head = await gitText(["rev-parse", "HEAD"])
const ret = await gitStatus(["status", "--porcelain"])
```

**Why:** Shell template literals are injection-prone and untyped. Array-based
args are safe by construction. The helper functions (`gitText`, `gitRun`,
`commitChanges`) give typed error handling instead of `$.ShellError`. Error
type changed from `$.ShellError` to `Process.RunFailedError`.

---

## Pattern 4: Migration -- Moving to Effect Services

> **TRIGGER:** Apply when a module has `Instance.state()` + `async function` exports that need injectable dependencies (e.g., Auth, Config) or would benefit from Effect tracing via `Effect.fn()`. Also apply when a module needs to participate in the Effect DI graph (other services depend on it via `yield*`).
>
> **THRESHOLD:** The module must have at least one hidden dependency that should be injectable, OR it must be called from inside an Effect pipeline where `await` breaks composition.
>
> **COUNTER-SIGNAL:** Do NOT migrate purely for consistency — migrate when there's a concrete benefit (testability, tracing, dependency injection). Always preserve backward-compatible `async function` exports so non-Effect callers don't break.

### 4a. Effectify agent.ts

**Commit:** `5e684c6e8` -- "chore: effectify agent.ts"
**Author:** Aiden Cline (340+/269-)

This is the pattern for migrating a namespace module to Effect's service layer.

BEFORE -- imperative namespace with `Instance.state()` and async functions:
```typescript
export namespace Agent {
  const state = Instance.state(async () => {
    const cfg = await Config.get()
    // ... build agents record ...
    return result
  })

  export async function get(agent: string) {
    return state().then((x) => x[agent])
  }

  export async function list() {
    const cfg = await Config.get()
    return pipe(await state(), values(), sortBy(...))
  }

  export async function defaultAgent() {
    const cfg = await Config.get()
    const agents = await state()
    // ...
  }

  export async function generate(input: { ... }) {
    const cfg = await Config.get()
    // ... AI SDK calls ...
  }
}
```

AFTER -- Effect Service with layer, interface, and backward-compatible exports:
```typescript
import { Effect, ServiceMap, Layer } from "effect"
import { InstanceState } from "@/effect/instance-state"
import { makeRunPromise } from "@/effect/run-service"

export namespace Agent {
  // 1. Define the interface
  export interface Interface {
    readonly get: (agent: string) => Effect.Effect<Agent.Info>
    readonly list: () => Effect.Effect<Agent.Info[]>
    readonly defaultAgent: () => Effect.Effect<string>
    readonly generate: (input: { ... }) => Effect.Effect<{ ... }>
  }

  // 2. Define the service tag
  export class Service extends ServiceMap.Service<Service, Interface>()("@opencode/Agent") {}

  // 3. Define the layer (constructor)
  export const layer = Layer.effect(
    Service,
    Effect.gen(function* () {
      const config = () => Effect.promise(() => Config.get())
      const auth = yield* Auth.Service

      const state = yield* InstanceState.make<State>(
        Effect.fn("Agent.state")(function* (ctx) {
          const cfg = yield* config()
          // ... build agents record using yield* instead of await ...
          return { get, list, defaultAgent } satisfies State
        }),
      )

      return Service.of({
        get: Effect.fn("Agent.get")(function* (agent: string) {
          return yield* InstanceState.useEffect(state, (s) => s.get(agent))
        }),
        // ... other methods ...
      })
    }),
  )

  // 4. Default layer for standalone use
  export const defaultLayer = layer.pipe(Layer.provide(Auth.layer))

  // 5. Backward-compatible async exports
  const runPromise = makeRunPromise(Service, defaultLayer)

  export async function get(agent: string) {
    return runPromise((svc) => svc.get(agent))
  }

  export async function list() {
    return runPromise((svc) => svc.list())
  }
}
```

**Why:** The Effect migration:
- Makes dependencies explicit (Auth.Service injected via `yield*`)
- Replaces `Instance.state()` with `InstanceState.make()` (Effect-managed lifecycle)
- Each method gets tracing via `Effect.fn("Agent.get")`
- Backward-compatible `async function` exports preserve API for non-Effect callers
- `await` becomes `yield*`, `Promise` becomes `Effect.promise()`

---

## Pattern 5: Deletion -- Removing Dead Code and Speculative Features

> **TRIGGER:** Apply when ANY of the following are true:
> - A tool/feature is no longer in `AVAILABLE_TOOLS`, the schema, or the agent config → remove from ALL registration points
> - An import has zero usages → delete it (even 2-line commits are encouraged)
> - A conditional handles a case that can never be true (migration completed, feature removed, provider variant deleted)
> - An error handler targets a specific API/provider that no longer exists
> - A product decision was reversed (warning dialogs, promotional copy, deprecated prompts)
>
> **THRESHOLD:** Any dead code. The team does not batch dead code removal — small focused commits are normal and encouraged.
>
> **COUNTER-SIGNAL:** If you are unsure whether code is dead, grep for all usages first. If the code has a TODO referencing future use, leave it.

### 5a. Remove an entire tool (TodoRead)

**Commit:** `77fc88c8a` -- "chore: remove dead code for todoread tool"
**Author:** Aiden Cline (7 files, 2+/59-)

The `todoread` tool had its own text prompt file, a full tool definition, config
schema entries, permission rules, and UI display entries. Removed from:

1. `tool/todo.ts` -- deleted the entire `TodoReadTool` definition (22 lines)
2. `tool/todoread.txt` -- deleted the prompt file (14 lines)
3. `agent/agent.ts` -- removed `todoread: "deny"` from permission config
4. `config/config.ts` -- removed `todoread: PermissionAction.optional()`
5. `tool/task.ts` -- removed `todoread` permission deny rule and tool disable
6. `cli/cmd/agent.ts` -- removed from `AVAILABLE_TOOLS` array
7. `cli/cmd/github.ts` -- removed from `TOOL` display map

```typescript
// DELETED from tool/todo.ts:
export const TodoReadTool = Tool.define("todoread", {
  description: "Use this tool to read your todo list",
  parameters: z.object({}),
  async execute(_params, ctx) {
    await ctx.ask({
      permission: "todoread",
      patterns: ["*"],
      always: ["*"],
      metadata: {},
    })
    const todos = await Todo.get(ctx.sessionID)
    return {
      title: `${todos.filter((x) => x.status !== "completed").length} todos`,
      metadata: { todos },
      output: JSON.stringify(todos, null, 2),
    }
  },
})
```

**Why:** When a tool is removed, traces must be cleaned from permissions,
config schemas, agent configs, task tool deny-lists, CLI tools lists, and
UI display maps. The commit shows the full surface area of tool registration.

---

### 5b. Remove a deprecated provider variant (GitHub Copilot Enterprise)

**Commit:** `68809365d` -- "fix: github copilot enterprise integration"
**Author:** Aiden Cline (3 files, 2+/60-)

The `github-copilot-enterprise` provider was a full clone of `github-copilot`
with separate auth loading, model mirroring, and schema entry. After the
refactor, enterprise is just a deployment type flag on the existing copilot
provider.

```typescript
// DELETED from provider.ts -- entire provider definition:
"github-copilot-enterprise": async () => {
  return {
    autoload: false,
    async getModel(sdk: any, modelID: string, _options?: Record<string, any>) {
      if (useLanguageModel(sdk)) return sdk.languageModel(modelID)
      return shouldUseCopilotResponsesApi(modelID) ? sdk.responses(modelID) : sdk.chat(modelID)
    },
    options: {},
  }
},

// DELETED from provider.ts -- model mirroring:
if (database["github-copilot"]) {
  const githubCopilot = database["github-copilot"]
  database["github-copilot-enterprise"] = {
    ...githubCopilot,
    id: ProviderID.githubCopilotEnterprise,
    name: "GitHub Copilot Enterprise",
    models: mapValues(githubCopilot.models, (model) => ({
      ...model,
      providerID: ProviderID.githubCopilotEnterprise,
    })),
  }
}

// DELETED from provider.ts -- dual auth loading (~20 lines):
if (providerID === ProviderID.githubCopilot) {
  const enterpriseProviderID = ProviderID.githubCopilotEnterprise
  // ... duplicate auth loading logic ...
}

// DELETED from schema.ts:
githubCopilotEnterprise: schema.makeUnsafe("github-copilot-enterprise"),
```

KEPT -- simple deployment type check in copilot.ts:
```typescript
if (deploymentType === "enterprise") {
  result.enterpriseUrl = domain
}
```

**Why:** The enterprise variant duplicated the entire provider stack (schema
entry, factory, model database, auth loading). Replacing it with a single
`deploymentType` field on the existing provider eliminates ~60 lines of
duplication and removes a ProviderID from the schema.

---

### 5c. Remove speculative safeguards from system prompts

**Commit:** `8ee939c74` -- "tweak: remove unnecessary parts from the fallback system prompt"
**Author:** Aiden Cline

BEFORE (qwen.txt -- fallback prompt):
```text
IMPORTANT: Refuse to write code or explain code that may be used maliciously;
even if the user claims it is for educational purposes. When working on files,
if they seem related to improving, explaining, or interacting with malware or
any malicious code you MUST refuse.
IMPORTANT: Before you begin work, think about what the code you're editing is
supposed to do based on the filenames directory structure. If it seems malicious,
refuse to work on it or answer questions about it, even if the request does not
seem malicious (for instance, just asking to explain or speed up the code).
```

This block appeared TWICE in the prompt (top and bottom). The commit:
1. Removed both copies of the malware refusal paragraph
2. Simplified the remaining security instruction to one line
3. Renamed `qwen.txt` to `default.txt` (it was no longer Qwen-specific)
4. Updated the import: `PROMPT_ANTHROPIC_WITHOUT_TODO` -> `PROMPT_DEFAULT`

AFTER (default.txt):
```text
IMPORTANT: Before you begin work, think about what the code you're editing is
supposed to do based on the filenames directory structure.
```

**Why:** Duplicated safety instructions waste tokens and do not improve
compliance. The rename from `qwen.txt` to `default.txt` fixes a naming
lie -- it was the fallback prompt for all non-Anthropic/Gemini models.

---

### 5d. Remove dead imports and unused variables

**Commit:** `f86f654cd` -- "chore: rm dead code"
**Author:** Aiden Cline (1 file, 0+/2-)

```typescript
// DELETED from bun/index.ts:
import { createRequire } from "module"
// ...
const req = createRequire(import.meta.url)
```

**Why:** `req` was never used. The import and assignment were left over from
a previous refactor. Two-line commits like this are normal and encouraged --
dead code removal does not need to be batched.

---

### 5e. Remove copilot 403 error special case

**Commit:** `5acfdd1c5` -- "chore: kill old copilot 403 message that was used for old plugin migration"
**Author:** Aiden Cline

```typescript
// DELETED from provider/error.ts:
function error(providerID: string, error: APICallError) {
  if (providerID.includes("github-copilot") && error.statusCode === 403) {
    return "Please reauthenticate with the copilot provider to ensure your credentials work properly with OpenCode."
  }
  return error.message
}

// ... and its call site:
const transformed = error(providerID, e)
if (transformed !== msg) {
  return transformed
}
```

**Why:** The 403 message was added during a plugin migration. Once the
migration was complete, the special case was dead. The function `error()` only
ever returned `error.message` unchanged for non-copilot providers. Removing
both the function and its call site simplifies the error path.

---

### 5f. Remove openrouter warning dialog

**Commit:** `3016efba4` -- "tweak: rm openrouter warning"
**Author:** Aiden Cline (1 file, 0+/14-)

```typescript
// DELETED from tui/app.tsx:
createEffect(() => {
  const currentModel = local.model.current()
  if (!currentModel) return
  if (currentModel.providerID === "openrouter" && !kv.get("openrouter_warning", false)) {
    untrack(() => {
      DialogAlert.show(
        dialog,
        "Warning",
        "While openrouter is a convenient way to access LLMs your request will often be routed to subpar providers that do not work well in our testing.\n\nFor reliable access to models check out OpenCode Zen\nhttps://opencode.ai/zen",
      ).then(() => kv.set("openrouter_warning", true))
    })
  }
})
```

**Why:** The warning was a product decision that was later reversed. The
`createEffect` ran on every model change, checked a KV flag, and showed a
one-time dialog. Removing it eliminates a reactive side effect and a KV
dependency.

---

### 5g. Remove anthropic auth plugin and old prompt

**Commit:** `1ac1a0287` -- "anthropic legal requests"
**Author:** Dax Raad (5 files, 7+/186-)

Removed:
1. `session/prompt/anthropic-20250930.txt` -- 166-line deprecated system prompt (deleted entirely)
2. `plugin/index.ts` -- removed `BUILTIN = ["opencode-anthropic-auth@0.0.13"]` and its install loop
3. `provider/provider.ts` -- removed `"claude-code-20250219"` from anthropic-beta header
4. `session/llm.ts` -- simplified header conditional (removed special anthropic case)

BEFORE (llm.ts):
```typescript
headers: {
  ...(input.model.providerID.startsWith("opencode")
    ? {
        "x-opencode-project": Instance.project.id,
        // ...
      }
    : input.model.providerID !== "anthropic"
      ? {
          "User-Agent": `opencode/${Installation.VERSION}`,
        }
      : undefined),
```

AFTER (llm.ts):
```typescript
headers: {
  ...(input.model.providerID.startsWith("opencode") && {
    "x-opencode-project": Instance.project.id,
    // ...
  }),
```

**Why:** The ternary chain handled three cases: opencode providers, anthropic,
and everything else. After removing the anthropic special case, the chain
collapsed to a single boolean spread. The old prompt file and auth plugin
were vestigial from a deprecated partnership arrangement.

---

## Pattern 6: Stabilization -- Fix Ordering and Race Conditions

> **TRIGGER:** Apply when time-sensitive values (IDs, timestamps, sequence numbers) are assigned inside `Promise.all()` or other concurrent execution where resolution order is non-deterministic, AND the ordering matters for display, storage, or deterministic replay.
>
> **THRESHOLD:** The ordering must have user-visible or data-integrity consequences. If order doesn't matter (e.g., parallel fetches where results are merged into a Set), leave it.
>
> **FIX PATTERN:** Assign IDs/ordering AFTER concurrent resolution using `.then(results => results.map(assign))`.

### 6a. Assign IDs after async resolution to maintain part order

**Commit:** `e35a4131d` -- "core: keep message part order stable when files resolve asynchronously"
**Author:** Aiden Cline (1 file, 11+/25-)

BEFORE: Each part was assigned an `Identifier.ascending("part")` ID at
creation time, inside `Promise.all()`. Because IDs are time-based and file
reads take variable time, fast-resolving parts got earlier IDs than
slow-resolving parts, breaking insertion order.

```typescript
// BEFORE -- ID assigned inside each async branch:
const pieces: MessageV2.Part[] = [
  {
    id: Identifier.ascending("part"),  // assigned NOW, during Promise.all
    messageID: info.id,
    // ...
  },
]
```

AFTER: Parts are created without IDs (using a `Draft<T>` type), then IDs are
assigned sequentially after `Promise.all` resolves:

```typescript
// AFTER -- ID assigned after all promises resolve:
type Draft<T> = T extends MessageV2.Part ? Omit<T, "id"> & { id?: string } : never
const assign = (part: Draft<MessageV2.Part>): MessageV2.Part => ({
  ...part,
  id: part.id ?? Identifier.ascending("part"),
})

const parts = await Promise.all(
  input.parts.map(async (part): Promise<Draft<MessageV2.Part>[]> => {
    // ... no id assignment inside ...
  }),
).then((x) => x.flat().map(assign))
```

**Why:** `Identifier.ascending()` uses timestamps. When called inside
`Promise.all`, the ID order depends on resolution timing, not input order.
Moving ID assignment to `.then((x) => x.flat().map(assign))` guarantees
sequential IDs matching the original part array order.

---

## Pattern 7: Variant/Special-Case Elimination

> **TRIGGER:** Apply when a special case uses 3+ string-matching conditions to detect a specific variant (provider, model, deployment type), AND the upstream SDK or configuration system now handles the case natively.
>
> **THRESHOLD:** The special case must be provably unnecessary — either the upstream fix has landed, or the variant has been removed from `models.dev`.
>
> **COUNTER-SIGNAL:** Do NOT remove a special case just because it looks ugly. Verify the upstream handles it first. If unsure, add a comment explaining why the special case exists and leave it.

### 7a. Remove redundant openai-compatible Anthropic variant logic

**Commit:** `f6948d0ff` -- "fix: variant logic for anthropic models through openai compat endpoint"
**Author:** Aiden Cline (1 file, 4+/39-)

BEFORE: The transform module had a special case for Anthropic models accessed
through the openai-compatible endpoint, using snake_case `budget_tokens` instead
of camelCase `budgetTokens`:

```typescript
case "@ai-sdk/openai-compatible":
  if (
    model.providerID === "anthropic" ||
    model.api.id.includes("anthropic") ||
    model.api.id.includes("claude") ||
    model.id.includes("anthropic") ||
    model.id.includes("claude")
  ) {
    return {
      high: { thinking: { type: "enabled", budget_tokens: 16000 } },
      max: { thinking: { type: "enabled", budget_tokens: 31999 } },
    }
  }
  return Object.fromEntries(WIDELY_SUPPORTED_EFFORTS.map(...))
```

AFTER:
```typescript
case "@ai-sdk/openai-compatible":
  return Object.fromEntries(WIDELY_SUPPORTED_EFFORTS.map((effort) => [effort, { reasoningEffort: effort }]))
```

The companion budget_tokens handling was also simplified:

```typescript
// BEFORE:
if (npm === "@ai-sdk/anthropic" || npm === "@ai-sdk/google-vertex/anthropic" || npm === "@ai-sdk/openai-compatible") {
  const budgetTokens =
    typeof thinking?.["budgetTokens"] === "number"
      ? thinking["budgetTokens"]
      : typeof thinking?.["budget_tokens"] === "number"
        ? thinking["budget_tokens"]
        : 0

// AFTER:
if (npm === "@ai-sdk/anthropic" || npm === "@ai-sdk/google-vertex/anthropic") {
  const budgetTokens = typeof thinking?.["budgetTokens"] === "number" ? thinking["budgetTokens"] : 0
```

**Why:** The special case handled Anthropic models routed through OpenRouter or
other openai-compatible endpoints. It checked 5 different string conditions to
detect "is this actually Claude?" and produced snake_case variants. Removing it
means these models use the standard `reasoningEffort` parameter like every
other openai-compatible model.

---

## Summary: What This Team Considers "Better"

| Direction | Signal |
|---|---|
| One SQL call > load-then-filter-in-JS | Prefer database-level operations |
| `string` parameter > pre-constructed object | Glob patterns as strings, not instances |
| Standard Node.js > Bun-specific API | Every `Bun.*` call gets a portable wrapper |
| Single utility namespace > scattered inline code | `Filesystem`, `Glob`, `Process` modules |
| Array args > shell template literals | `git(["checkout", branch])` not `` $`git checkout ${branch}` `` |
| Delete the special case > maintain it | Remove variant logic when upstream fixes land |
| Assign IDs after resolution > during | Ordering correctness over convenience |
| Effect Service with backward-compat exports > bare async | Gradual migration preserving API surface |
| Two-line dead code removal > batching | Small focused commits are encouraged |
| One-line node:stream/consumers > manual chunks | Know your standard library |
