# Test Writing Reference

Real test code extracted from the opencode repo. Every snippet is copy-paste-ready. Read this file in full before writing any test.

---

## 1. Test Infrastructure

### 1.1 preload.ts -- Environment Setup Before ANY Imports

This file runs before every test file. Environment variables MUST be set before any `src/` imports because `xdg-basedir` reads them at import time and caches the result.

```ts
// test/preload.ts
import os from "os"
import path from "path"
import fs from "fs/promises"
import { setTimeout as sleep } from "node:timers/promises"
import { afterAll } from "bun:test"

// Create a per-process temp directory so parallel test workers never collide.
const dir = path.join(os.tmpdir(), "opencode-test-data-" + process.pid)
await fs.mkdir(dir, { recursive: true })

afterAll(async () => {
  // Dynamic import: if we imported Database at the top of the file, it
  // would trigger src/ module evaluation BEFORE the env vars below are set.
  const { Database } = await import("../src/storage/db")
  Database.close()

  // EBUSY retry: on Windows the SQLite WAL file handle can linger until
  // GC finalizers run. Bun.gc(true) forces a synchronous collection,
  // then we retry up to 30 times with 100ms gaps.
  const busy = (error: unknown) =>
    typeof error === "object" && error !== null && "code" in error && error.code === "EBUSY"
  const rm = async (left: number): Promise<void> => {
    Bun.gc(true)
    await sleep(100)
    return fs.rm(dir, { recursive: true, force: true }).catch((error) => {
      if (!busy(error)) throw error
      if (left <= 1) throw error
      return rm(left - 1)
    })
  }
  await rm(30)
})

// XDG overrides: redirect all XDG directories into the temp dir so tests
// never touch the real user home. These MUST be set before any src/ import.
process.env["XDG_DATA_HOME"] = path.join(dir, "share")
process.env["XDG_CACHE_HOME"] = path.join(dir, "cache")
process.env["XDG_CONFIG_HOME"] = path.join(dir, "config")
process.env["XDG_STATE_HOME"] = path.join(dir, "state")

// Point model resolution at a test fixture so tests don't need network.
process.env["OPENCODE_MODELS_PATH"] = path.join(import.meta.dir, "tool", "fixtures", "models-api.json")

// Isolate tests from the user's actual home directory.
const testHome = path.join(dir, "home")
await fs.mkdir(testHome, { recursive: true })
process.env["OPENCODE_TEST_HOME"] = testHome

// Isolate managed config so tests don't pollute each other.
const testManagedConfigDir = path.join(dir, "managed")
process.env["OPENCODE_TEST_MANAGED_CONFIG_DIR"] = testManagedConfigDir

// Disable default plugins to avoid side-effects.
process.env["OPENCODE_DISABLE_DEFAULT_PLUGINS"] = "true"

// Write the cache version file so the cache system doesn't clear on startup.
const cacheDir = path.join(dir, "cache", "opencode")
await fs.mkdir(cacheDir, { recursive: true })
await fs.writeFile(path.join(cacheDir, "version"), "14")

// Clear ALL provider API keys so no test accidentally hits a real API.
delete process.env["ANTHROPIC_API_KEY"]
delete process.env["OPENAI_API_KEY"]
delete process.env["GOOGLE_API_KEY"]
// ... (every provider key is deleted)
delete process.env["OPENCODE_SERVER_PASSWORD"]
delete process.env["OPENCODE_SERVER_USERNAME"]

// Use in-memory SQLite for speed and isolation.
process.env["OPENCODE_DB"] = ":memory:"

// NOW safe to import from src/.
const { Log } = await import("../src/util/log")
const { initProjectors } = await import("../src/server/projectors")

Log.init({ print: false, dev: true, level: "DEBUG" })
initProjectors()
```

Why each piece matters:
- **Per-process tmpdir** (`process.pid`): Bun runs test files in parallel workers. Without pid isolation, workers would stomp on each other's XDG directories.
- **Dynamic `import()` in afterAll**: Static `import` of `Database` at the top would trigger `src/` module evaluation before environment variables are set, causing `xdg-basedir` to read the real home directory.
- **EBUSY retry with `Bun.gc(true)`**: SQLite WAL mode keeps file handles open. On Windows, those handles survive until GC finalizers fire. The loop forces GC, waits 100ms, then retries -- up to 30 attempts.
- **`:memory:` SQLite**: Every test worker gets a fresh in-memory database. No cleanup needed, no file locking.
- **API key deletion**: Guarantees tests never hit real provider APIs, even if the developer has keys in their shell environment.

### 1.2 fixture/fixture.ts -- tmpdir and Instance Provision

```ts
// test/fixture/fixture.ts
import { $ } from "bun"
import * as fs from "fs/promises"
import os from "os"
import path from "path"
import { Effect, FileSystem, ServiceMap } from "effect"
import { ChildProcess, ChildProcessSpawner } from "effect/unstable/process"
import type { Config } from "../../src/config/config"
import { Instance } from "../../src/project/instance"

function sanitizePath(p: string): string {
  return p.replace(/\0/g, "")
}

type TmpDirOptions<T> = {
  git?: boolean
  config?: Partial<Config.Info>
  init?: (dir: string) => Promise<T>
  dispose?: (dir: string) => Promise<T>
}

export async function tmpdir<T>(options?: TmpDirOptions<T>) {
  const dirpath = sanitizePath(
    path.join(os.tmpdir(), "opencode-test-" + Math.random().toString(36).slice(2))
  )
  await fs.mkdir(dirpath, { recursive: true })

  // git: true creates a real git repo with sensible test defaults.
  // fsmonitor is disabled to avoid inotify/kqueue noise in CI.
  // An empty root commit ensures HEAD exists for snapshot/diff operations.
  if (options?.git) {
    await $`git init`.cwd(dirpath).quiet()
    await $`git config core.fsmonitor false`.cwd(dirpath).quiet()
    await $`git config user.email "test@opencode.test"`.cwd(dirpath).quiet()
    await $`git config user.name "Test"`.cwd(dirpath).quiet()
    await $`git commit --allow-empty -m "root commit ${dirpath}"`.cwd(dirpath).quiet()
  }

  // config option writes opencode.json into the tmpdir for Instance to discover.
  if (options?.config) {
    await Bun.write(
      path.join(dirpath, "opencode.json"),
      JSON.stringify({
        $schema: "https://opencode.ai/config.json",
        ...options.config,
      }),
    )
  }

  const realpath = sanitizePath(await fs.realpath(dirpath))
  const extra = await options?.init?.(realpath)

  // Symbol.asyncDispose enables `await using tmp = await tmpdir(...)`.
  // Cleanup runs automatically when the block scope exits.
  const result = {
    [Symbol.asyncDispose]: async () => {
      try {
        await options?.dispose?.(realpath)
      } finally {
        if (options?.git) await stop(realpath).catch(() => undefined)
        await clean(realpath).catch(() => undefined)
      }
    },
    path: realpath,
    extra: extra as T,
  }
  return result
}

// Bridge between Effect world and Instance.provide.
// Captures the current service map, then runs inside Instance.provide.
export const provideInstance =
  (directory: string) =>
  <A, E, R>(self: Effect.Effect<A, E, R>): Effect.Effect<A, E, R> =>
    Effect.servicesWith((services: ServiceMap.ServiceMap<R>) =>
      Effect.promise<A>(async () =>
        Instance.provide({
          directory,
          fn: () => Effect.runPromiseWith(services)(self),
        }),
      ),
    )
```

Key design decisions:
- **`await using`** (TC39 Explicit Resource Management): the tmpdir auto-cleans when the block exits, even if a test throws. No manual cleanup in `afterEach`.
- **`init` callback**: receives the resolved realpath so file setup happens AFTER the directory exists and BEFORE the test body. `extra` carries return values (like generated content) into the test.
- **`sanitizePath`**: defends against null bytes that could slip through path.join on some platforms.

### 1.3 lib/effect.ts -- Effect Test Helper

```ts
// test/lib/effect.ts
import { test, type TestOptions } from "bun:test"
import { Cause, Effect, Exit, Layer } from "effect"
import type * as Scope from "effect/Scope"
import * as TestConsole from "effect/testing/TestConsole"

type Body<A, E, R> = Effect.Effect<A, E, R> | (() => Effect.Effect<A, E, R>)
const env = TestConsole.layer

const body = <A, E, R>(value: Body<A, E, R>) =>
  Effect.suspend(() => (typeof value === "function" ? value() : value))

const run = <A, E, R, E2>(
  value: Body<A, E, R | Scope.Scope>,
  layer: Layer.Layer<R, E2, never>
) =>
  Effect.gen(function* () {
    const exit = yield* body(value).pipe(Effect.scoped, Effect.provide(layer), Effect.exit)
    if (Exit.isFailure(exit)) {
      for (const err of Cause.prettyErrors(exit.cause)) {
        yield* Effect.logError(err)
      }
    }
    return yield* exit
  }).pipe(Effect.runPromise)

const make = <R, E>(layer: Layer.Layer<R, E, never>) => {
  const effect = <A, E2>(
    name: string,
    value: Body<A, E2, R | Scope.Scope>,
    opts?: number | TestOptions
  ) => test(name, () => run(value, layer), opts)

  effect.only = <A, E2>(name: string, value: Body<A, E2, R | Scope.Scope>, opts?: number | TestOptions) =>
    test.only(name, () => run(value, layer), opts)

  effect.skip = <A, E2>(name: string, value: Body<A, E2, R | Scope.Scope>, opts?: number | TestOptions) =>
    test.skip(name, () => run(value, layer), opts)

  return { effect }
}

export const it = make(env)
export const testEffect = <R, E>(layer: Layer.Layer<R, E, never>) =>
  make(Layer.provideMerge(layer, env))
```

Usage:

```ts
const it = testEffect(Layer.mergeAll(TruncateSvc.defaultLayer, NodeFileSystem.layer))

it.effect("deletes files older than 7 days and preserves recent files", () =>
  Effect.gen(function* () {
    const fs = yield* FileSystem.FileSystem
    yield* fs.makeDirectory(Truncate.DIR, { recursive: true })
    // ... test logic ...
    expect(yield* fs.exists(old)).toBe(false)
    expect(yield* fs.exists(recent)).toBe(true)
  }),
)
```

### 1.4 fixture/db.ts -- Database Reset Helper

```ts
import { rm } from "fs/promises"
import { Instance } from "../../src/project/instance"
import { Database } from "../../src/storage/db"

export async function resetDatabase() {
  await Instance.disposeAll().catch(() => undefined)
  Database.close()
  await rm(Database.Path, { force: true }).catch(() => undefined)
  await rm(`${Database.Path}-wal`, { force: true }).catch(() => undefined)
  await rm(`${Database.Path}-shm`, { force: true }).catch(() => undefined)
}
```

---

## 2. Standard Tool Context

Every tool test creates this `ctx` object. It is the minimum shape that satisfies the tool execution interface.

```ts
import { SessionID, MessageID } from "../../src/session/schema"

const ctx = {
  sessionID: SessionID.make("ses_test"),
  messageID: MessageID.make(""),
  callID: "",
  agent: "build",
  abort: AbortSignal.any([]),
  messages: [],
  metadata: () => {},
  ask: async () => {},
}
```

For permission tests, replace `ask` with a capture function:

```ts
const requests: Array<Omit<Permission.Request, "id" | "sessionID" | "tool">> = []
const testCtx = {
  ...ctx,
  ask: async (req: Omit<Permission.Request, "id" | "sessionID" | "tool">) => {
    requests.push(req)
  },
}
```

---

## 3. Complete Test Examples

### 3.1 Tool Test -- read.test.ts

Demonstrates: tmpdir + init, Instance.provide, Tool.init + execute, permission capture via `ask`, parameterized tests with `describe.each` + `test.each`, truncation metadata, image attachment handling, binary detection.

```ts
import { afterEach, describe, expect, test } from "bun:test"
import path from "path"
import { ReadTool } from "../../src/tool/read"
import { Instance } from "../../src/project/instance"
import { Filesystem } from "../../src/util/filesystem"
import { tmpdir } from "../fixture/fixture"
import { Permission } from "../../src/permission"
import { Agent } from "../../src/agent/agent"
import { SessionID, MessageID } from "../../src/session/schema"

const FIXTURES_DIR = path.join(import.meta.dir, "fixtures")

afterEach(async () => {
  await Instance.disposeAll()
})

const ctx = {
  sessionID: SessionID.make("ses_test"),
  messageID: MessageID.make(""),
  callID: "",
  agent: "build",
  abort: AbortSignal.any([]),
  messages: [],
  metadata: () => {},
  ask: async () => {},
}

// --- Permission tests ---

describe("tool.read external_directory permission", () => {
  test("allows reading absolute path inside project directory", async () => {
    await using tmp = await tmpdir({
      init: async (dir) => {
        await Bun.write(path.join(dir, "test.txt"), "hello world")
      },
    })
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const read = await ReadTool.init()
        const result = await read.execute(
          { filePath: path.join(tmp.path, "test.txt") },
          ctx,
        )
        expect(result.output).toContain("hello world")
      },
    })
  })

  test("asks for external_directory permission when reading outside project", async () => {
    await using outerTmp = await tmpdir({
      init: async (dir) => {
        await Bun.write(path.join(dir, "secret.txt"), "secret data")
      },
    })
    await using tmp = await tmpdir({ git: true })
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const read = await ReadTool.init()
        const requests: Array<Omit<Permission.Request, "id" | "sessionID" | "tool">> = []
        const testCtx = {
          ...ctx,
          ask: async (req: Omit<Permission.Request, "id" | "sessionID" | "tool">) => {
            requests.push(req)
          },
        }
        await read.execute(
          { filePath: path.join(outerTmp.path, "secret.txt") },
          testCtx,
        )
        const extDirReq = requests.find((r) => r.permission === "external_directory")
        expect(extDirReq).toBeDefined()
        expect(
          extDirReq!.patterns.some((p) =>
            p.includes(outerTmp.path.replaceAll("\\", "/"))
          )
        ).toBe(true)
      },
    })
  })
})

// --- Parameterized env file permission tests ---

describe("tool.read env file permissions", () => {
  const cases: [string, boolean][] = [
    [".env", true],
    [".env.local", true],
    [".env.production", true],
    [".env.development.local", true],
    [".env.example", false],
    [".envrc", false],
    ["environment.ts", false],
  ]

  describe.each(["build", "plan"])("agent=%s", (agentName) => {
    test.each(cases)("%s asks=%s", async (filename, shouldAsk) => {
      await using tmp = await tmpdir({
        init: (dir) => Bun.write(path.join(dir, filename), "content"),
      })
      await Instance.provide({
        directory: tmp.path,
        fn: async () => {
          const agent = await Agent.get(agentName)
          let askedForEnv = false
          const ctxWithPermissions = {
            ...ctx,
            ask: async (req: Omit<Permission.Request, "id" | "sessionID" | "tool">) => {
              for (const pattern of req.patterns) {
                const rule = Permission.evaluate(req.permission, pattern, agent.permission)
                if (rule.action === "ask" && req.permission === "read") {
                  askedForEnv = true
                }
                if (rule.action === "deny") {
                  throw new Permission.DeniedError({ ruleset: agent.permission })
                }
              }
            },
          }
          const read = await ReadTool.init()
          await read.execute(
            { filePath: path.join(tmp.path, filename) },
            ctxWithPermissions,
          )
          expect(askedForEnv).toBe(shouldAsk)
        },
      })
    })
  })
})

// --- Truncation and binary detection ---

describe("tool.read truncation", () => {
  test("truncates large file by bytes and sets truncated metadata", async () => {
    await using tmp = await tmpdir({
      init: async (dir) => {
        const base = await Filesystem.readText(path.join(FIXTURES_DIR, "models-api.json"))
        const target = 60 * 1024
        const content = base.length >= target ? base : base.repeat(Math.ceil(target / base.length))
        await Filesystem.write(path.join(dir, "large.json"), content)
      },
    })
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const read = await ReadTool.init()
        const result = await read.execute(
          { filePath: path.join(tmp.path, "large.json") },
          ctx,
        )
        expect(result.metadata.truncated).toBe(true)
        expect(result.output).toContain("Output capped at")
        expect(result.output).toContain("Use offset=")
      },
    })
  })

  test("image files set truncated to false", async () => {
    await using tmp = await tmpdir({
      init: async (dir) => {
        const png = Buffer.from(
          "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==",
          "base64",
        )
        await Bun.write(path.join(dir, "image.png"), png)
      },
    })
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const read = await ReadTool.init()
        const result = await read.execute(
          { filePath: path.join(tmp.path, "image.png") },
          ctx,
        )
        expect(result.metadata.truncated).toBe(false)
        expect(result.attachments).toBeDefined()
        expect(result.attachments?.length).toBe(1)
        expect(result.attachments?.[0]).not.toHaveProperty("id")
      },
    })
  })

  test("rejects text extension files with null bytes", async () => {
    await using tmp = await tmpdir({
      init: async (dir) => {
        const bytes = Buffer.from([0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x77, 0x6f, 0x72, 0x6c, 0x64])
        await Bun.write(path.join(dir, "null-byte.txt"), bytes)
      },
    })
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const read = await ReadTool.init()
        await expect(
          read.execute({ filePath: path.join(tmp.path, "null-byte.txt") }, ctx)
        ).rejects.toThrow("Cannot read binary file")
      },
    })
  })
})
```

### 3.2 Service Test -- skill.test.ts

Demonstrates: tmpdir with SKILL.md fixture, domain method assertions, env var override + restore in finally block.

```ts
import { afterEach, test, expect } from "bun:test"
import { Skill } from "../../src/skill"
import { Instance } from "../../src/project/instance"
import { tmpdir } from "../fixture/fixture"
import path from "path"
import fs from "fs/promises"

afterEach(async () => { await Instance.disposeAll() })

test("discovers skills from .opencode/skill/ directory", async () => {
  await using tmp = await tmpdir({
    git: true,
    init: async (dir) => {
      const skillDir = path.join(dir, ".opencode", "skill", "test-skill")
      await Bun.write(
        path.join(skillDir, "SKILL.md"),
        `---
name: test-skill
description: A test skill for verification.
---

# Test Skill
Instructions here.
`,
      )
    },
  })

  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const skills = await Skill.all()
      expect(skills.length).toBe(1)
      const testSkill = skills.find((s) => s.name === "test-skill")
      expect(testSkill).toBeDefined()
      expect(testSkill!.description).toBe("A test skill for verification.")
      expect(testSkill!.location).toContain(path.join("skill", "test-skill", "SKILL.md"))
    },
  })
})

test("discovers global skills from ~/.claude/skills/ directory", async () => {
  await using tmp = await tmpdir({ git: true })
  const originalHome = process.env.OPENCODE_TEST_HOME
  process.env.OPENCODE_TEST_HOME = tmp.path

  try {
    await createGlobalSkill(tmp.path)
    await Instance.provide({
      directory: tmp.path,
      fn: async () => {
        const skills = await Skill.all()
        expect(skills.length).toBe(1)
        expect(skills[0].name).toBe("global-test-skill")
      },
    })
  } finally {
    process.env.OPENCODE_TEST_HOME = originalHome
  }
})
```

### 3.3 Snapshot Test -- Real Git Repos

Demonstrates: git repo bootstrap with content, Snapshot.track/patch/revert, cross-platform path normalization, asserting file existence via fs.access.

```ts
import { afterEach, test, expect } from "bun:test"
import { $ } from "bun"
import fs from "fs/promises"
import path from "path"
import { Snapshot } from "../../src/snapshot"
import { Instance } from "../../src/project/instance"
import { Filesystem } from "../../src/util/filesystem"
import { tmpdir } from "../fixture/fixture"

const fwd = (...parts: string[]) => path.join(...parts).replaceAll("\\", "/")

afterEach(async () => { await Instance.disposeAll() })

async function bootstrap() {
  return tmpdir({
    git: true,
    init: async (dir) => {
      const unique = Math.random().toString(36).slice(2)
      const aContent = `A${unique}`
      const bContent = `B${unique}`
      await Filesystem.write(`${dir}/a.txt`, aContent)
      await Filesystem.write(`${dir}/b.txt`, bContent)
      await $`git add .`.cwd(dir).quiet()
      await $`git commit --no-gpg-sign -m init`.cwd(dir).quiet()
      return { aContent, bContent }
    },
  })
}

test("tracks deleted files correctly", async () => {
  await using tmp = await bootstrap()
  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const before = await Snapshot.track()
      expect(before).toBeTruthy()
      await $`rm ${tmp.path}/a.txt`.quiet()
      expect((await Snapshot.patch(before!)).files).toContain(fwd(tmp.path, "a.txt"))
    },
  })
})

test("revert should remove new files", async () => {
  await using tmp = await bootstrap()
  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const before = await Snapshot.track()
      await Filesystem.write(`${tmp.path}/new.txt`, "NEW")
      await Snapshot.revert([await Snapshot.patch(before!)])
      expect(
        await fs.access(`${tmp.path}/new.txt`).then(() => true).catch(() => false),
      ).toBe(false)
    },
  })
})

test("multiple file operations", async () => {
  await using tmp = await bootstrap()
  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const before = await Snapshot.track()
      await $`rm ${tmp.path}/a.txt`.quiet()
      await Filesystem.write(`${tmp.path}/c.txt`, "C")
      await Filesystem.write(`${tmp.path}/b.txt`, "MODIFIED")
      await Snapshot.revert([await Snapshot.patch(before!)])
      expect(await fs.readFile(`${tmp.path}/a.txt`, "utf-8")).toBe(tmp.extra.aContent)
      expect(await fs.readFile(`${tmp.path}/b.txt`, "utf-8")).toBe(tmp.extra.bContent)
    },
  })
})
```

### 3.4 Server Test -- HTTP Boundary Testing

Demonstrates: Server.Default() + app.request() (Hono test client pattern), cursor-based pagination, source-text assertion.

```ts
describe("session messages endpoint", () => {
  test("returns cursor headers for older pages", async () => {
    await Instance.provide({
      directory: root,
      fn: async () => {
        const session = await Session.create({})
        const ids = await fill(session.id, 5)
        const app = Server.Default()

        const a = await app.request(`/session/${session.id}/message?limit=2`)
        expect(a.status).toBe(200)
        const aBody = (await a.json()) as MessageV2.WithParts[]
        expect(aBody.map((item) => item.info.id)).toEqual(ids.slice(-2))
        const cursor = a.headers.get("x-next-cursor")
        expect(cursor).toBeTruthy()
        expect(a.headers.get("link")).toContain('rel="next"')

        const b = await app.request(
          `/session/${session.id}/message?limit=2&before=${encodeURIComponent(cursor!)}`
        )
        expect(b.status).toBe(200)
        const bBody = (await b.json()) as MessageV2.WithParts[]
        expect(bBody.map((item) => item.info.id)).toEqual(ids.slice(-4, -2))

        await Session.remove(session.id)
      },
    })
  })
})

// Source-text assertion: read actual source code to verify structural invariants.
describe("session.prompt_async error handling", () => {
  test("prompt_async route has error handler for detached prompt call", async () => {
    const src = await Bun.file(
      path.join(import.meta.dir, "../../src/server/routes/session.ts")
    ).text()
    const start = src.indexOf('"/:sessionID/prompt_async"')
    const end = src.indexOf('"/:sessionID/command"', start)
    expect(start).toBeGreaterThan(-1)
    expect(end).toBeGreaterThan(start)
    const route = src.slice(start, end)
    expect(route).toContain(".catch(")
    expect(route).toContain("Bus.publish(Session.Event.Error")
  })
})
```

### 3.5 Effect Test -- instance-state.test.ts

Demonstrates: Effect.scoped + InstanceState.make, ServiceMap.Service class, ManagedRuntime, concurrent access with Promise.all across directories.

```ts
import { afterEach, expect, test } from "bun:test"
import { Duration, Effect, Layer, ManagedRuntime, ServiceMap } from "effect"
import { InstanceState } from "../../src/effect/instance-state"
import { Instance } from "../../src/project/instance"
import { tmpdir } from "../fixture/fixture"

async function access<A, E>(state: InstanceState<A, E>, dir: string) {
  return Instance.provide({
    directory: dir,
    fn: () => Effect.runPromise(InstanceState.get(state)),
  })
}

afterEach(async () => { await Instance.disposeAll() })

test("InstanceState caches values per directory", async () => {
  await using tmp = await tmpdir()
  let n = 0

  await Effect.runPromise(
    Effect.scoped(
      Effect.gen(function* () {
        const state = yield* InstanceState.make(() => Effect.sync(() => ({ n: ++n })))
        const a = yield* Effect.promise(() => access(state, tmp.path))
        const b = yield* Effect.promise(() => access(state, tmp.path))
        expect(a).toBe(b)
        expect(n).toBe(1)
      }),
    ),
  )
})

test("InstanceState preserves directory across async boundaries", async () => {
  await using one = await tmpdir({ git: true })
  await using two = await tmpdir({ git: true })
  await using three = await tmpdir({ git: true })

  interface Api {
    readonly get: () => Effect.Effect<{
      directory: string; worktree: string; project: string
    }>
  }

  class Test extends ServiceMap.Service<Test, Api>()("@test/InstanceStateAsync") {
    static readonly layer = Layer.effect(
      Test,
      Effect.gen(function* () {
        const state = yield* InstanceState.make((ctx) =>
          Effect.sync(() => ({
            directory: ctx.directory,
            worktree: ctx.worktree,
            project: ctx.project.id,
          })),
        )
        return Test.of({
          get: Effect.fn("Test.get")(function* () {
            yield* Effect.promise(() => Bun.sleep(1))
            yield* Effect.sleep(Duration.millis(1))
            for (let i = 0; i < 100; i++) yield* Effect.yieldNow
            for (let i = 0; i < 100; i++) yield* Effect.promise(() => Promise.resolve())
            yield* Effect.sleep(Duration.millis(2))
            return yield* InstanceState.get(state)
          }),
        })
      }),
    )
  }

  const rt = ManagedRuntime.make(Test.layer)
  try {
    const [a, b, c] = await Promise.all([
      Instance.provide({ directory: one.path, fn: () => rt.runPromise(Test.use((svc) => svc.get())) }),
      Instance.provide({ directory: two.path, fn: () => rt.runPromise(Test.use((svc) => svc.get())) }),
      Instance.provide({ directory: three.path, fn: () => rt.runPromise(Test.use((svc) => svc.get())) }),
    ])
    expect(a).toEqual({ directory: one.path, worktree: one.path, project: a.project })
    expect(b).toEqual({ directory: two.path, worktree: two.path, project: b.project })
    expect(a.project).not.toBe(b.project)
  } finally {
    await rt.dispose()
  }
})
```

---

## 4. Fake Server Pattern

Used by `llm.test.ts` to test LLM provider integration without hitting real APIs. The pattern uses `Bun.serve({ port: 0 })` for an ephemeral server on a random port, a request queue for deterministic request/response pairing, and SSE stream helpers for simulating chat completions.

```ts
import { afterAll, beforeAll, beforeEach, describe, expect, test } from "bun:test"
import path from "path"
import { LLM } from "../../src/session/llm"
import { Provider } from "../../src/provider/provider"
import { ProviderTransform } from "../../src/provider/transform"
import { ProviderID, ModelID } from "../../src/provider/schema"
import { tmpdir } from "../fixture/fixture"

// --- Deferred promise utility for request capture ---

function deferred<T>() {
  const result = {} as { promise: Promise<T>; resolve: (value: T) => void }
  result.promise = new Promise((resolve) => { result.resolve = resolve })
  return result
}

type Capture = { url: URL; headers: Headers; body: Record<string, unknown> }

const state = {
  server: null as ReturnType<typeof Bun.serve> | null,
  queue: [] as Array<{
    path: string; response: Response; resolve: (value: Capture) => void
  }>,
}

// Enqueue an expected request. Returns a promise that resolves with the
// captured request details when the server receives a matching request.
function waitRequest(pathname: string, response: Response) {
  const pending = deferred<Capture>()
  state.queue.push({ path: pathname, response, resolve: pending.resolve })
  return pending.promise
}

// --- Bun.serve as fake API server ---

beforeAll(() => {
  state.server = Bun.serve({
    port: 0, // random port -- no conflicts with other tests
    async fetch(req) {
      const next = state.queue.shift()
      if (!next) return new Response("unexpected request", { status: 500 })
      const url = new URL(req.url)
      const body = (await req.json()) as Record<string, unknown>
      next.resolve({ url, headers: req.headers, body })
      if (!url.pathname.endsWith(next.path)) {
        return new Response("not found", { status: 404 })
      }
      return next.response
    },
  })
})

beforeEach(() => { state.queue.length = 0 })
afterAll(() => { state.server?.stop() })

// --- SSE stream helpers ---

function createChatStream(text: string) {
  const payload = [
    `data: ${JSON.stringify({
      id: "chatcmpl-1", object: "chat.completion.chunk",
      choices: [{ delta: { role: "assistant" } }],
    })}`,
    `data: ${JSON.stringify({
      id: "chatcmpl-1", object: "chat.completion.chunk",
      choices: [{ delta: { content: text } }],
    })}`,
    `data: ${JSON.stringify({
      id: "chatcmpl-1", object: "chat.completion.chunk",
      choices: [{ delta: {}, finish_reason: "stop" }],
    })}`,
    "data: [DONE]",
  ].join("\n\n") + "\n\n"
  const encoder = new TextEncoder()
  return new ReadableStream<Uint8Array>({
    start(controller) {
      controller.enqueue(encoder.encode(payload))
      controller.close()
    },
  })
}

// --- Test using the fake server ---

test("sends temperature, tokens, and reasoning options", async () => {
  const server = state.server!
  const providerID = "alibaba"
  const modelID = "qwen-plus"
  const fixture = await loadFixture(providerID, modelID)

  // Queue the expected request BEFORE triggering the LLM call.
  const request = waitRequest(
    "/chat/completions",
    new Response(createChatStream("Hello"), {
      status: 200,
      headers: { "Content-Type": "text/event-stream" },
    }),
  )

  await using tmp = await tmpdir({
    init: async (dir) => {
      await Bun.write(
        path.join(dir, "opencode.json"),
        JSON.stringify({
          $schema: "https://opencode.ai/config.json",
          enabled_providers: [providerID],
          provider: {
            [providerID]: {
              options: {
                apiKey: "test-key",
                baseURL: `${server.url.origin}/v1`,
              },
            },
          },
        }),
      )
    },
  })

  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const resolved = await Provider.getModel(
        ProviderID.make(providerID), ModelID.make(fixture.model.id)
      )
      const sessionID = SessionID.make("session-test-1")
      const agent = {
        name: "test", mode: "primary", options: {},
        permission: [{ permission: "*", pattern: "*", action: "allow" }],
        temperature: 0.4, topP: 0.8,
      } satisfies Agent.Info

      const user = {
        id: MessageID.make("user-1"),
        sessionID, role: "user",
        time: { created: Date.now() },
        agent: agent.name,
        model: { providerID: ProviderID.make(providerID), modelID: resolved.id },
        variant: "high",
      } satisfies MessageV2.User

      const stream = await LLM.stream({
        user, sessionID, model: resolved, agent,
        system: ["You are a helpful assistant."],
        abort: new AbortController().signal,
        messages: [{ role: "user", content: "Hello" }],
        tools: {},
      })

      // Drain the stream to trigger the HTTP request.
      for await (const _ of stream.fullStream) {}

      // Assert against the captured request.
      const capture = await request
      expect(capture.url.pathname.startsWith("/v1/")).toBe(true)
      expect(capture.headers.get("Authorization")).toBe("Bearer test-key")
      expect(capture.body.model).toBe(resolved.api.id)
      expect(capture.body.temperature).toBe(0.4)
      expect(capture.body.top_p).toBe(0.8)
      expect(capture.body.stream).toBe(true)
    },
  })
})
```

Network error simulation variant (from `retry.test.ts`):

```ts
test.concurrent(
  "converts ECONNRESET socket errors to retryable APIError",
  async () => {
    // Bun.serve with `using` for auto-cleanup via Symbol.dispose.
    using server = Bun.serve({
      port: 0,
      idleTimeout: 8,
      async fetch(req) {
        return new Response(
          new ReadableStream({
            async pull(controller) {
              controller.enqueue("Hello,")
              await sleep(10000) // server goes idle, triggers ECONNRESET
              controller.enqueue(" World!")
              controller.close()
            },
          }),
          { headers: { "Content-Type": "text/plain" } },
        )
      },
    })

    const error = await fetch(new URL("/", server.url.origin))
      .then((res) => res.text())
      .catch((e) => e)

    const result = MessageV2.fromError(error, { providerID })
    expect(MessageV2.APIError.isInstance(result)).toBe(true)
    expect((result as MessageV2.APIError).data.isRetryable).toBe(true)
    expect((result as MessageV2.APIError).data.message).toBe("Connection reset by server")
  },
  15_000, // generous timeout for idle-triggered disconnect
)
```

---

## 5. Mock Patterns

Mocking is the LAST resort. The hierarchy is: real services > fake server > Layer.mock > mock.module. Only use `mock.module` for external SDKs where no other approach works.

### 5.1 MCP SDK -- Full Module Mocking

`mock.module` calls MUST appear before any imports that touch the mocked modules. Each test resets mock state via `beforeEach`.

```ts
import { test, expect, mock, beforeEach } from "bun:test"

// These MUST come before any import that uses the MCP SDK.
mock.module("@modelcontextprotocol/sdk/client/stdio.js", () => ({
  StdioClientTransport: MockStdioTransport,
}))

mock.module("@modelcontextprotocol/sdk/client/streamableHttp.js", () => ({
  StreamableHTTPClientTransport: MockStreamableHTTP,
}))

mock.module("@modelcontextprotocol/sdk/client/index.js", () => ({
  Client: class MockClient {
    _state!: MockClientState
    transport: any
    constructor(_opts: any) { clientCreateCount++ }
    async connect(transport: { start: () => Promise<void> }) {
      this.transport = transport
      await transport.start()
      this._state = getOrCreateClientState(lastCreatedClientName)
    }
    async listTools() {
      if (this._state) this._state.listToolsCalls++
      if (this._state?.listToolsShouldFail) throw new Error(this._state.listToolsError)
      return { tools: this._state?.tools ?? [] }
    }
    async close() { this._state.closed = true }
  },
}))

interface MockClientState {
  tools: Array<{ name: string; description?: string; inputSchema: object }>
  listToolsCalls: number
  listToolsShouldFail: boolean
  listToolsError: string
  closed: boolean
}

beforeEach(() => {
  clientStates.clear()
  lastCreatedClientName = undefined
  connectShouldFail = false
  connectShouldHang = false
  clientCreateCount = 0
  transportCloseCount = 0
})
```

### 5.2 Effect Layer Mocking -- ChildProcessSpawner

For simulating git command failures without mocking modules. Wraps the real spawner and intercepts specific commands.

```ts
function mockGitFailure(failArg: string) {
  return Layer.effect(
    ChildProcessSpawner.ChildProcessSpawner,
    Effect.gen(function* () {
      const real = yield* ChildProcessSpawner.ChildProcessSpawner
      return ChildProcessSpawner.make(
        Effect.fnUntraced(function* (command) {
          const std = ChildProcess.isStandardCommand(command) ? command : undefined
          if (std?.command === "git" && std.args.some((a) => a === failArg)) {
            return ChildProcessSpawner.makeHandle({
              pid: ChildProcessSpawner.ProcessId(0),
              exitCode: Effect.succeed(ChildProcessSpawner.ExitCode(128)),
              isRunning: Effect.succeed(false),
              kill: () => Effect.void,
              stdin: { [Symbol.for("effect/Sink/TypeId")]: Symbol.for("effect/Sink/TypeId") } as any,
              stdout: Stream.empty,
              stderr: Stream.make(encoder.encode("fatal: simulated failure\n")),
              all: Stream.empty,
              getInputFd: () => ({ [Symbol.for("effect/Sink/TypeId")]: Symbol.for("effect/Sink/TypeId") }) as any,
              getOutputFd: () => Stream.empty,
            })
          }
          return yield* real.spawn(command)
        }),
      )
    }),
  ).pipe(Layer.provide(CrossSpawnSpawner.defaultLayer))
}

test("handles show-toplevel failure gracefully", async () => {
  await using tmp = await tmpdir({ git: true })
  const layer = projectLayerWithFailure("--show-toplevel")

  const { project, sandbox } = await Effect.runPromise(
    Project.Service.use((svc) => svc.fromDirectory(tmp.path)).pipe(
      Effect.provide(layer)
    ),
  )
  expect(project.worktree).toBe(tmp.path)
  expect(sandbox).toBe(tmp.path)
})
```

### 5.3 Layer.mock for Effect Services

```ts
const emptyAccount = Layer.mock(Account.Service)({
  active: () => Effect.succeed(Option.none()),
})

const emptyAuth = Layer.mock(Auth.Service)({
  all: () => Effect.succeed({}),
})
```

### 5.4 Env Var Override + Restore

For tests that must change environment variables. Always restore in a `finally` block.

```ts
test("discovers global skills from home directory", async () => {
  const originalHome = process.env.OPENCODE_TEST_HOME
  process.env.OPENCODE_TEST_HOME = tmp.path

  try {
    // ... test body ...
  } finally {
    process.env.OPENCODE_TEST_HOME = originalHome
  }
})
```

### 5.5 Env.set for Provider Tests

```ts
await Instance.provide({
  directory: tmp.path,
  init: async () => {
    Env.set("ANTHROPIC_API_KEY", "test-api-key")
  },
  fn: async () => {
    const providers = await Provider.list()
    expect(providers[ProviderID.anthropic]).toBeDefined()
    expect(providers[ProviderID.anthropic].source).toBe("env")
  },
})
```

---

## 6. Testing Decisions

Choose the lightest strategy that covers the behavior. This is the hierarchy from lightest to heaviest:

### Pure helper -- direct test, no Instance

For stateless utility functions. Import the function, call it, assert the return value.

```ts
import { test, expect } from "bun:test"
import { Wildcard } from "../../src/util/wildcard"

test("match with trailing space+wildcard", () => {
  expect(Wildcard.match("ls", "ls *")).toBe(true)
  expect(Wildcard.match("ls -la", "ls *")).toBe(true)
  expect(Wildcard.match("lstmeval", "ls *")).toBe(false)
})
```

When to use: the function takes plain values and returns plain values. No file system, no database, no project context.

### Domain logic -- tmpdir + Instance.provide

For anything that touches project state, config, or the event bus.

```ts
test("loads JSON config file", async () => {
  await using tmp = await tmpdir({
    init: async (dir) => {
      await Bun.write(path.join(dir, "opencode.json"), JSON.stringify({
        $schema: "https://opencode.ai/config.json",
        model: "test/model",
      }))
    },
  })
  await Instance.provide({
    directory: tmp.path,
    fn: async () => {
      const config = await Config.get()
      expect(config.model).toBe("test/model")
    },
  })
})
```

When to use: the code reads config, accesses the database, emits events, or needs a project directory.

### HTTP contract -- Server.Default().request()

For testing API routes. Uses Hono's built-in test client, no real HTTP server needed.

```ts
const app = Server.Default()
const res = await app.request(`/session/${session.id}/message?limit=2`)
expect(res.status).toBe(200)
```

When to use: testing route handlers, response shapes, headers, status codes.

### Provider/streaming -- local Bun.serve() fake

For testing LLM provider integration, SSE streaming, retry logic, or network error handling.

```ts
state.server = Bun.serve({ port: 0, async fetch(req) { /* queue-based response */ } })
```

When to use: the code makes HTTP requests to external APIs. You need to verify request shape, headers, and streaming behavior.

### External SDK -- mock.module()

Last resort. Only for third-party SDKs where you cannot substitute behavior any other way (MCP SDK, etc).

```ts
mock.module("@modelcontextprotocol/sdk/client/index.js", () => ({
  Client: class MockClient { /* ... */ },
}))
```

When to use: the SDK constructor has side effects, opens connections, or is otherwise impossible to fake with a local server.

---

## 7. Recurring Patterns Quick Reference

| Pattern | Code |
|---|---|
| Async disposable tmpdir | `await using tmp = await tmpdir({ git: true })` |
| Scope all ops to a project | `await Instance.provide({ directory, fn })` |
| Clean up after each test | `afterEach(() => Instance.disposeAll())` |
| Standard tool context | `const ctx = { sessionID: SessionID.make("ses_test"), messageID: MessageID.make(""), callID: "", agent: "build", abort: AbortSignal.any([]), messages: [], metadata: () => {}, ask: async () => {} }` |
| Write files in init | `Bun.write(path, content)` (preferred over fs.writeFile) |
| Git operations | `` $`git add .`.cwd(dir).quiet() `` |
| Ephemeral HTTP server | `Bun.serve({ port: 0 })` |
| Brief async delay | `Bun.sleep(10)` |
| Cross-platform paths | `path.join(...).replaceAll("\\", "/")` |
| Type-safe test data | `{ ... } satisfies Agent.Info` |
| Permission capture | `ask: async (req) => { requests.push(req) }` |
| Bus event observation | `Bus.subscribe(Event, (e) => events.push(e))` then `Bun.sleep(10)` |
| Source-text assertion | `Bun.file(path).text()` then `expect(src).toContain(...)` |
| Effect test wrapper | `it.effect("name", () => Effect.gen(function* () { ... }))` |
