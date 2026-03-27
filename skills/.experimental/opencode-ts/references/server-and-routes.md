# Server, Routes & System Lifecycle

Real code from `packages/opencode/src/server/`, `config/`, `plugin/`, `project/`.

---

## 1. Server Setup (`server/server.ts`)

Hono app with layered middleware. `ControlPlaneRoutes` is the top-level app; `InstanceRoutes` is mounted as the catch-all via `WorkspaceRouterMiddleware`.

```typescript
export namespace Server {
  export const ControlPlaneRoutes = (opts?: { cors?: string[] }): Hono => {
    const app = new Hono()
    return app
      .onError(errorHandler(log))
      // Basic auth guard (skips OPTIONS for CORS preflight)
      .use((c, next) => {
        if (c.req.method === "OPTIONS") return next()
        const password = Flag.OPENCODE_SERVER_PASSWORD
        if (!password) return next()
        const username = Flag.OPENCODE_SERVER_USERNAME ?? "opencode"
        return basicAuth({ username, password })(c, next)
      })
      // Request logging + timing
      .use(async (c, next) => {
        const skip = c.req.path === "/log"
        if (!skip) log.info("request", { method: c.req.method, path: c.req.path })
        const timer = log.time("request", { method: c.req.method, path: c.req.path })
        await next()
        if (!skip) timer.stop()
      })
      // CORS whitelist
      .use(cors({
        maxAge: 86_400,
        origin(input) {
          if (!input) return
          if (input.startsWith("http://localhost:")) return input
          if (input.startsWith("http://127.0.0.1:")) return input
          if (/^https:\/\/([a-z0-9-]+\.)*opencode\.ai$/.test(input)) return input
          if (opts?.cors?.includes(input)) return input
        },
      }))
      // Selective compression (skip SSE and streaming endpoints)
      .use((c, next) => {
        if (skipCompress(c.req.path, c.req.method)) return next()
        return zipped(c, next)
      })
      .route("/global", GlobalRoutes())
      // ... auth routes, log route
      .use(WorkspaceRouterMiddleware)
  }

  export function listen(opts: { port; hostname; mdns?; mdnsDomain?; cors? }) {
    url = new URL(`http://${opts.hostname}:${opts.port}`)
    const app = ControlPlaneRoutes({ cors: opts.cors })
    const tryServe = (port: number) => {
      try { return Bun.serve({ hostname: opts.hostname, idleTimeout: 0, fetch: app.fetch, websocket, port }) }
      catch { return undefined }
    }
    const server = opts.port === 0 ? (tryServe(4096) ?? tryServe(0)) : tryServe(opts.port)
    if (!server) throw new Error(`Failed to start server on port ${opts.port}`)
    if (shouldPublishMDNS) MDNS.publish(server.port!, opts.mdnsDomain)
    return server
  }
}
```

Middleware execution order per request:
1. `errorHandler` (catches everything below)
2. Basic auth (skipped for OPTIONS)
3. Request logging + timing
4. CORS
5. Compression (skipped for SSE)
6. `/global` routes OR `WorkspaceRouterMiddleware` (which delegates to `InstanceRoutes`)

---

## 2. Instance Middleware (`server/instance.ts`)

`InstanceRoutes` resolves `directory` from query param, header, or `process.cwd()`, then wraps the entire request in `Instance.provide`. Every sub-route handler runs inside an Instance context.

```typescript
export const InstanceRoutes = (app?: Hono) =>
  (app ?? new Hono())
    .onError(errorHandler(log))
    // Instance context injection middleware
    .use(async (c, next) => {
      const raw = c.req.query("directory") || c.req.header("x-opencode-directory") || process.cwd()
      const directory = Filesystem.resolve(decodeURIComponent(raw))
      return Instance.provide({
        directory,
        init: InstanceBootstrap,
        async fn() { return next() },
      })
    })
    // Sub-route mounting
    .route("/project", ProjectRoutes())
    .route("/pty", PtyRoutes())
    .route("/config", ConfigRoutes())
    .route("/experimental", ExperimentalRoutes())
    .route("/session", SessionRoutes())
    .route("/permission", PermissionRoutes())
    .route("/question", QuestionRoutes())
    .route("/provider", ProviderRoutes())
    .route("/", FileRoutes())
    .route("/", EventRoutes())
    .route("/mcp", McpRoutes())
    .route("/tui", TuiRoutes())
    // Direct instance endpoints
    .post("/instance/dispose", /* ... */)
    .get("/path", /* ... */)
    .get("/vcs", /* ... */)
    .get("/command", /* ... */)
    .get("/agent", /* ... */)
    .get("/skill", /* ... */)
    .get("/lsp", /* ... */)
    .get("/formatter", /* ... */)
    // Fallback: embedded web UI or proxy to app.opencode.ai
    .all("/*", async (c) => {
      const embeddedWebUI = await embeddedUIPromise
      if (embeddedWebUI) {
        const match = embeddedWebUI[path.replace(/^\//, "")] ?? embeddedWebUI["index.html"]
        // serve static file with CSP headers
      } else {
        // proxy to https://app.opencode.ai
      }
    })
```

Directory resolution priority: `?directory=` query > `x-opencode-directory` header > `process.cwd()`.

---

## 3. Route Pattern

Every route file exports a `lazy(() => new Hono().METHOD(...))` factory. Each endpoint uses three layers: `describeRoute` (OpenAPI metadata) + `validator` (Zod input validation) + async handler.

### `lazy` helper (`util/lazy.ts`)

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
      throw e
    }
  }

  result.reset = () => {
    loaded = false
    value = undefined
  }

  return result
}
```

### Imports used in route files

```typescript
import { Hono } from "hono"
import { describeRoute } from "hono-openapi"
import { resolver, validator } from "hono-openapi/zod"
import { errors } from "../error"
import { lazy } from "@opencode-ai/util/lazy"
```

### Complete Example: Config Routes (`server/routes/config.ts`)

```typescript
export const ConfigRoutes = lazy(() =>
  new Hono()
    .get("/",
      describeRoute({
        summary: "Get configuration",
        operationId: "config.get",
        responses: {
          200: {
            description: "Get config info",
            content: { "application/json": { schema: resolver(Config.Info) } },
          },
        },
      }),
      async (c) => {
        return c.json(await Config.get())
      },
    )
    .patch("/",
      describeRoute({
        summary: "Update configuration",
        operationId: "config.update",
        responses: {
          200: {
            description: "Updated config",
            content: { "application/json": { schema: resolver(Config.Info) } },
          },
          ...errors(400),
        },
      }),
      validator("json", Config.Info),
      async (c) => {
        const config = c.req.valid("json")
        await Config.update(config)
        return c.json(config)
      },
    )
)
```

### Complete Example: Session Routes (`server/routes/session.ts`)

```typescript
export const SessionRoutes = lazy(() =>
  new Hono()
    .get("/",
      describeRoute({
        summary: "List sessions",
        operationId: "session.list",
        responses: {
          200: {
            description: "Sessions list",
            content: { "application/json": { schema: resolver(z.array(Session.Info)) } },
          },
        },
      }),
      validator("query", z.object({
        directory: z.string().optional(),
        roots: z.coerce.boolean().optional(),
        start: z.coerce.number().optional(),
        search: z.string().optional(),
        limit: z.coerce.number().optional(),
      })),
      async (c) => {
        const query = c.req.valid("query")
        const sessions: Session.Info[] = []
        for await (const session of Session.list({
          directory: query.directory,
          roots: query.roots,
          start: query.start,
          search: query.search,
          limit: query.limit,
        })) {
          sessions.push(session)
        }
        return c.json(sessions)
      },
    )
)
```

### Pattern Summary

```
export const XxxRoutes = lazy(() =>
  new Hono()
    .METHOD("/path",
      describeRoute({
        summary: "...",
        operationId: "namespace.action",
        responses: {
          200: { description: "...", content: { "application/json": { schema: resolver(ZodSchema) } } },
          ...errors(400, 404),  // optional error codes
        },
      }),
      validator("json" | "query" | "param", ZodSchema),  // optional per-source
      async (c) => {
        const data = c.req.valid("json" | "query" | "param")
        // call domain module directly (Config.get(), Session.list(), etc.)
        return c.json(result)
      },
    )
)
```

Key rules:
- Route files call domain modules directly -- no controller layer.
- `resolver(schema)` wraps a Zod schema for OpenAPI doc generation.
- `validator("json", schema)` validates + parses the request body; `"query"` for query params, `"param"` for URL params.
- `c.req.valid("json")` returns the parsed, typed data.
- Query params that are numbers use `z.coerce.number()`, booleans use `z.coerce.boolean()`.
- `errors(400)` and `errors(400, 404)` add standard OpenAPI error response schemas.
- Every route factory is wrapped in `lazy()` for deferred initialization.

---

## 4. Error Middleware (`server/middleware.ts` + `server/error.ts`)

### NamedError Base Class (`packages/util/src/error.ts`)

```typescript
export abstract class NamedError extends Error {
  abstract schema(): z.core.$ZodType
  abstract toObject(): { name: string; data: any }

  static create<Name extends string, Data extends z.core.$ZodType>(name: Name, data: Data) {
    const schema = z
      .object({
        name: z.literal(name),
        data,
      })
      .meta({ ref: name })
    const result = class extends NamedError {
      public static readonly Schema = schema
      public override readonly name = name as Name

      constructor(
        public readonly data: z.input<Data>,
        options?: ErrorOptions,
      ) {
        super(name, options)
        this.name = name
      }

      static isInstance(input: any): input is InstanceType<typeof result> {
        return typeof input === "object" && "name" in input && input.name === name
      }

      schema() { return schema }
      toObject() { return { name: name, data: this.data } }
    }
    Object.defineProperty(result, "name", { value: name })
    return result
  }

  public static readonly Unknown = NamedError.create(
    "UnknownError",
    z.object({ message: z.string() }),
  )
}
```

### Error Handler (`server/middleware.ts`)

```typescript
export function errorHandler(log: Log.Logger): ErrorHandler {
  return (err, c) => {
    log.error("failed", { error: err })
    if (err instanceof NamedError) {
      let status: ContentfulStatusCode
      if (err instanceof NotFoundError) status = 404
      else if (err instanceof Provider.ModelNotFoundError) status = 400
      else if (err.name.startsWith("Worktree")) status = 400
      else status = 500
      return c.json(err.toObject(), { status })
    }
    if (err instanceof HTTPException) return err.getResponse()
    return c.json(new NamedError.Unknown({ message: err.stack ?? err.toString() }).toObject(), { status: 500 })
  }
}
```

### OpenAPI Error Schemas (`server/error.ts`)

```typescript
export const ERRORS = {
  400: {
    description: "Bad request",
    content: {
      "application/json": {
        schema: resolver(
          z.object({
            data: z.any(),
            errors: z.array(z.record(z.string(), z.any())),
            success: z.literal(false),
          }).meta({ ref: "BadRequestError" }),
        ),
      },
    },
  },
  404: {
    description: "Not found",
    content: {
      "application/json": {
        schema: resolver(NotFoundError.Schema),
      },
    },
  },
} as const

export function errors(...codes: number[]) {
  return Object.fromEntries(codes.map((code) => [code, ERRORS[code as keyof typeof ERRORS]]))
}
```

### Error-to-HTTP Status Mapping

| Error | HTTP Status |
|---|---|
| `NotFoundError` | 404 |
| `Provider.ModelNotFoundError` | 400 |
| `ProviderAuthValidationFailed` | 400 |
| Any `Worktree*` error (name starts with "Worktree") | 400 |
| Any other `NamedError` subclass | 500 |
| Hono `HTTPException` | exception's own status |
| Any other `Error` | 500 (wrapped as `UnknownError`) |

All error responses are `{ name: string, data: any }` -- the `toObject()` shape.

---

## 5. Config System (`config/config.ts`)

### Config File Discovery (`config/paths.ts`)

```typescript
export namespace ConfigPaths {
  export async function projectFiles(name: string, directory: string, worktree: string) {
    const files: string[] = []
    for (const file of [`${name}.jsonc`, `${name}.json`]) {
      const found = await Filesystem.findUp(file, directory, worktree)
      for (const resolved of found.toReversed()) {
        files.push(resolved)
      }
    }
    return files
  }

  export async function directories(directory: string, worktree: string) {
    return [
      Global.Path.config,
      ...(!Flag.OPENCODE_DISABLE_PROJECT_CONFIG
        ? await Array.fromAsync(
            Filesystem.up({
              targets: [".opencode"],
              start: directory,
              stop: worktree,
            }),
          )
        : []),
      ...(await Array.fromAsync(
        Filesystem.up({
          targets: [".opencode"],
          start: Global.Path.home,
          stop: Global.Path.home,
        }),
      )),
      ...(Flag.OPENCODE_CONFIG_DIR ? [Flag.OPENCODE_CONFIG_DIR] : []),
    ]
  }

  export function fileInDirectory(dir: string, name: string) {
    return [path.join(dir, `${name}.jsonc`), path.join(dir, `${name}.json`)]
  }
}
```

### Config Merge Order (lowest to highest priority)

1. Global config dir (`~/.config/opencode/opencode.jsonc` or `.json`)
2. Custom config (via `OPENCODE_TUI_CONFIG` flag, for TUI configs)
3. Project-level files (found via `findUp` from cwd to worktree root)
4. `.opencode` directories
5. Managed config dir (enterprise: `/Library/Application Support/opencode` on macOS, `/etc/opencode` on Linux, `C:\ProgramData\opencode` on Windows) -- highest priority

```typescript
function systemManagedConfigDir(): string {
  switch (process.platform) {
    case "darwin":
      return "/Library/Application Support/opencode"
    case "win32":
      return path.join(process.env.ProgramData || "C:\\ProgramData", "opencode")
    default:
      return "/etc/opencode"
  }
}
```

TUI config merge (same principle applies to main config):

```typescript
const state = Instance.state(async () => {
  let projectFiles = Flag.OPENCODE_DISABLE_PROJECT_CONFIG
    ? []
    : await ConfigPaths.projectFiles("tui", Instance.directory, Instance.worktree)
  const directories = await ConfigPaths.directories(Instance.directory, Instance.worktree)
  const custom = customPath()
  const managed = Config.managedConfigDir()

  const acc: Acc = { result: {}, entries: [] }

  // 1. Global config
  for (const file of ConfigPaths.fileInDirectory(Global.Path.config, "tui")) {
    await mergeFile(acc, file)
  }
  // 2. Custom config
  if (custom) { await mergeFile(acc, custom) }
  // 3. Project files
  for (const file of projectFiles) { await mergeFile(acc, file) }
  // 4. .opencode directories
  for (const dir of unique(directories)) {
    if (!dir.endsWith(".opencode") && dir !== Flag.OPENCODE_CONFIG_DIR) continue
    for (const file of ConfigPaths.fileInDirectory(dir, "tui")) {
      await mergeFile(acc, file)
    }
  }
  // 5. Managed (enterprise) config -- highest priority
  if (existsSync(managed)) {
    for (const file of ConfigPaths.fileInDirectory(managed, "tui")) {
      await mergeFile(acc, file)
    }
  }

  const merged = dedupePlugins(acc.entries)
  acc.result.keybinds = Config.Keybinds.parse(acc.result.keybinds ?? {})
  acc.result.plugin = merged.map((item) => item.item)
  return { config: acc.result, deps }
})
```

### Array Concatenation (not replacement)

`plugin` and `instructions` arrays are concatenated across config layers, not overwritten:

```typescript
function mergeConfigConcatArrays(target: Info, source: Info): Info {
  const merged = mergeDeep(target, source)
  if (target.plugin && source.plugin) {
    merged.plugin = Array.from(new Set([...target.plugin, ...source.plugin]))
  }
  if (target.instructions && source.instructions) {
    merged.instructions = Array.from(new Set([...target.instructions, ...source.instructions]))
  }
  return merged
}
```

### Plugin Deduplication (later entries = higher priority)

```typescript
export function deduplicatePlugins(plugins: PluginSpec[]): PluginSpec[] {
  const seenNames = new Set<string>()
  const uniqueSpecifiers: PluginSpec[] = []

  for (const specifier of plugins.toReversed()) {
    const spec = pluginSpecifier(specifier)
    const name = spec.startsWith("file://") ? spec : parsePluginSpecifier(spec).pkg
    if (!seenNames.has(name)) {
      seenNames.add(name)
      uniqueSpecifiers.push(specifier)
    }
  }

  return uniqueSpecifiers.toReversed()
}
```

### Config Substitution (`{env:VAR}` and `{file:path}`)

Config values support variable expansion before parsing:

```typescript
async function substitute(text: string, input: ParseSource, missing: "error" | "empty" = "error") {
  text = text.replace(/\{env:([^}]+)\}/g, (_, varName) => {
    return process.env[varName] || ""
  })

  const fileMatches = Array.from(text.matchAll(/\{file:[^}]+\}/g))
  if (!fileMatches.length) return text

  const configDir = dir(input)
  let out = ""
  let cursor = 0

  for (const match of fileMatches) {
    const token = match[0]
    const index = match.index!
    out += text.slice(cursor, index)

    // Skip tokens inside comments
    const lineStart = text.lastIndexOf("\n", index - 1) + 1
    const prefix = text.slice(lineStart, index).trimStart()
    if (prefix.startsWith("//")) {
      out += token
      cursor = index + token.length
      continue
    }

    let filePath = token.replace(/^\{file:/, "").replace(/\}$/, "")
    if (filePath.startsWith("~/")) {
      filePath = path.join(os.homedir(), filePath.slice(2))
    }

    const resolvedPath = path.isAbsolute(filePath) ? filePath : path.resolve(configDir, filePath)
    const fileContent = (
      await Filesystem.readText(resolvedPath).catch((error: NodeJS.ErrnoException) => {
        if (missing === "empty") return ""
        // ... error handling
      })
    ).trim()

    out += JSON.stringify(fileContent).slice(1, -1)
    cursor = index + token.length
  }

  out += text.slice(cursor)
  return out
}
```

### JSONC Text Patching (plugin install)

Config updates for plugin installation operate on raw JSONC text, not parse-serialize cycles. This preserves comments, formatting, and trailing commas:

```typescript
export async function patchPluginConfig(input: PatchInput, dep: PatchDeps = defaultPatchDeps): Promise<PatchResult> {
  const dir = patchDir(input)
  const items: PatchItem[] = []
  for (const target of input.targets) {
    const hit = await patchOne(dir, target, input.spec, Boolean(input.force), dep)
    if (!hit.ok) return { ...hit, dir }
    items.push(hit.item)
  }
  return { ok: true, dir, items }
}

function patchPluginList(list: unknown[], spec: string, next: unknown, force = false): { mode: Mode; list: unknown[] } {
  const pkg = parsePluginSpecifier(spec).pkg
  const rows = list.map((item, i) => ({ item, i, spec: pluginSpec(item) }))
  const dup = rows.filter((item) => {
    if (!item.spec) return false
    if (item.spec === spec) return true
    if (item.spec.startsWith("file://")) return false
    return parsePluginSpecifier(item.spec).pkg === pkg
  })
  if (!dup.length) return { mode: "add", list: [...list, next] }
  if (!force) return { mode: "noop", list }
  // ... replace logic
}
```

### Dependency Installation (flock + bun)

```typescript
export async function installDependencies(dir: string, input?: InstallInput) {
  if (!(await needsInstall(dir))) return

  await using _ = await Flock.acquire(`config-install:${Filesystem.resolve(dir)}`, {
    signal: input?.signal,
    onWait: (tick) => input?.waitTick?.({ dir, attempt: tick.attempt, delay: tick.delay, waited: tick.waited }),
  })

  input?.signal?.throwIfAborted()
  if (!(await needsInstall(dir))) return

  const pkg = path.join(dir, "package.json")
  const target = Installation.isLocal() ? "*" : Installation.VERSION

  const json = await Filesystem.readJson<{ dependencies?: Record<string, string> }>(pkg).catch(() => ({
    dependencies: {},
  }))
  json.dependencies = { ...json.dependencies, "@opencode-ai/plugin": target }
  await Filesystem.writeJson(pkg, json)

  // Serialize installs globally on win32, keep parallel on other platforms
  await using __ =
    process.platform === "win32"
      ? await Flock.acquire("config-install:bun", { signal: input?.signal })
      : undefined

  await BunProc.run(
    ["install", ...(proxied() || process.env.CI ? ["--no-cache"] : [])],
    { cwd: dir, abort: input?.signal },
  )
}
```

---

## 6. Plugin Lifecycle (`plugin/index.ts`)

### Effect Service Definition

```typescript
export namespace Plugin {
  type TriggerName = {
    [K in keyof Hooks]-?: NonNullable<Hooks[K]> extends (input: any, output: any) => Promise<void> ? K : never
  }[keyof Hooks]

  export interface Interface {
    readonly trigger: <Name extends TriggerName, Input, Output>(
      name: Name, input: Input, output: Output,
    ) => Effect.Effect<Output>
    readonly list: () => Effect.Effect<Hooks[]>
    readonly init: () => Effect.Effect<void>
  }

  export class Service extends ServiceMap.Service<Service, Interface>()("@opencode/Plugin") {}

  const INTERNAL_PLUGINS: PluginInstance[] = [CodexAuthPlugin, CopilotAuthPlugin, GitlabAuthPlugin, PoeAuthPlugin]
```

### Init Sequence (local SDK client, internal then external, hook fanout)

```typescript
  export const layer = Layer.effect(
    Service,
    Effect.gen(function* () {
      const bus = yield* Bus.Service
      const config = yield* Config.Service

      const cache = yield* InstanceState.make<State>(
        Effect.fn("Plugin.state")(function* (ctx) {
          const hooks: Hooks[] = []

          // Step 1: Create local SDK client (in-process fetch, no network)
          const { Server } = yield* Effect.promise(() => import("../server/server"))
          const client = createOpencodeClient({
            baseUrl: "http://localhost:4096",
            directory: ctx.directory,
            headers: Flag.OPENCODE_SERVER_PASSWORD ? { /* basic auth */ } : undefined,
            fetch: async (...args) => Server.Default().fetch(...args),
          })
          const cfg = yield* config.get()
          const input: PluginInput = {
            client, project: ctx.project, worktree: ctx.worktree,
            directory: ctx.directory,
            get serverUrl(): URL { return Server.url ?? new URL("http://localhost:4096") },
            $: Bun.$,
          }

          // Step 2: Load internal plugins first
          for (const plugin of INTERNAL_PLUGINS) {
            const init = yield* Effect.tryPromise({
              try: () => plugin(input),
              catch: (err) => { log.error("failed to load internal plugin", { name: plugin.name, error: err }) },
            }).pipe(Effect.option)
            if (init._tag === "Some") hooks.push(init.value)
          }

          // Step 3: Load external plugins (sequential for deterministic hook order)
          const plugins = Flag.OPENCODE_PURE ? [] : (cfg.plugin ?? [])
          if (plugins.length) yield* config.waitForDependencies()

          const loaded = yield* Effect.promise(() => Promise.all(plugins.map((item) => prepPlugin(item))))
          for (const load of loaded) {
            if (!load) continue
            yield* Effect.tryPromise({
              try: () => applyPlugin(load, input, hooks),
              catch: (err) => { /* error handling */ },
            }).pipe(Effect.catch((message) => bus.publish(Session.Event.Error, { /* ... */ })))
          }

          // Step 4: Notify plugins of current config
          for (const hook of hooks) {
            yield* Effect.tryPromise({
              try: () => Promise.resolve((hook as any).config?.(cfg)),
            }).pipe(Effect.ignore)
          }

          // Step 5: Subscribe to bus events and fan out to all plugins
          yield* bus.subscribeAll().pipe(
            Stream.runForEach((input) =>
              Effect.sync(() => {
                for (const hook of hooks) {
                  hook["event"]?.({ event: input as any })
                }
              }),
            ),
            Effect.forkScoped,
          )

          return { hooks }
        }),
      )
```

### Hook Trigger Fanout

```typescript
      const trigger = Effect.fn("Plugin.trigger")(function* <
        Name extends TriggerName,
        Input = Parameters<Required<Hooks>[Name]>[0],
        Output = Parameters<Required<Hooks>[Name]>[1],
      >(name: Name, input: Input, output: Output) {
        if (!name) return output
        const state = yield* InstanceState.get(cache)
        for (const hook of state.hooks) {
          const fn = hook[name] as any
          if (!fn) continue
          yield* Effect.promise(() => fn(input, output))
        }
        return output
      })
```

### Plugin Resolution (`plugin/shared.ts`)

```typescript
export function parsePluginSpecifier(spec: string) {
  const lastAt = spec.lastIndexOf("@")
  const pkg = lastAt > 0 ? spec.substring(0, lastAt) : spec
  const version = lastAt > 0 ? spec.substring(lastAt + 1) : "latest"
  return { pkg, version }
}

export type PluginSource = "file" | "npm"

export function pluginSource(spec: string): PluginSource {
  return spec.startsWith("file://") ? "file" : "npm"
}

export async function resolvePluginEntrypoint(spec: string, target: string, kind: PluginKind) {
  const pkg = await readPluginPackage(target).catch(() => undefined)
  if (!pkg) return target
  if (!hasEntrypoint(pkg.json, kind)) return target
  const exports = pkg.json.exports
  if (!isRecord(exports)) return target
  const raw = extractExportValue(exports[`./${kind}`])
  if (!raw) return target
  const resolved = resolveExportPath(raw, pkg.dir)
  const root = Filesystem.resolve(pkg.dir)
  const next = Filesystem.resolve(resolved)
  if (!Filesystem.contains(root, next)) {
    throw new Error(`Plugin ${spec} resolved ${kind} entry outside plugin directory`)
  }
  return pathToFileURL(next).href
}
```

### Export Dedup and Promise API

```typescript
  export const defaultLayer = layer.pipe(
    Layer.provide(Bus.layer),
    Layer.provide(Config.defaultLayer),
  )
  const { runPromise } = makeRuntime(Service, defaultLayer)

  export async function trigger<Name extends TriggerName, Input, Output>(
    name: Name, input: Input, output: Output,
  ): Promise<Output> {
    return runPromise((svc) => svc.trigger(name, input, output))
  }

  export async function list(): Promise<Hooks[]> {
    return runPromise((svc) => svc.list())
  }

  export async function init() {
    return runPromise((svc) => svc.init())
  }
}
```

Plugin lifecycle summary:
1. Create in-process SDK client (routes through `Server.Default().fetch`, no network)
2. Load internal auth plugins (Codex, Copilot, Gitlab, Poe)
3. Wait for dependency installation, then load external plugins sequentially
4. Deduplicate exports (later entries override by package name)
5. Notify all plugins with current config via `hook.config(cfg)`
6. Fork a scoped fiber that fans bus events to all `hook.event()` handlers

---

## 7. Project/Instance Lifecycle

### Instance Context (`project/instance.ts`)

```typescript
export interface InstanceContext {
  directory: string
  worktree: string
  project: Project.Info
}

const context = Context.create<InstanceContext>("instance")
const cache = new Map<string, Promise<InstanceContext>>()

export const Instance = {
  async provide<R>(input: { directory: string; init?: () => Promise<any>; fn: () => R }): Promise<R> {
    const directory = Filesystem.resolve(input.directory)
    let existing = cache.get(directory)
    if (!existing) {
      Log.Default.info("creating instance", { directory })
      existing = track(directory, boot({ directory, init: input.init }))
    }
    const ctx = await existing
    return context.provide(ctx, async () => { return input.fn() })
  },

  get current() { return context.use() },
  get directory() { return context.use().directory },
  get worktree() { return context.use().worktree },
  get project() { return context.use().project },

  containsPath(filepath: string) {
    if (Filesystem.contains(Instance.directory, filepath)) return true
    if (Instance.worktree === "/") return false
    return Filesystem.contains(Instance.worktree, filepath)
  },

  bind<F extends (...args: any[]) => any>(fn: F): F {
    const ctx = context.use()
    return ((...args: any[]) => context.provide(ctx, () => fn(...args))) as F
  },

  state<S>(init: () => S, dispose?: (state: Awaited<S>) => Promise<void>): () => S {
    return State.create(() => Instance.directory, init, dispose)
  },

  async reload(input) {
    const directory = Filesystem.resolve(input.directory)
    await Promise.all([State.dispose(directory), disposeInstance(directory)])
    cache.delete(directory)
    const next = track(directory, boot({ ...input, directory }))
    emit(directory)
    return await next
  },

  async dispose() {
    const directory = Instance.directory
    await Promise.all([State.dispose(directory), disposeInstance(directory)])
    cache.delete(directory)
    emit(directory)
  },
}
```

### State Management (`project/state.ts`)

Per-directory state keyed by `init` function identity:

```typescript
export namespace State {
  const recordsByKey = new Map<string, Map<any, Entry>>()

  export function create<S>(root: () => string, init: () => S, dispose?: (state: Awaited<S>) => Promise<void>) {
    return () => {
      const key = root()
      let entries = recordsByKey.get(key)
      if (!entries) {
        entries = new Map<string, Entry>()
        recordsByKey.set(key, entries)
      }
      const exists = entries.get(init)
      if (exists) return exists.state as S
      const state = init()
      entries.set(init, { state, dispose })
      return state
    }
  }

  export async function dispose(key: string) {
    const entries = recordsByKey.get(key)
    if (!entries) return
    const tasks: Promise<void>[] = []
    for (const [init, entry] of entries) {
      if (!entry.dispose) continue
      tasks.push(Promise.resolve(entry.state).then((state) => entry.dispose!(state)).catch(/* ... */))
    }
    await Promise.all(tasks)
    entries.clear()
    recordsByKey.delete(key)
  }
}
```

### Instance Bootstrap (`project/bootstrap.ts`)

```typescript
export async function InstanceBootstrap() {
  Log.Default.info("bootstrapping", { directory: Instance.directory })
  await Plugin.init()
  ShareNext.init()
  Format.init()
  await LSP.init()
  File.init()
  FileWatcher.init()
  Vcs.init()
  Snapshot.init()

  Bus.subscribe(Command.Event.Executed, async (payload) => {
    if (payload.properties.name === Command.Default.INIT) {
      Project.setInitialized(Instance.project.id)
    }
  })
}
```

### CLI Bootstrap (`cli/bootstrap.ts`)

```typescript
export async function bootstrap<T>(directory: string, cb: () => Promise<T>) {
  return Instance.provide({
    directory,
    init: InstanceBootstrap,
    fn: async () => {
      try {
        const result = await cb()
        return result
      } finally {
        await Instance.dispose()
      }
    },
  })
}
```

Full lifecycle:
1. `Instance.provide({ directory, init: InstanceBootstrap, fn })` resolves/caches the context
2. `boot()` discovers the project (git info, worktree, DB upsert), then calls `init`
3. `InstanceBootstrap` runs: Plugin.init -> ShareNext -> Format -> LSP -> File -> FileWatcher -> Vcs -> Snapshot
4. The `fn` callback runs inside the async-local-storage context
5. On dispose: all `State` entries for that directory are disposed, instance cache is cleared

The HTTP server path: every request hits `InstanceRoutes` middleware, which calls `Instance.provide` with the request's directory. If the instance was already bootstrapped for that directory, it reuses the cached context. The handler runs inside that context, so `Instance.directory`, `Instance.project`, etc. are available in any code called from the handler.
