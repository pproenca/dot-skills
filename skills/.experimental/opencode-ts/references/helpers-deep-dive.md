# Helpers Deep Dive

> Every helper and utility in the opencode codebase. An LLM should never reinvent something that already exists, AND should know when NOT to use a helper.

---

## Table of Contents

1. [util/ Utilities (35 files)](#util-utilities)
2. [Non-util Helpers](#non-util-helpers)
3. [Usage Matrix](#usage-matrix)
4. [Anti-Patterns and Correct Avoidances](#anti-patterns-and-correct-avoidances)

---

## util/ Utilities

### `abort.ts` -- Timeout-aware AbortController creation

**What it does:** Creates AbortControllers that auto-abort after a timeout, with optional signal composition.

**Implementation:**
```typescript
export function abortAfter(ms: number) {
  const controller = new AbortController()
  const id = setTimeout(controller.abort.bind(controller), ms)
  return {
    controller,
    signal: controller.signal,
    clearTimeout: () => globalThis.clearTimeout(id),
  }
}

export function abortAfterAny(ms: number, ...signals: AbortSignal[]) {
  const timeout = abortAfter(ms)
  const signal = AbortSignal.any([timeout.signal, ...signals])
  return {
    signal,
    clearTimeout: timeout.clearTimeout,
  }
}
```

**Key design detail:** Uses `bind()` instead of arrow functions to avoid capturing surrounding scope in closures -- prevents request bodies and other large objects from being retained for the timer's lifetime.

**Used by:** No direct imports found in `src/` (defined but currently unused by application code).

**When NOT to use:** The codebase has many `new AbortController()` calls (session/prompt.ts, provider/provider.ts, acp/agent.ts, cli/cmd/tui/worker.ts, control-plane/workspace.ts, cli/cmd/tui/plugin/runtime.ts). These are all cases where the controller is NOT timeout-based -- they are lifecycle controllers that get manually aborted. The `abortAfter` helper is ONLY for timeout-based abort. Do not use it for general-purpose abort controllers.

---

### `archive.ts` -- Cross-platform zip extraction

**What it does:** Extracts zip files using platform-appropriate tools (PowerShell on Windows, `unzip` elsewhere).

**Implementation:**
```typescript
export namespace Archive {
  export async function extractZip(zipPath: string, destDir: string) {
    if (process.platform === "win32") {
      const winZipPath = path.resolve(zipPath)
      const winDestDir = path.resolve(destDir)
      const cmd = `$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive -Path '${winZipPath}' -DestinationPath '${winDestDir}' -Force`
      await Process.run(["powershell", "-NoProfile", "-NonInteractive", "-Command", cmd])
      return
    }
    await Process.run(["unzip", "-o", "-q", zipPath, "-d", destDir])
  }
}
```

**Used by:** No direct imports in `src/` (available for plugin/installation scenarios).

**When NOT to use:** Only for zip files. Does not handle tar.gz or other archive formats.

---

### `color.ts` -- Hex color validation and ANSI conversion

**What it does:** Validates hex color strings, converts to RGB, and creates ANSI bold escape sequences.

**Implementation:**
```typescript
export namespace Color {
  export function isValidHex(hex?: string): hex is string {
    if (!hex) return false
    return /^#[0-9a-fA-F]{6}$/.test(hex)
  }

  export function hexToRgb(hex: string): { r: number; g: number; b: number } {
    const r = parseInt(hex.slice(1, 3), 16)
    const g = parseInt(hex.slice(3, 5), 16)
    const b = parseInt(hex.slice(5, 7), 16)
    return { r, g, b }
  }

  export function hexToAnsiBold(hex?: string): string | undefined {
    if (!isValidHex(hex)) return undefined
    const { r, g, b } = hexToRgb(hex)
    return `\x1b[38;2;${r};${g};${b}m\x1b[1m`
  }
}
```

**Used by:** No direct imports found (TUI theming infrastructure).

**When NOT to use:** Only supports 6-digit hex (`#RRGGBB`). Does not handle 3-digit hex, named colors, or HSL.

---

### `context.ts` -- AsyncLocalStorage-based context propagation

**What it does:** Creates typed async context values using Node.js `AsyncLocalStorage`. Provides `use()` to read and `provide()` to set context.

**Implementation:**
```typescript
export namespace Context {
  export class NotFound extends Error {
    constructor(public override readonly name: string) {
      super(`No context found for ${name}`)
    }
  }

  export function create<T>(name: string) {
    const storage = new AsyncLocalStorage<T>()
    return {
      use() {
        const result = storage.getStore()
        if (!result) throw new NotFound(name)
        return result
      },
      provide<R>(value: T, fn: () => R) {
        return storage.run(value, fn)
      },
    }
  }
}
```

**Used by:**
- `storage/db.ts` -- Database transaction context (`Context.create<{ tx: TxOrDb, effects: ... }>("database")`)
- `cli/cmd/tui/thread.ts` -- TUI thread context
- `cli/cmd/tui/plugin/runtime.ts` -- Plugin runtime context
- `cli/cmd/tui/component/textarea-keybindings.ts` -- Keybinding context

**Real call pattern:**
```typescript
// Define context
const ctx = Context.create<{ tx: TxOrDb; effects: (() => void)[] }>("database")

// Provide context
ctx.provide({ tx, effects }, () => callback(tx))

// Use context (throws Context.NotFound if not in scope)
const { tx } = ctx.use()
```

**When NOT to use:** This is for vanilla JS/TS contexts. The Effect-based modules use Effect's own `Context` / `Layer` / `ServiceMap` system instead. Do NOT use `Context.create` inside Effect service code -- use `ServiceMap.Service` and layers.

---

### `data-url.ts` -- Decode data: URLs

**What it does:** Decodes base64 and percent-encoded data URLs to UTF-8 strings.

**Implementation:**
```typescript
export function decodeDataUrl(url: string) {
  const idx = url.indexOf(",")
  if (idx === -1) return ""
  const head = url.slice(0, idx)
  const body = url.slice(idx + 1)
  if (head.includes(";base64")) return Buffer.from(body, "base64").toString("utf8")
  return decodeURIComponent(body)
}
```

**Used by:**
- `session/prompt.ts` -- Decoding inline data URLs in prompt content

**When NOT to use:** Only returns strings (UTF-8). Not suitable for binary data URL decoding.

---

### `defer.ts` -- Resource cleanup via `using` / `await using`

**What it does:** Creates disposable objects for `using` / `await using` syntax, wrapping cleanup functions.

**Implementation:**
```typescript
export function defer<T extends () => void | Promise<void>>(
  fn: T,
): T extends () => Promise<void> ? { [Symbol.asyncDispose]: () => Promise<void> } : { [Symbol.dispose]: () => void } {
  return {
    [Symbol.dispose]() { fn() },
    [Symbol.asyncDispose]() { return Promise.resolve(fn()) },
  } as any
}
```

**Used by:**
- `tool/task.ts` -- Cleanup after task tool execution
- `cli/cmd/tui/util/editor.ts` -- Editor temp file cleanup

**Real call pattern:**
```typescript
await using _ = defer(async () => {
  // cleanup logic here
})
```

**When NOT to use:** The `Lock` module already returns disposables. `Flock.acquire` already returns async disposables. Do not wrap these in `defer` -- they have their own `[Symbol.asyncDispose]`.

---

### `effect-http-client.ts` -- Retry wrapper for Effect HTTP client

**What it does:** Adds transient-error retry with exponential backoff + jitter to an Effect HTTP client.

**Implementation:**
```typescript
export const withTransientReadRetry = <E, R>(client: HttpClient.HttpClient.With<E, R>) =>
  client.pipe(
    HttpClient.retryTransient({
      retryOn: "errors-and-responses",
      times: 2,
      schedule: Schedule.exponential(200).pipe(Schedule.jittered),
    }),
  )
```

**Used by:**
- `auth/index.ts` -- Retrying auth token fetches

**When NOT to use:** Only for Effect-based HTTP clients. The codebase also uses raw `fetch()` in some places (provider SDK calls) -- those use their own retry logic.

---

### `effect-zod.ts` -- Effect Schema to Zod conversion

**What it does:** Walks an Effect `Schema.AST` and produces an equivalent Zod schema. Handles strings, numbers, booleans, literals, unions, objects, arrays, optionals, and declarations.

**Implementation:** ~95 lines. Recursive AST walker that maps Effect schema nodes to Zod equivalents. Supports discriminated unions via `annotations.discriminator`.

**Used by:**
- `account/index.ts` -- Converting Effect schemas for API validation
- `installation/index.ts` -- Schema conversion for installation data
- `skill/discovery.ts` -- Schema conversion for skill discovery

**Real call pattern:**
```typescript
import { zod } from "@/util/effect-zod"
const zodSchema = zod(effectSchema)
```

**When NOT to use:** Throws on unsupported schema features (tuples with elements, multiple index signatures, multi-param declarations). If your Effect schema uses those features, you need a manual Zod equivalent.

---

### `error.ts` -- Error formatting and message extraction

**What it does:** Three functions for error handling: `errorFormat` (full representation), `errorMessage` (human-readable message), `errorData` (structured data for logging).

**Implementation:**
```typescript
export function errorFormat(error: unknown): string {
  if (error instanceof Error) return error.stack ?? `${error.name}: ${error.message}`
  if (typeof error === "object" && error !== null) {
    try { return JSON.stringify(error, null, 2) } catch { return "Unexpected error (unserializable)" }
  }
  return String(error)
}

export function errorMessage(error: unknown): string {
  if (error instanceof Error) {
    if (error.message) return error.message
    if (error.name) return error.name
  }
  if (isRecord(error) && typeof error.message === "string" && error.message) return error.message
  const text = String(error)
  if (text && text !== "[object Object]") return text
  const formatted = errorFormat(error)
  if (formatted && formatted !== "{}") return formatted
  return "unknown error"
}

export function errorData(error: unknown) { /* ... structured extraction ... */ }
```

**Used by:** 19 files including:
- `session/message-v2.ts` -- Formatting LLM errors for display
- `server/server.ts` -- Error response formatting
- `server/routes/*.ts` -- Route error handling (session, question, pty, provider, project, permission, mcp, config, experimental, workspace, tui)
- `plugin/index.ts` -- Plugin error display
- `cli/error.ts` -- CLI error formatting
- `cli/cmd/tui/thread.ts` -- TUI error display
- `process.ts` (internal) -- `errorMessage` used in `Process.run` catch

**Real call pattern:**
```typescript
try { /* ... */ } catch (e) {
  log.error("operation failed", errorData(e))
  return { error: errorMessage(e) }
}
```

**When NOT to use:** For Effect-based code, use Effect's own error handling (`Effect.catchTag`, `Effect.catchAll`). The `errorMessage`/`errorFormat` helpers are for vanilla JS try/catch boundaries.

---

### `filesystem.ts` -- File system operations with auto-mkdir and cross-platform normalization

**What it does:** Namespace with 20+ file operations: exists, isDir, stat, size, readText, readJson, readBytes, readArrayBuffer, write (auto-mkdir), writeJson, writeStream, mimeType, normalizePath, resolve, windowsPath, overlaps, contains, findUp, up, globUp.

**Implementation:** ~200 lines. Key features:
- `write()` auto-creates parent directories on ENOENT
- `resolve()` handles Git Bash / Cygwin / WSL path translation on Windows
- `normalizePath()` canonicalizes Windows case-insensitive paths via `realpathSync.native`
- `findUp()` / `up()` / `globUp()` walk up directory trees searching for files

**Used by:** 14+ files including:
- `tool/bash.ts` -- File existence checks
- `skill/index.ts` -- Reading skill files
- `shell/shell.ts` -- Shell detection
- `server/instance.ts` -- Lock file management
- `project/instance.ts` -- Project root detection
- `plugin/shared.ts`, `plugin/meta.ts`, `plugin/install.ts` -- Plugin file I/O
- `config/config.ts`, `config/paths.ts` -- Config file reading
- `storage/storage.ts` -- JSON storage backend
- `cli/cmd/tui/util/editor.ts` -- Temp file writing
- `cli/cmd/tui/thread.ts` -- File reading for thread context

**Real call pattern:**
```typescript
// Auto-mkdir write
await Filesystem.write(path.join(dir, "config.json"), JSON.stringify(data))

// Read JSON with type
const config = await Filesystem.readJson<ConfigType>(filePath)

// Walk up directory tree
const files = await Filesystem.findUp(".opencode", startDir)

// Check path containment
if (Filesystem.contains(projectRoot, filePath)) { /* safe */ }
```

**When NOT to use:** For Effect-based file operations, use `@effect/platform-node/NodeFileSystem`. This namespace is for vanilla async code only. Also: `exists()` and `isDir()` are misleadingly async (they use sync implementations internally) -- this is fine for current usage but be aware they don't truly yield.

---

### `flock.ts` -- Cross-process file-based locking with heartbeat

**What it does:** Directory-based file locks with stale detection, heartbeat, exponential backoff retry, and token-based ownership verification. For cross-PROCESS synchronization (different Node.js processes).

**Implementation:** ~330 lines. Uses `mkdir` atomicity for lock acquisition. Features:
- Stale lock detection via heartbeat file mtime
- Breaker pattern for safe stale lock cleanup (prevents two processes from both cleaning up simultaneously)
- Heartbeat interval (default: staleMs/3) keeps long operations alive
- Token verification prevents releasing locks owned by other processes
- Configurable: staleMs, timeoutMs, baseDelayMs, maxDelayMs

**Used by:**
- `config/config.ts` -- Config file writes
- `plugin/meta.ts` -- Plugin metadata updates
- `plugin/install.ts` -- Plugin installation
- `snapshot/index.ts` -- Snapshot operations

**Real call pattern:**
```typescript
// Simple usage
await using _ = await Flock.acquire("my-operation-key")
// ... critical section ...

// With options
await Flock.withLock("config-write", async () => {
  await writeConfig(data)
}, { staleMs: 30_000, timeoutMs: 10_000 })
```

**When NOT to use:** For in-process synchronization (same Node.js process), use `Lock` instead -- it is dramatically faster (no filesystem I/O). `Flock` is ONLY needed when multiple processes compete for the same resource (e.g., config file writes from multiple opencode instances).

---

### `fn.ts` -- Zod-validated function wrapper

**What it does:** Wraps a function with Zod input validation. Provides `.schema` accessor and `.force()` bypass.

**Implementation:**
```typescript
export function fn<T extends z.ZodType, Result>(schema: T, cb: (input: z.infer<T>) => Result) {
  const result = (input: z.infer<T>) => {
    let parsed
    try {
      parsed = schema.parse(input)
    } catch (e) {
      console.trace("schema validation failure stack trace:")
      if (e instanceof z.ZodError) {
        console.error("schema validation issues:", JSON.stringify(e.issues, null, 2))
      }
      throw e
    }
    return cb(parsed)
  }
  result.force = (input: z.infer<T>) => cb(input)
  result.schema = schema
  return result
}
```

**Used by:** 6 files:
- `session/prompt.ts` -- `prompt = fn(PromptInput, async (input) => { ... })`, `loop = fn(LoopInput, async (input) => { ... })`
- `session/summary.ts` -- Summary generation input validation
- `session/message-v2.ts` -- Message creation validation
- `session/index.ts` -- Session CRUD operations
- `session/compaction.ts` -- Compaction input validation
- `control-plane/workspace.ts` -- Workspace operations

**Real call pattern:**
```typescript
export const prompt = fn(PromptInput, async (input) => {
  const session = await Session.get(input.sessionID)
  // ... input is guaranteed to match PromptInput schema
})

// Call normally (validates)
await prompt({ sessionID: "ses_..." })

// Bypass validation (internal/trusted callers)
await prompt.force({ sessionID: "ses_..." })

// Access schema for documentation/routes
const schema = prompt.schema
```

**When NOT to use:** For Effect-based code, use Effect's own `Schema.decode`. For server routes, the routes use `fn.schema` to extract the Zod schema and validate separately. Do not use `fn()` for trivially typed functions that do not need runtime validation.

---

### `format.ts` -- Human-readable duration formatting (seconds input)

**What it does:** Formats a number of seconds into a human-readable string ("5s", "3m 20s", "2h 15m", "~3 days", "~2 weeks").

**Implementation:**
```typescript
export function formatDuration(secs: number) {
  if (secs <= 0) return ""
  if (secs < 60) return `${secs}s`
  if (secs < 3600) {
    const mins = Math.floor(secs / 60)
    const remaining = secs % 60
    return remaining > 0 ? `${mins}m ${remaining}s` : `${mins}m`
  }
  // ... continues for hours, days, weeks
}
```

**Used by:**
- `server/instance.ts` -- Displaying server uptime
- `project/bootstrap.ts` -- Project initialization timing
- `format/index.ts` -- Format tool output
- `tool/write.ts`, `tool/edit.ts`, `tool/apply_patch.ts` -- Tool execution timing

**IMPORTANT -- Overlap with `Locale.duration`:** There are TWO duration formatters:
- `format.ts` `formatDuration(secs)` -- takes SECONDS as input
- `locale.ts` `Locale.duration(ms)` -- takes MILLISECONDS as input
These are NOT interchangeable. Check the input unit.

---

### `git.ts` -- Git command runner

**What it does:** Runs git commands via `Process.run` with stdin ignored (avoids pipe inheritance issues).

**Implementation:**
```typescript
export async function git(args: string[], opts: { cwd: string; env?: Record<string, string> }): Promise<GitResult> {
  return Process.run(["git", ...args], {
    cwd: opts.cwd,
    env: opts.env,
    stdin: "ignore",
    nothrow: true,
  })
    .then((result) => ({
      exitCode: result.code,
      text: () => result.stdout.toString(),
      stdout: result.stdout,
      stderr: result.stderr,
    }))
    .catch((error) => ({
      exitCode: 1,
      text: () => "",
      stdout: Buffer.alloc(0),
      stderr: Buffer.from(error instanceof Error ? error.message : String(error)),
    }))
}
```

**Used by:** 5 files:
- `storage/storage.ts` -- Git root detection for project ID migration
- `file/watcher.ts` -- Git status checks
- `file/index.ts` -- File tracking via git
- `cli/cmd/pr.ts` -- PR operations
- `cli/cmd/github.ts` -- GitHub operations

**Real call pattern:**
```typescript
const result = await git(["rev-list", "--max-parents=0", "--all"], { cwd: worktree })
const [id] = result.text().split("\n").filter(Boolean).map(x => x.trim()).toSorted()
```

**When NOT to use:** For Effect-based child processes, use the `cross-spawn-spawner.ts` layer. The `git()` helper is for vanilla async code only. Also note: it always uses `nothrow: true` and returns exitCode -- callers must check `result.exitCode` themselves.

---

### `glob.ts` -- File globbing wrapper

**What it does:** Wraps the `glob` and `minimatch` packages with a simplified API.

**Implementation:**
```typescript
export namespace Glob {
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

**Used by:** 31 files (one of the most used utilities). Internal users include `filesystem.ts`, `log.ts`. External users span nearly every module: tool, storage, snapshot, skill, session, server, provider, mcp, lsp, file, config, cli, bus, bun, auth, worktree, index.ts.

**Real call pattern:**
```typescript
// Find files
const matches = await Glob.scan("**/*.ts", { cwd: projectDir, include: "file", dot: true })

// Check if a path matches a pattern
if (Glob.match("*.test.ts", filepath)) { /* ... */ }

// Sync version for startup/config
const files = Glob.scanSync("*.json", { cwd: configDir })
```

**When NOT to use:** For simple filename extension checks, use `path.extname()`. For directory listing without patterns, use `fs.readdir`. Glob is for actual pattern matching scenarios.

---

### `hash.ts` -- Fast SHA-1 hashing

**What it does:** SHA-1 hash of string or Buffer input, returned as hex.

**Implementation:**
```typescript
export namespace Hash {
  export function fast(input: string | Buffer): string {
    return createHash("sha1").update(input).digest("hex")
  }
}
```

**Used by:**
- `util/flock.ts` (internal) -- Hashing lock keys to filesystem-safe filenames
- `snapshot/index.ts` -- Content-addressable snapshot storage

**ANTI-PATTERN:** `server/instance.ts` uses `createHash("sha256")` directly instead of `Hash.fast()`. This is CORRECT because it needs SHA-256 (not SHA-1) and base64 output (not hex). `Hash.fast` is intentionally SHA-1 for speed in non-security contexts.

---

### `iife.ts` -- Immediately invoked function expression helper

**What it does:** Executes a function immediately and returns its result. A type-safe way to use complex expressions where a simple value is expected.

**Implementation:**
```typescript
export function iife<T>(fn: () => T) {
  return fn()
}
```

**Used by:** 13 files:
- `storage/db.ts` -- Computing `Database.Path` with conditional logic
- `tool/task.ts`, `tool/skill.ts` -- Complex initialization expressions
- `session/retry.ts`, `session/prompt.ts`, `session/message-v2.ts`, `session/index.ts` -- Inline computed values
- `provider/transform.ts`, `provider/provider.ts`, `provider/error.ts` -- Provider configuration
- `project/instance.ts` -- Instance path computation
- `plugin/copilot.ts` -- Copilot configuration
- `config/config.ts` -- Config path resolution

**Real call pattern:**
```typescript
export const Path = iife(() => {
  if (Flag.OPENCODE_DB) {
    if (Flag.OPENCODE_DB === ":memory:" || path.isAbsolute(Flag.OPENCODE_DB)) return Flag.OPENCODE_DB
    return path.join(Global.Path.data, Flag.OPENCODE_DB)
  }
  return getChannelPath()
})
```

**When NOT to use:** For truly trivial expressions, just use the expression directly. `iife` adds readability for multi-line conditional initialization -- do not use it for single-line assignments.

---

### `keybind.ts` -- Keyboard binding parsing and matching

**What it does:** Parses keybinding strings (like "ctrl+shift+p", "\<leader\> a"), matches key events against bindings, and converts back to display strings.

**Implementation:** ~100 lines. Handles ctrl, alt/meta/option, shift, super, leader prefix, special keys (esc->escape, del->delete, space).

**Used by:**
- `cli/cmd/tui/component/textarea-keybindings.ts` -- TUI keybinding configuration

**When NOT to use:** TUI-specific. Not needed for non-TUI code.

---

### `lazy.ts` -- Lazy evaluation with reset

**What it does:** Creates a lazily-evaluated value that caches on first call. Supports `reset()` to invalidate the cache. Does NOT cache on error.

**Implementation:**
```typescript
export function lazy<T>(fn: () => T) {
  let value: T | undefined
  let loaded = false

  const result = (): T => {
    if (loaded) return value as T
    try {
      value = fn()
      loaded = true
      return value as T
    } catch (e) {
      throw e  // Don't mark as loaded if initialization failed
    }
  }

  result.reset = () => {
    loaded = false
    value = undefined
  }

  return result
}
```

**Used by:** 6 files:
- `storage/db.ts` -- `Database.Client = lazy(() => { ... })` with `Client.reset()` used in `close()`
- `storage/storage.ts` -- `state = lazy(async () => { ... })`
- `tool/bash.ts` -- Lazy tree-sitter language loading
- `shell/shell.ts` -- `Shell.preferred = lazy(() => ...)`, `Shell.acceptable = lazy(() => ...)`
- `provider/models.ts` -- Lazy model list initialization
- `file/watcher.ts` -- Lazy watcher initialization

**Real call pattern:**
```typescript
// Define lazy value
export const Client = lazy(() => {
  const db = init(Path)
  db.run("PRAGMA journal_mode = WAL")
  return db
})

// Use (initializes on first call)
Client().run("SELECT 1")

// Reset (for cleanup/testing)
Client.reset()
```

**Key behavior:** The `reset()` method is critical for `Database.close()` -- it allows re-initialization after closing. Also: lazy does NOT cache failures -- if the factory throws, next call will retry.

**When NOT to use:** For Effect-based code, use Effect's `ScopedCache` (as used in `InstanceState`). For values that need async initialization, `lazy` works but the returned function becomes `() => Promise<T>` -- which is fine (see `storage.ts`).

---

### `locale.ts` -- Locale-aware formatting utilities

**What it does:** String formatting: titlecase, time/datetime display, number abbreviation (K/M), duration (milliseconds), truncation (start/middle), pluralization.

**Implementation:** ~80 lines covering:
- `titlecase(str)` -- Word-initial capitalization
- `time(ms)` -- Short time string from epoch ms
- `datetime(ms)` -- Full date+time from epoch ms
- `todayTimeOrDateTime(ms)` -- Show time only if today, else full datetime
- `number(num)` -- "1.2K", "3.4M"
- `duration(ms)` -- "150ms", "3.2s", "5m 20s" (INPUT IS MILLISECONDS)
- `truncate(str, len)` -- Truncate with ellipsis at end
- `truncateMiddle(str, max)` -- Truncate with ellipsis in middle
- `pluralize(count, singular, plural)` -- Template-based pluralization with `{}` placeholder

**Used by:**
- `cli/cmd/tui/util/transcript.ts` -- Session transcript formatting

**IMPORTANT -- Overlap with `format.ts`:** `Locale.duration(ms)` takes MILLISECONDS. `formatDuration(secs)` takes SECONDS. Do not confuse them.

**When NOT to use:** For server/API responses, use raw values and let the client format. These helpers are for TUI/CLI display.

---

### `lock.ts` -- In-process read/write lock

**What it does:** In-memory reader-writer lock with writer priority. Returns `Disposable` for `using` syntax.

**Implementation:**
```typescript
export namespace Lock {
  export async function read(key: string): Promise<Disposable> {
    const lock = get(key)
    return new Promise((resolve) => {
      if (!lock.writer && lock.waitingWriters.length === 0) {
        lock.readers++
        resolve({ [Symbol.dispose]: () => { lock.readers--; process(key) } })
      } else {
        lock.waitingReaders.push(() => { /* ... */ })
      }
    })
  }

  export async function write(key: string): Promise<Disposable> {
    // Similar, but exclusive access
  }
}
```

**Used by:**
- `storage/storage.ts` -- All read/write operations use `Lock.read(target)` / `Lock.write(target)`

**Real call pattern:**
```typescript
// Read lock (multiple readers allowed)
using _ = await Lock.read(target)
const result = await Filesystem.readJson<T>(target)

// Write lock (exclusive)
using _ = await Lock.write(target)
await Filesystem.writeJson(target, content)
```

**Key behavior:** Writer priority prevents reader starvation. Locks auto-cleanup when no waiters remain.

**When NOT to use:** This is in-PROCESS only. For cross-process locking, use `Flock`. Also: key is a string, so callers must choose consistent keys (Storage uses the file path as key).

---

### `log.ts` -- Structured file-based logging

**What it does:** Creates tagged loggers that write to a log file (or stderr in print mode). Supports levels (DEBUG/INFO/WARN/ERROR), tags, cloning, and timed operations.

**Implementation:** ~180 lines. Features:
- Service-keyed logger caching (same service name returns same logger)
- Auto-cleanup of old log files (keeps last 10)
- Delta timing between log entries
- `log.time(msg)` returns disposable timer for measuring operations

**Used by:** 70 files (the single most-used utility). Every module in the codebase uses logging.

**Real call pattern:**
```typescript
const log = Log.create({ service: "session" })

log.info("starting prompt", { sessionID })
log.error("prompt failed", { error: errorData(e) })

// Timed operation
using timer = log.time("compaction")
await doCompaction()
// timer auto-stops on scope exit, logs duration
```

**When NOT to use:** Always use `Log.create` -- never use `console.log` in production code. The only exception is `fn.ts` which uses `console.trace` and `console.error` for schema validation failures (these are developer-facing debugging aids).

---

### `network.ts` -- Network status checks

**What it does:** Two functions: `online()` checks navigator.onLine, `proxied()` checks HTTP proxy env vars.

**Implementation:**
```typescript
export function online() {
  const nav = globalThis.navigator
  if (!nav || typeof nav.onLine !== "boolean") return true
  return nav.onLine
}

export function proxied() {
  return !!(process.env.HTTP_PROXY || process.env.HTTPS_PROXY || process.env.http_proxy || process.env.https_proxy)
}
```

**Used by:** 6 files:
- `config/config.ts` -- Proxy-aware HTTP configuration
- `cli/cmd/web.ts`, `cli/cmd/serve.ts`, `cli/cmd/acp.ts` -- Network-dependent features
- `bun/registry.ts`, `bun/index.ts` -- Bun-specific network checks

---

### `process.ts` -- Cross-platform child process management

**What it does:** Spawns child processes with cross-platform support (uses `cross-spawn`). Provides `spawn()` (raw), `run()` (capture output), `text()` (string output), `lines()` (split output), and `stop()` (Windows taskkill support).

**Implementation:** ~170 lines. Key features:
- `cross-spawn` for reliable Windows command resolution
- Abort signal support with SIGTERM -> SIGKILL escalation
- `nothrow` option to return exit code instead of throwing
- `windowsHide` for invisible Windows processes
- `RunFailedError` with cmd, code, stdout, stderr

**Used by:** 10 files:
- `util/git.ts` (internal) -- Git command execution
- `util/archive.ts` (internal) -- Zip extraction
- `session/prompt.ts`, `session/compaction.ts` -- Process spawning for tool execution
- `ide/index.ts` -- IDE integration
- `config/config.ts` -- Config tool execution
- `cli/cmd/tui/util/editor.ts` -- Editor launching
- `cli/cmd/tui/plugin/runtime.ts` -- Plugin process management
- `cli/cmd/pr.ts`, `cli/cmd/github.ts` -- Git/GitHub CLI commands

**Real call pattern:**
```typescript
// Run and capture output
const result = await Process.run(["git", "status"], { cwd: projectDir, nothrow: true })
if (result.code === 0) {
  const output = result.stdout.toString()
}

// Get text directly
const { text } = await Process.text(["git", "branch", "--show-current"], { cwd })

// Get lines
const branches = await Process.lines(["git", "branch", "-a"], { cwd })

// Spawn with abort
const child = Process.spawn(["node", "server.js"], { abort: controller.signal })
await child.exited
```

**When NOT to use:** For Effect-based process spawning, use the `cross-spawn-spawner.ts` layer which integrates with Effect's resource management. `Process` is for vanilla async code.

---

### `queue.ts` -- Async queue and concurrent work

**What it does:** Two utilities: `AsyncQueue<T>` (push/pull async queue implementing `AsyncIterable`) and `work()` (bounded-concurrency worker pool).

**Implementation:**
```typescript
export class AsyncQueue<T> implements AsyncIterable<T> {
  private queue: T[] = []
  private resolvers: ((value: T) => void)[] = []

  push(item: T) {
    const resolve = this.resolvers.shift()
    if (resolve) resolve(item)
    else this.queue.push(item)
  }

  async *[Symbol.asyncIterator]() {
    while (true) yield await this.next()
  }
}

export async function work<T>(concurrency: number, items: T[], fn: (item: T) => Promise<void>) {
  const pending = [...items]
  await Promise.all(
    Array.from({ length: concurrency }, async () => {
      while (true) {
        const item = pending.pop()
        if (item === undefined) return
        await fn(item)
      }
    }),
  )
}
```

**Used by:**
- `server/routes/global.ts` -- Async queue for server events

**When NOT to use:** For Effect-based concurrency, use Effect's `Stream`, `PubSub`, or `Queue`. The `AsyncQueue` is for vanilla JS async iteration patterns.

---

### `record.ts` -- Type guard for plain objects

**What it does:** Checks if a value is a non-null, non-array object.

**Implementation:**
```typescript
export function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value)
}
```

**Used by:**
- `util/error.ts` (internal) -- Used in `errorMessage` and `errorData`
- `plugin/shared.ts` -- Plugin data validation
- `config/tui.ts` -- TUI config parsing
- `config/config.ts` -- Config value validation
- `cli/cmd/tui/plugin/runtime.ts` -- Plugin message parsing

---

### `rpc.ts` -- Worker thread RPC protocol

**What it does:** Simple JSON-based RPC for communicating between main thread and workers. Provides `listen()` (worker side), `emit()` (worker events), and `client()` (main thread side).

**Implementation:** ~65 lines. Uses `postMessage`/`onmessage` with JSON serialization. Supports request/response (`rpc.request`/`rpc.result`) and events (`rpc.event`).

**Used by:**
- `cli/cmd/tui/worker.ts` -- TUI background worker
- `cli/cmd/tui/thread.ts` -- TUI main thread client

**Real call pattern:**
```typescript
// Worker side
Rpc.listen({
  async doSomething(input) { return result }
})
Rpc.emit("progress", { percent: 50 })

// Main thread side
const client = Rpc.client<WorkerDef>(worker)
const result = await client.call("doSomething", { data })
client.on("progress", (data) => { /* ... */ })
```

---

### `schema.ts` -- Effect Schema helpers (withStatics, Newtype)

**What it does:** Two helpers for Effect Schema:
1. `withStatics` -- Attaches static methods to a schema via `.pipe()`
2. `Newtype` -- Creates nominal/branded scalar types that are also valid schemas

**Implementation:**
```typescript
export const withStatics =
  <S extends object, M extends Record<string, unknown>>(methods: (schema: S) => M) =>
  (schema: S): S & M =>
    Object.assign(schema, methods(schema))

export function Newtype<Self>() {
  return <const Tag extends string, S extends Schema.Top>(tag: Tag, schema: S) => {
    abstract class Base {
      static makeUnsafe(value: Schema.Schema.Type<S>): Self { return value as unknown as Self }
    }
    Object.setPrototypeOf(Base, schema)
    return Base as unknown as /* ... branded type ... */
  }
}
```

**Used by (`withStatics`):** 9 files -- every schema file that defines branded IDs:
- `session/schema.ts` -- SessionID, MessageID, PartID
- `sync/schema.ts` -- EventID
- `tool/schema.ts` -- ToolCallID
- `pty/schema.ts` -- PtyID
- `provider/schema.ts` -- ProviderID
- `project/schema.ts` -- ProjectID
- `control-plane/schema.ts` -- WorkspaceID
- `account/schema.ts` -- AccountID

**Used by (`Newtype`):** 3 files:
- `question/schema.ts` -- QuestionID
- `permission/schema.ts` -- PermissionID
- `util/schema.ts` (definition)

**Real call pattern:**
```typescript
// withStatics: attach factory methods to a branded schema
export const SessionID = Schema.String.pipe(
  Schema.brand("SessionID"),
  withStatics((s) => ({
    descending: (id?: string) => s.makeUnsafe(Identifier.descending("session", id)),
    zod: Identifier.schema("session").pipe(z.custom<Schema.Schema.Type<typeof s>>()),
  })),
)

// Newtype: create a nominal type that IS a schema
class QuestionID extends Newtype<QuestionID>()("QuestionID", Schema.String) {
  static make(id: string): QuestionID { return this.makeUnsafe(id) }
}
```

---

### `scrap.ts` -- Scratch/dummy file (NOT a real utility)

**What it does:** Contains dummy exports (`foo`, `bar`, `dummyFunction`, `randomHelper`). This is a scratch file.

**Used by:**
- `cli/cmd/debug/index.ts` -- Debug command imports for testing

**When NOT to use:** NEVER use in production code. This file exists only for development/debugging.

---

### `signal.ts` -- One-shot signal/trigger

**What it does:** Creates a promise-based signal that can be triggered once.

**Implementation:**
```typescript
export function signal() {
  let resolve: any
  const promise = new Promise((r) => (resolve = r))
  return {
    trigger() { return resolve() },
    wait() { return promise },
  }
}
```

**Used by:** No direct imports found.

**When NOT to use:** For Effect-based signals, use `Deferred`. For recurring events, use `EventEmitter` or `PubSub`.

---

### `timeout.ts` -- Promise timeout wrapper

**What it does:** Races a promise against a timeout, rejecting with a descriptive error on timeout.

**Implementation:**
```typescript
export function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  let timeout: NodeJS.Timeout
  return Promise.race([
    promise.then((result) => { clearTimeout(timeout); return result }),
    new Promise<never>((_, reject) => {
      timeout = setTimeout(() => reject(new Error(`Operation timed out after ${ms}ms`)), ms)
    }),
  ])
}
```

**Used by:**
- `mcp/index.ts` -- MCP server connection timeout
- `cli/cmd/tui/thread.ts` -- TUI operation timeout

**When NOT to use:** For abort-based timeouts (where you need to cancel the underlying operation, not just the wait), use `abortAfter`. `withTimeout` only races -- it does NOT cancel the original promise.

---

### `token.ts` -- LLM token estimation

**What it does:** Estimates token count using the 4-chars-per-token heuristic.

**Implementation:**
```typescript
export namespace Token {
  const CHARS_PER_TOKEN = 4
  export function estimate(input: string) {
    return Math.max(0, Math.round((input || "").length / CHARS_PER_TOKEN))
  }
}
```

**Used by:**
- `session/compaction.ts` -- Estimating message token costs for compaction decisions

---

### `update-schema.ts` -- Make all Zod object fields optional+nullable

**What it does:** Transforms a Zod object schema so every field becomes `optional(nullable(T))`. Useful for PATCH/update operations.

**Implementation:**
```typescript
export function updateSchema<T extends z.ZodRawShape>(schema: z.ZodObject<T>) {
  const next = {} as { [K in keyof T]: z.ZodOptional<z.ZodNullable<T[K]>> }
  for (const [k, v] of Object.entries(schema.required().shape)) {
    next[k] = v.nullable() as unknown as (typeof next)[typeof k]
  }
  return z.object(next)
}
```

**Used by:** No direct imports found (infrastructure for PATCH endpoints).

---

### `which.ts` -- Cross-platform command path resolution

**What it does:** Finds the full path of a command, checking PATH plus the global bin directory.

**Implementation:**
```typescript
export function which(cmd: string, env?: NodeJS.ProcessEnv) {
  const base = env?.PATH ?? env?.Path ?? process.env.PATH ?? process.env.Path ?? ""
  const full = base ? base + path.delimiter + Global.Path.bin : Global.Path.bin
  const result = whichPkg.sync(cmd, {
    nothrow: true,
    path: full,
    pathExt: env?.PATHEXT ?? env?.PathExt ?? process.env.PATHEXT ?? process.env.PathExt,
  })
  return typeof result === "string" ? result : null
}
```

**Used by:**
- `shell/shell.ts` -- Finding shell executables

---

### `wildcard.ts` -- Wildcard pattern matching for permissions

**What it does:** Matches strings against wildcard patterns (`*` = any, `?` = single char). Includes `all()` for finding the best-matching pattern from a sorted set, and `allStructured()` for matching command head + args.

**Implementation:** ~60 lines. Features:
- Case-insensitive on Windows
- `"ls *"` pattern matches both `"ls"` and `"ls -la"` (trailing wildcard is optional)
- Patterns sorted by length (shortest first), last match wins (most specific)

**Used by:**
- `permission/index.ts` -- Command permission matching
- `permission/evaluate.ts` -- Permission evaluation

**Real call pattern:**
```typescript
// Simple match
Wildcard.match("git commit *", "git commit -m 'fix'") // true

// Find matching permission from ruleset
const permission = Wildcard.all("git push origin main", {
  "git *": "allow",
  "git push *": "deny",
}) // returns "deny" (longer/more specific pattern wins)
```

---

## Non-util Helpers

### `effect/instance-state.ts` -- Per-project-instance state cache

**What it does:** Creates a `ScopedCache` keyed by project directory. Each project instance gets its own lazily-initialized state. Automatically invalidates when an instance is disposed.

**Implementation:**
```typescript
export namespace InstanceState {
  export const make = <A, E = never, R = never>(
    init: (ctx: InstanceContext) => Effect.Effect<A, E, R | Scope.Scope>,
  ): Effect.Effect<InstanceState<A, E, Exclude<R, Scope.Scope>>, never, R | Scope.Scope> =>
    Effect.gen(function* () {
      const cache = yield* ScopedCache.make<string, A, E, R>({
        capacity: Number.POSITIVE_INFINITY,
        lookup: () => init(Instance.current),
      })
      const off = registerDisposer((directory) => Effect.runPromise(ScopedCache.invalidate(cache, directory)))
      yield* Effect.addFinalizer(() => Effect.sync(off))
      return { [TypeId]: TypeId, cache }
    })

  export const get = <A, E, R>(self: InstanceState<A, E, R>) =>
    Effect.suspend(() => ScopedCache.get(self.cache, Instance.directory))

  export const use = <A, E, R, B>(self: InstanceState<A, E, R>, select: (value: A) => B) =>
    Effect.map(get(self), select)

  export const useEffect = <A, E, R, B, E2, R2>(
    self: InstanceState<A, E, R>,
    select: (value: A) => Effect.Effect<B, E2, R2>,
  ) => Effect.flatMap(get(self), select)

  export const has = /* ... */
  export const invalidate = /* ... */
}
```

**Used by:** 20 files (core infrastructure):
- `tool/registry.ts` -- Tool state per project
- `snapshot/index.ts` -- Snapshot state per project
- `skill/index.ts` -- Skill state per project
- `session/status.ts` -- Session status per project
- `question/index.ts` -- Question state per project
- `pty/index.ts` -- PTY state per project
- `provider/auth.ts` -- Provider auth per project
- `project/vcs.ts` -- VCS state per project
- `plugin/index.ts` -- Plugin state per project
- `permission/index.ts` -- Permission state per project
- `mcp/index.ts` -- MCP state per project
- `lsp/index.ts` -- LSP state per project
- `format/index.ts` -- Format state per project
- `file/watcher.ts`, `file/time.ts`, `file/index.ts` -- File state per project
- `config/config.ts` -- Config state per project
- `command/index.ts` -- Command state per project
- `bus/index.ts` -- Bus state per project
- `agent/agent.ts` -- Agent state per project

**Real call pattern:**
```typescript
// In layer definition
const state = yield* InstanceState.make<MyState>(
  Effect.fn("MyModule.state")(function* (ctx) {
    // Initialize per-instance state
    return { /* ... */ }
  }),
)

// In service methods
const s = yield* InstanceState.get(state)
```

---

### `effect/run-service.ts` -- Service runtime factory

**What it does:** Creates a managed runtime for an Effect service, providing `runSync`, `runPromise`, `runFork`, and `runCallback` that automatically resolve the service from its layer.

**Implementation:**
```typescript
export const memoMap = Layer.makeMemoMapUnsafe()

export function makeRuntime<I, S, E>(service: ServiceMap.Service<I, S>, layer: Layer.Layer<I, E>) {
  let rt: ManagedRuntime.ManagedRuntime<I, E> | undefined
  const getRuntime = () => (rt ??= ManagedRuntime.make(layer, { memoMap }))
  return {
    runSync: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => getRuntime().runSync(service.use(fn)),
    runPromise: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>, options?: Effect.RunOptions) =>
      getRuntime().runPromise(service.use(fn), options),
    runFork: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => getRuntime().runFork(service.use(fn)),
    runCallback: <A, Err>(fn: (svc: S) => Effect.Effect<A, Err, I>) => getRuntime().runCallback(service.use(fn)),
  }
}
```

**Used by:** 27 files -- every service module uses this at the bottom to export its public API:
- `session/status.ts`, `mcp/auth.ts`, `question/index.ts`, `format/index.ts`, `account/index.ts`, `tool/truncate.ts`, `auth/index.ts`, `tool/registry.ts`, `permission/index.ts`, `config/config.ts`, `mcp/index.ts`, `command/index.ts`, `bus/index.ts`, `project/project.ts`, `project/vcs.ts`, `agent/agent.ts`, `lsp/index.ts`, `pty/index.ts`, `skill/index.ts`, `provider/auth.ts`, `snapshot/index.ts`, `file/time.ts`, `file/index.ts`, `file/watcher.ts`, `worktree/index.ts`, `plugin/index.ts`, `installation/index.ts`

**Real call pattern:**
```typescript
// At bottom of service module
const { runPromise } = makeRuntime(Service, defaultLayer)

// Exported as public API
export async function get(id: string) {
  return runPromise((svc) => svc.get(id))
}
```

**Key behavior:** The shared `memoMap` ensures services are only initialized once across the entire application, even when multiple modules depend on the same service.

---

### `effect/instance-registry.ts` -- Instance disposal coordination

**What it does:** Maintains a set of disposer callbacks that run when a project instance is disposed.

**Implementation:**
```typescript
const disposers = new Set<(directory: string) => Promise<void>>()

export function registerDisposer(disposer: (directory: string) => Promise<void>) {
  disposers.add(disposer)
  return () => { disposers.delete(disposer) }
}

export async function disposeInstance(directory: string) {
  await Promise.allSettled([...disposers].map((disposer) => disposer(directory)))
}
```

**Used by:**
- `effect/instance-state.ts` (internal) -- Registers cache invalidation
- `project/instance.ts` -- Calls `disposeInstance` during cleanup

---

### `effect/cross-spawn-spawner.ts` -- Effect-native process spawner

**What it does:** Provides an Effect `ChildProcessSpawner` layer that uses `cross-spawn` for cross-platform child process management. Handles piped commands, stdio configuration, process groups, Windows-specific taskkill, and resource cleanup.

**Implementation:** ~480 lines. Full Effect-native replacement for Node.js `child_process.spawn` with:
- Proper resource management via `Effect.acquireRelease`
- Process group killing (negative PID on Unix, taskkill on Windows)
- Piped command chains
- Additional file descriptors
- Overlapped pipes on Windows

**Used by:** 6 files:
- `worktree/index.ts`, `snapshot/index.ts` -- Git operations via Effect
- `project/vcs.ts`, `project/project.ts` -- VCS operations
- `mcp/index.ts` -- MCP server process management
- `installation/index.ts` -- Self-update process

---

### `id/id.ts` -- Monotonic ID generation

**What it does:** Generates sortable, prefixed IDs with time-based ordering (ascending or descending). Uses a prefix registry for type safety.

**Implementation:** ~85 lines. Features:
- Prefixes: evt, ses, msg, per, que, usr, prt, pty, tool, wrk
- Monotonic: same-millisecond IDs get incrementing counters
- Descending: bitwise NOT of timestamp for reverse-chronological sorting
- Random suffix: base62 for uniqueness
- `timestamp(id)` extracts creation time from ascending IDs

**Used by:** 10 files -- every schema file that defines an entity ID:
- `session/schema.ts` -- SessionID (descending), MessageID (ascending), PartID (ascending)
- `sync/schema.ts` -- EventID (ascending)
- `tool/schema.ts` -- ToolCallID (ascending)
- `pty/schema.ts` -- PtyID (ascending)
- `provider/schema.ts` -- (uses Identifier.schema for validation)
- `project/schema.ts` -- ProjectID
- `control-plane/schema.ts` -- WorkspaceID (ascending)
- `permission/schema.ts` -- PermissionID (ascending)
- `question/schema.ts` -- QuestionID (ascending)
- `account/schema.ts` -- AccountID

**Real call pattern:**
```typescript
// In schema definition
export const SessionID = Schema.String.pipe(
  Schema.brand("SessionID"),
  withStatics((s) => ({
    descending: (id?: string) => s.makeUnsafe(Identifier.descending("session", id)),
  })),
)

// Generate a new ID
const id = SessionID.descending()

// Extract timestamp
const created = Identifier.timestamp(id)
```

**When NOT to use:** SessionIDs are DESCENDING (newest first in sorted order). All other IDs are ASCENDING. Do not mix these up -- it determines database query ordering.

---

### `bus/bus-event.ts` -- Event type definition registry

**What it does:** Defines typed event definitions for the pub/sub bus. Maintains a global registry for schema generation.

**Implementation:**
```typescript
export namespace BusEvent {
  export type Definition = ReturnType<typeof define>
  const registry = new Map<string, Definition>()

  export function define<Type extends string, Properties extends ZodType>(type: Type, properties: Properties) {
    const result = { type, properties }
    registry.set(type, result)
    return result
  }

  export function payloads() {
    return z.discriminatedUnion("type", /* all registered events */)
  }
}
```

**Used by:** 25+ files define events. Every module that publishes events uses `BusEvent.define`:
- `session/index.ts` -- Diff, Error events
- `session/message-v2.ts` -- PartDelta
- `session/compaction.ts` -- Compacted
- `session/status.ts` -- Status, Idle
- `session/todo.ts` -- Updated
- `question/index.ts` -- Asked, Replied, Rejected
- `permission/index.ts` -- Asked, Replied
- `pty/index.ts` -- Created, Updated, Exited, Deleted
- `file/index.ts` -- Edited
- `file/watcher.ts` -- Updated
- `lsp/index.ts` -- Updated; `lsp/client.ts` -- Diagnostics
- `mcp/index.ts` -- ToolsChanged, BrowserOpenFailed
- `worktree/index.ts` -- Ready, Failed
- `installation/index.ts` -- Updated, UpdateAvailable
- `ide/index.ts` -- Installed
- `command/index.ts` -- Executed
- `project/vcs.ts` -- BranchUpdated
- `project/project.ts` -- Updated
- `control-plane/workspace.ts` -- Ready, Failed
- `server/event.ts` -- Connected, Disposed
- `server/routes/global.ts` -- GlobalDisposedEvent
- `cli/cmd/tui/event.ts` -- PromptAppend, CommandExecute, ToastShow, SessionSelect
- `bus/index.ts` -- InstanceDisposed

---

### `bus/index.ts` -- Effect-based pub/sub event bus

**What it does:** Full publish/subscribe system built on Effect's `PubSub`. Per-instance state, typed subscriptions, wildcard subscriptions, and callback-based subscriptions.

**Key API:**
```typescript
Bus.publish(EventDef, properties)
Bus.subscribe(EventDef, callback)
Bus.subscribeAll(callback)
```

**Used by:** The same 25+ modules that define events also subscribe to events.

---

### `sync/index.ts` -- Event sourcing / CQRS system

**What it does:** Defines versioned, aggregated events with projectors. Events are stored in SQLite, replayed for state reconstruction, and published to the bus.

**Used by:**
- `session/message-v2.ts` -- Message events (Created, Updated, Deleted, etc.)
- `session/index.ts` -- Session events (Created, Updated, Deleted, etc.)

---

### `storage/db.ts` -- SQLite database management

**What it does:** Manages the SQLite database: connection, migrations, transactions, context-based connection sharing.

**Key features:**
- Uses `lazy()` for connection initialization with `reset()` for cleanup
- Uses `Context.create()` for transaction propagation
- `Database.use(cb)` -- auto-wraps in context or creates new one
- `Database.transaction(cb)` -- explicit transaction with context nesting
- `Database.effect(fn)` -- deferred side-effects that run after transaction commits
- `iife()` for computing the database path

**Used by:** 25+ files -- everything that reads/writes persistent data.

---

## Usage Matrix

Which helpers are used by which major modules. Check marks indicate direct imports.

```
Helper              | session | tool | provider | project | permission | config | file | mcp | lsp | server | bus | snapshot | cli/tui | pty | question | skill | account | install | worktree | format | command
--------------------|---------|------|----------|---------|------------|--------|------|-----|-----|--------|----- |----------|---------|-----|----------|-------|---------|---------|----------|--------|--------
Log                 |   X     |  X   |    X     |   X     |     X      |   X    |  X   |  X  |  X  |   X    |  X  |    X     |   X     |  X  |    X     |   X   |         |    X    |    X     |   X    |   X
Glob                |   X     |  X   |    X     |         |            |   X    |  X   |     |  X  |   X    |     |    X     |   X     |     |          |   X   |         |         |    X     |        |
Filesystem          |         |  X   |          |   X     |            |   X    |      |     |     |   X    |     |          |   X     |     |          |   X   |         |         |          |   X    |
InstanceState       |         |  X   |    X     |   X     |     X      |   X    |  X   |  X  |  X  |        |  X  |    X     |         |  X  |    X     |   X   |         |         |    X     |   X    |   X
makeRuntime         |   X     |  X   |    X     |   X     |     X      |   X    |  X   |  X  |  X  |        |  X  |    X     |         |  X  |    X     |   X   |    X    |    X    |    X     |   X    |   X
BusEvent.define     |   X     |      |          |   X     |     X      |        |  X   |  X  |  X  |   X    |  X  |          |   X     |  X  |    X     |       |         |    X    |    X     |        |   X
Identifier          |   X     |  X   |    X     |   X     |     X      |        |      |     |     |        |     |          |         |  X  |    X     |       |    X    |         |          |        |
withStatics/schema  |   X     |  X   |    X     |   X     |     X      |        |      |     |     |        |     |          |         |  X  |    X     |       |    X    |         |    X     |        |
fn()                |   X     |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
iife()              |   X     |  X   |    X     |   X     |            |   X    |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
lazy()              |         |  X   |    X     |         |            |        |  X   |     |     |   X    |     |          |         |     |          |       |         |         |          |        |
Process             |         |      |          |   X     |            |   X    |      |     |     |        |     |          |   X     |     |          |       |         |         |          |   X    |
git()               |         |      |          |   X     |            |        |  X   |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
error               |   X     |      |          |         |            |   X    |      |     |     |   X    |     |          |   X     |     |          |       |         |         |          |        |
Context             |         |      |          |         |            |        |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
Lock                |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
Flock               |         |      |          |         |            |   X    |      |     |     |        |     |    X     |         |     |          |       |         |         |          |        |
Wildcard            |         |      |          |         |     X      |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
Hash                |         |      |          |         |            |        |      |     |     |        |     |    X     |         |     |          |       |         |         |          |        |
Rpc                 |         |      |          |         |            |        |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
defer()             |         |  X   |          |         |            |        |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
signal()            |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
AsyncQueue/work     |         |      |          |         |            |        |      |     |     |   X    |     |          |         |     |          |       |         |         |          |        |
withTimeout         |         |      |          |         |            |        |      |  X  |     |        |     |          |   X     |     |          |       |         |         |          |        |
Token               |   X     |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
data-url            |   X     |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
Locale              |         |      |          |         |            |        |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
formatDuration      |         |  X   |          |   X     |            |        |      |     |     |   X    |     |          |         |     |          |       |         |         |          |   X    |
Color               |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
Keybind             |         |      |          |         |            |        |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
network             |         |      |          |         |            |   X    |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
which               |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
isRecord            |         |      |          |         |            |   X    |      |     |     |        |     |          |   X     |     |          |       |         |         |          |        |
effect-http-client  |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |       |         |         |          |        |
effect-zod          |         |      |          |         |            |        |      |     |     |        |     |          |         |     |          |   X   |    X    |         |          |        |
cross-spawn-spawner |         |      |          |   X     |            |        |      |  X  |     |        |     |    X     |         |     |          |       |         |    X    |    X     |        |
Database            |   X     |  X   |    X     |   X     |     X      |        |      |     |  X  |   X    |     |          |         |     |    X     |       |    X    |    X    |    X     |        |   X
SyncEvent           |   X     |      |          |         |            |        |      |     |     |   X    |     |          |         |     |          |       |    X    |         |    X     |        |
```

---

## Anti-Patterns and Correct Avoidances

### ANTI-PATTERN: Direct `createHash` instead of `Hash.fast`

**Location:** `server/instance.ts:303`
```typescript
const hash = match ? createHash("sha256").update(match[2]).digest("base64") : ""
```

**Verdict: CORRECT avoidance.** `Hash.fast` uses SHA-1 and hex output. This site needs SHA-256 and base64. The helper does not fit.

---

### ANTI-PATTERN: Direct `new AbortController()` without `abortAfter`

**Locations:** `session/prompt.ts` (4 sites), `provider/provider.ts`, `acp/agent.ts`, `cli/cmd/tui/worker.ts`, `control-plane/workspace.ts`, `cli/cmd/tui/plugin/runtime.ts`

**Verdict: CORRECT avoidance.** These are lifecycle controllers that are manually aborted on cancellation, not timeout-based. `abortAfter` is specifically for time-bounded abort and would leak timers if used for lifecycle management.

**One potential anti-pattern:** `provider/provider.ts` creates an AbortController for chunk timeout:
```typescript
const chunkAbortCtl = typeof chunkTimeout === "number" && chunkTimeout > 0 ? new AbortController() : undefined
```
This IS timeout-based -- it could use `abortAfter(chunkTimeout)`. However, the timeout is reset per-chunk (not a single timeout), so the manual approach is actually correct here.

---

### ANTI-PATTERN: Direct `existsSync` instead of `Filesystem.exists`

**Locations:** `storage/json-migration.ts`, `storage/db.ts`, `config/tui.ts`, `config/config.ts`, `cli/cmd/tui/attach.ts`

**Verdict: MIXED.**
- `storage/db.ts` and `config/config.ts` use `existsSync` during synchronous initialization (e.g., inside `lazy()` or `iife()`) where `Filesystem.exists` (which is async-wrapped but sync internally) would require unnecessary awaiting. **Correct avoidance.**
- `config/tui.ts` and `cli/cmd/tui/attach.ts` use `existsSync` in contexts where async is fine -- these COULD use `Filesystem.exists` but the difference is negligible since `Filesystem.exists` internally calls `existsSync` anyway.

---

### ANTI-PATTERN: `new AsyncLocalStorage` instead of `Context.create`

**Verdict: No violation found.** The only `new AsyncLocalStorage` is inside `Context.create` itself.

---

### ANTI-PATTERN: Manual lazy initialization instead of `lazy()`

**Verdict: No violation found.** The `let loaded = false` pattern only appears in `lazy.ts` itself.

---

### ANTI-PATTERN: `Promise.race` for timeout instead of `withTimeout`

**Verdict: No violation found.** The only `Promise.race` is inside `withTimeout` itself.

---

### ANTI-PATTERN: Manual `JSON.parse(await readFile(...))` instead of `Filesystem.readJson`

**Verdict: The only occurrence is inside `Filesystem.readJson` itself.** All external code uses the helper.

---

### ANTI-PATTERN: `Lock.read`/`Lock.write` are never imported directly

`Lock` is used ONLY by `storage/storage.ts`. This is correct -- Lock is the internal concurrency mechanism for the Storage layer. Other modules should use Storage's API (which handles locking internally) rather than Lock directly.

---

### ANTI-PATTERN: Two duration formatters

**`format.ts` `formatDuration(secs)` and `locale.ts` `Locale.duration(ms)`**

These take different units (seconds vs milliseconds) and have different output formats. They are NOT redundant -- `formatDuration` is for tool/server display (takes seconds), `Locale.duration` is for TUI display (takes milliseconds). However, this IS a footgun -- always check the input unit.

---

### ANTI-PATTERN: `scrap.ts` exists in production

`scrap.ts` contains dummy test functions. It is only imported by `cli/cmd/debug/index.ts`. This is acceptable as a development scratch file but should not be imported by any production code.

---

### ANTI-PATTERN: `signal()`, `abort.ts`, `archive.ts`, `update-schema.ts`, `color.ts` -- Defined but barely/never used

These utilities exist but have zero or near-zero direct imports in `src/`. They represent either:
1. Infrastructure for features not yet built
2. Utilities used by external consumers (SDK users)
3. Deprecated but not yet removed

An LLM should still USE these rather than reinvent them if the functionality matches.

---

### CORRECT PATTERN: Effect vs vanilla utility split

The codebase maintains a clean split:
- **Effect-based modules** use `InstanceState`, `makeRuntime`, `ServiceMap.Service`, `ScopedCache`, `PubSub`, `cross-spawn-spawner`
- **Vanilla async modules** use `Context.create`, `lazy`, `Lock`, `Flock`, `Process`, `Filesystem`, `git`

**Never cross these boundaries.** Do not use `Context.create` inside an Effect service. Do not use `InstanceState` outside of an Effect service.
