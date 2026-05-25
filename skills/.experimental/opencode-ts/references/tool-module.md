# Tool Module Reference

How tools are defined, registered, wired into the prompt loop, and executed in opencode.

---

## 1. Tool Anatomy

`Tool.define(id, init)` takes an `id` and an **Effect** that yields the tool def (`{ parameters, description, execute }`). Parameters are an Effect `Schema` (`Schema.Decoder<unknown>`); `wrap` compiles the decoder once per init and validates every call with `Schema.decodeUnknownEffect`. Verbatim from `tool/tool.ts` (lightly trimmed):

```typescript
import { Effect, Schema } from "effect"
import type { JSONSchema7 } from "@ai-sdk/provider"
import * as Truncate from "./truncate"
import { Agent } from "@/agent/agent"

// Raised when the LLM calls a tool with arguments that fail the parameter
// schema. The typed error class makes it matchable upstream; its `message`
// getter is the model-facing "rewrite the input" prose the AI SDK feeds back.
export class InvalidArgumentsError extends Schema.TaggedErrorClass<InvalidArgumentsError>()(
  "ToolInvalidArgumentsError",
  { tool: Schema.String, detail: Schema.String },
) {
  override get message() {
    return `The ${this.tool} tool was called with invalid arguments: ${this.detail}.\nPlease rewrite the input so it satisfies the expected schema.`
  }
}

export interface Def<
  Parameters extends Schema.Decoder<unknown> = Schema.Decoder<unknown>,
  M extends Metadata = Metadata,
> {
  id: string
  description: string
  parameters: Parameters
  jsonSchema?: JSONSchema7
  execute(args: Schema.Schema.Type<Parameters>, ctx: Context): Effect.Effect<ExecuteResult<M>>
  formatValidationError?(error: unknown): string
}

export interface Info<
  Parameters extends Schema.Decoder<unknown> = Schema.Decoder<unknown>,
  M extends Metadata = Metadata,
> {
  id: string
  init: () => Effect.Effect<DefWithoutID<Parameters, M>>
}

function wrap<Parameters extends Schema.Decoder<unknown>, Result extends Metadata>(
  id: string,
  init: Init<Parameters, Result>,
  truncate: Truncate.Interface,
  agents: Agent.Interface,
) {
  return () =>
    Effect.gen(function* () {
      const toolInfo = typeof init === "function" ? { ...(yield* init()) } : { ...init }
      // Compile the parser closure once per tool init; `decodeUnknownEffect`
      // allocates a new closure per call, so hoisting avoids re-closing it.
      const decode = Schema.decodeUnknownEffect(toolInfo.parameters)
      const execute = toolInfo.execute
      toolInfo.execute = (args, ctx) =>
        Effect.gen(function* () {
          const decoded = yield* decode(args).pipe(
            Effect.mapError(
              (error) =>
                new InvalidArgumentsError({
                  tool: id,
                  detail: toolInfo.formatValidationError ? toolInfo.formatValidationError(error) : String(error),
                }),
            ),
          )
          const result = yield* execute(decoded as Schema.Schema.Type<Parameters>, ctx)
          // auto-truncate output unless the tool explicitly set metadata.truncated
          if (result.metadata.truncated !== undefined) return result
          const agent = yield* agents.get(ctx.agent)
          const truncated = yield* truncate.output(result.output, {}, agent)
          return {
            ...result,
            output: truncated.content,
            metadata: { ...result.metadata, truncated: truncated.truncated },
          }
        }).pipe(Effect.orDie, Effect.withSpan("Tool.execute", { attributes: { "tool.name": id } }))
      return toolInfo
    })
}

export function define<
  Parameters extends Schema.Decoder<unknown>,
  Result extends Metadata,
  R,
  ID extends string = string,
>(
  id: ID,
  init: Effect.Effect<Init<Parameters, Result>, never, R>,
): Effect.Effect<Info<Parameters, Result>, never, R | Truncate.Service | Agent.Service> & { id: ID } {
  return Object.assign(
    Effect.gen(function* () {
      const resolved = yield* init
      const truncate = yield* Truncate.Service
      const agents = yield* Agent.Service
      return { id, init: wrap(id, resolved, truncate, agents) }
    }),
    { id },
  )
}

export * as Tool from "./tool"
```

The wrapping gives every tool three guarantees for free:
1. Input validated against the Effect `Schema`; on failure the model gets `InvalidArgumentsError` whose `message` tells it to rewrite the input
2. Output auto-truncated to 2000 lines / 50 KB (whichever hits first)
3. Tools that handle their own truncation opt out by setting `metadata.truncated`

`define` returns an `Effect` (it needs `Truncate.Service` + `Agent.Service`), so a tool is itself a value in the layer graph — not a plain object.

---

## 2. Complete Tool: read.ts

The Read tool demonstrates all standard patterns: an Effect `Schema` parameters object, dependencies acquired in `define`'s `Effect.gen`, permission checking via `ctx.ask` (yielded), binary detection, dual truncation (lines + bytes), and instruction auto-discovery. Parameters and `define` shape are verbatim; the `execute` body is sketched.

```typescript
import { Effect, Option, Schema, Scope, Stream } from "effect"
import { NonNegativeInt } from "@opencode-ai/core/schema"
import * as Tool from "./tool"
import { AppFileSystem } from "@opencode-ai/core/filesystem"
import { LSP } from "@/lsp/lsp"
import DESCRIPTION from "./read.txt"
import { Instruction } from "../session/instruction"
import { Reference } from "@/reference/reference"

const DEFAULT_READ_LIMIT = 2000
const MAX_LINE_LENGTH = 2000
const MAX_BYTES = 50 * 1024 // 50 KB

// `offset`/`limit` were `z.coerce.number()`; coercion is pointless on the LLM
// tool-call path (the model emits typed JSON), so they're now plain
// NonNegativeInt. JSON Schema output is identical (`type: "number"`).
export const Parameters = Schema.Struct({
  filePath: Schema.String.annotate({ description: "The absolute path to the file or directory to read" }),
  offset: Schema.optional(NonNegativeInt).annotate({
    description: "The line number to start reading from (1-indexed)",
  }),
  limit: Schema.optional(NonNegativeInt).annotate({
    description: "The maximum number of lines to read (defaults to 2000)",
  }),
})

export const ReadTool = Tool.define(
  "read",
  Effect.gen(function* () {
    // Dependencies are services, acquired once when the tool initializes.
    const fs = yield* AppFileSystem.Service
    const instruction = yield* Instruction.Service
    const lsp = yield* LSP.Service
    const reference = yield* Reference.Service

    return {
      description: DESCRIPTION,
      parameters: Parameters,
      execute: Effect.fn("ReadTool.execute")(function* (params, ctx) {
        // 1. Permission check for paths outside workspace.
        //    yield* ctx.ask fails with Permission.RejectedError if denied.
        yield* ctx.ask({ permission: "read", patterns: [params.filePath] })

        // 2. Binary detection -- return early, don't blow up context.
        const stat = yield* fs.stat(params.filePath)
        if (yield* isBinary(fs, params.filePath, stat.size)) {
          return {
            title: params.filePath,
            output: `File is binary (${stat.size} bytes). Use bash to process binary files.`,
            metadata: { truncated: false },
          }
        }

        // 3. Read with dual truncation (lines + bytes); each line capped at
        //    MAX_LINE_LENGTH to handle minified files. Output is
        //    "lineNumber: content" so the model can reference lines for edits.
        const content = yield* fs.readText(params.filePath)
        const lines = content.split("\n")
        const offset = params.offset ?? 0
        const slice = lines.slice(offset, offset + (params.limit ?? DEFAULT_READ_LIMIT))
        // ...byte-accumulation loop omitted...

        // 4. Auto-discover AGENTS.md up the tree so context-specific rules load
        //    without the model knowing about them (claimed per-messageID).
        yield* instruction.resolve(ctx.messages, params.filePath, ctx.messageID)

        return {
          title: params.filePath,
          output: slice.map((line, i) => `${i + offset}: ${line}`).join("\n"),
          metadata: { truncated: slice.length < lines.length },
        }
      }),
    }
  }),
)
```

Key non-obvious decisions:
- `define` takes an `Effect.gen` that yields service dependencies, then returns `{ description, parameters, execute }`. `execute` is an Effect-returning function (`Effect.fn`), not `async`.
- `metadata.truncated` is set explicitly, so the `Tool.define` wrapper skips its own truncation pass.
- Line numbers in output start from `offset`, not 0 — the model uses these for edit operations.
- Parameter names are camelCase (`filePath`), matching the Effect Schema field names emitted into the JSON Schema the model sees.

---

## 3. Tool Registry

The registry is an Effect service that loads built-in tools, plugin tools, and applies model-gating.

```typescript
export const layer = Layer.effect(Service, Effect.gen(function* () {
  const config = yield* Config.Service
  const plugin = yield* Plugin.Service

  // WHY: custom tools loaded from {tool,tools}/*.{js,ts} in config directories
  const cache = yield* InstanceState.make<State>(Effect.fn("ToolRegistry.state")(function* (ctx) {
    const custom: Tool.Info[] = []
    const dirs = yield* config.directories()
    const matches = dirs.flatMap(dir =>
      Glob.scanSync("{tool,tools}/*.{js,ts}", { cwd: dir, absolute: true, dot: true, symlink: true })
    )
    if (matches.length) yield* config.waitForDependencies()
    for (const match of matches) {
      const namespace = path.basename(match, path.extname(match))
      const mod = yield* Effect.promise(() => import(pathToFileURL(match).href))
      // WHY: default export uses filename as ID; named exports get filename_exportName
      for (const [id, def] of Object.entries<ToolDefinition>(mod)) {
        custom.push(fromPlugin(id === "default" ? namespace : `${namespace}_${id}`, def))
      }
    }
    return { custom }
  }))

  // Model-aware tool filtering at resolution time
  const tools = Effect.fn("ToolRegistry.tools")(function* (model, agent?) {
    const filtered = allTools.filter(tool => {
      // WHY: codesearch/websearch gated to opencode provider or explicit EXA flag
      if (tool.id === "codesearch" || tool.id === "websearch")
        return model.providerID === ProviderID.opencode || Flag.OPENCODE_ENABLE_EXA

      // WHY: GPT-5+ uses apply_patch instead of edit/write -- different editing paradigm
      const usePatch = model.modelID.includes("gpt-") && !model.modelID.includes("oss") && !model.modelID.includes("gpt-4")
      if (tool.id === "apply_patch") return usePatch
      if (tool.id === "edit" || tool.id === "write") return !usePatch

      return true
    })

    // WHY: all tools initialized concurrently -- Tool.init is an Effect that
    // runs the wrapped init() (no args; agent context is read inside execute)
    return yield* Effect.forEach(filtered, tool => {
      const next = yield* Tool.init(tool)
      // WHY: plugin hook can modify tool description/parameters after init
      yield* plugin.trigger("tool.definition", { toolID: tool.id }, output)
      return { id: tool.id, ...next }
    }, { concurrency: "unbounded" })
  })
}))
```

The Invalid Tool acts as an error sink for unrecognized tool calls:

```typescript
export const InvalidTool = Tool.define(
  "invalid",
  Effect.succeed({
    description: "Do not use",
    parameters: Schema.Struct({ tool: Schema.String, error: Schema.String }),
    execute: Effect.fn("InvalidTool.execute")(function* (params) {
      return {
        title: "Invalid Tool",
        output: `The arguments provided to the tool are invalid: ${params.error}`,
        metadata: {},
      }
    }),
  }),
)
```

This is wired into `experimental_repairToolCall` in the LLM stream -- when a tool call cannot be repaired by lowercasing its name, it gets routed here instead of throwing.

---

## 4. Tool Context

Every tool's `execute` receives `(args, ctx)`. The `ctx` shape:

```typescript
export type Context<M extends Metadata = Metadata> = {
  sessionID: SessionID                 // current session
  messageID: MessageID                 // current assistant message
  agent: string                        // agent name (e.g., "code", "explore")
  abort: AbortSignal                   // cancellation signal
  callID?: string                      // unique ID for this tool invocation
  extra?: { [key: string]: unknown }   // grab-bag: model info, bypass flags
  messages: MessageV2.WithParts[]      // full conversation history
  metadata(input: { title?: string; metadata?: M }): Effect.Effect<void> // live-update tool part for streaming UI
  ask(input: Omit<Permission.Request, "id" | "sessionID" | "tool">): Effect.Effect<void> // permission gate -- fails RejectedError if denied
}
```

`metadata` and `ask` return `Effect`s — yield them inside `execute`. Usage patterns:
- `yield* ctx.metadata({ title: "Reading file..." })` -- updates the tool card in the UI in real-time
- `yield* ctx.ask({ permission: "bash", patterns: ["npm install"] })` -- checks permission rules, prompts user if needed, fails with `Permission.RejectedError` on deny
- `ctx.abort.throwIfAborted()` -- check cancellation during long operations
- `ctx.extra?.model` -- access the current model info for provider-specific behavior
- `ctx.messages` -- full conversation history for tools that need context (e.g., compaction)

---

## 5. Session Prompt Loop

The prompt loop in `prompt.ts` wires tools into the LLM conversation. Three key phases: tool resolution, stream processing, and the main loop dispatch.

### 5.1 Tool Resolution: resolveTools

Builds the `Record<string, AITool>` passed to the LLM stream. Each registered tool gets wrapped with context construction, permission checking, and plugin hooks. This is an Effect-based sketch (the real `prompt.ts` is longer); note that `ctx.metadata`/`ctx.ask` return Effects and dependencies like `Permission`/`Plugin` are acquired via `yield*`.

```typescript
export const resolveTools = Effect.fn("resolveTools")(function* (input: {
  agent, model, session, tools?, processor, bypassAgentCheck, messages
}) {
  const tools: Record<string, AITool> = {}
  const permission = yield* Permission.Service
  const plugin = yield* Plugin.Service

  // WHY: context factory closes over session/processor state so each tool call
  // gets the right messageID, callID, and live-update capability.
  // metadata/ask return Effects (yielded inside the tool's execute).
  const context = (args, options): Tool.Context => ({
    sessionID: input.session.id,
    abort: options.abortSignal!,
    messageID: input.processor.message.id,
    callID: options.toolCallId,
    extra: { model: input.model, bypassAgentCheck: input.bypassAgentCheck },
    agent: input.agent.name,
    messages: input.messages,
    metadata: (val) =>
      // WHY: live-update the tool part via processor tracking for streaming UI
      Effect.gen(function* () {
        const match = input.processor.partFromToolCall(options.toolCallId)
        if (match && match.state.status === "running") {
          yield* Session.updatePart({ ...match, state: { title: val.title, metadata: val.metadata } })
        }
      }),
    ask: (req) =>
      // WHY: permission rules merged from agent config + session overrides
      permission.ask({
        ...req,
        sessionID: input.session.id,
        tool: { messageID: input.processor.message.id, callID: options.toolCallId },
        ruleset: Permission.merge(input.agent.permission, input.session.permission ?? []),
      }),
  })

  // Wrap each registered tool with plugin before/after hooks
  for (const item of yield* ToolRegistry.tools(model, agent)) {
    // JsonSchema.fromTool converts the Effect Schema parameters to JSON Schema
    const schema = ProviderTransform.schema(input.model, JsonSchema.fromTool(item))
    tools[item.id] = tool({
      id: item.id,
      description: item.description,
      inputSchema: jsonSchema(schema),
      // AI SDK's execute is a Promise; the tool Effect (item.execute returns an
      // Effect) is run through the session runtime here, bridging back to async.
      async execute(args, options) {
        const ctx = context(args, options)
        // WHY: plugin hooks can modify args before execution and output after
        yield* plugin.trigger("tool.execute.before", { tool: item.id, sessionID: ctx.sessionID, callID: ctx.callID }, { args })
        const result = yield* item.execute(args, ctx)
        const output = {
          ...result,
          attachments: result.attachments?.map(a => ({
            ...a, id: PartID.ascending(), sessionID, messageID
          })),
        }
        yield* plugin.trigger("tool.execute.after", { tool: item.id, sessionID: ctx.sessionID, callID: ctx.callID, args }, output)
        return output
      },
    })
  }
  return tools
})
```

### 5.2 The Main Loop: While-True with 4-Path Dispatch

```typescript
let step = 0
while (true) {
  await SessionStatus.set(sessionID, { type: "busy" })
  if (abort.aborted) break
  let msgs = await MessageV2.filterCompacted(MessageV2.stream(sessionID))

  // Walk backwards to find lastUser, lastAssistant, lastFinished, and pending tasks
  let lastUser, lastAssistant, lastFinished
  let tasks: (MessageV2.CompactionPart | MessageV2.SubtaskPart)[] = []
  for (let i = msgs.length - 1; i >= 0; i--) { /* ... */ }

  // WHY: exit when assistant finished with a non-tool-call reason
  if (lastAssistant?.finish && !["tool-calls", "unknown"].includes(lastAssistant.finish)
      && lastUser.id < lastAssistant.id) break

  step++
  if (step === 1) ensureTitle({ session, modelID, providerID, history: msgs })

  const task = tasks.pop()

  // PATH 1: Pending subtask (task tool delegation)
  if (task?.type === "subtask") { /* create child session, run tool, continue */ }

  // PATH 2: Pending compaction
  if (task?.type === "compaction") { /* run compaction process, continue or stop */ }

  // PATH 3: Context overflow (auto-compact)
  if (lastFinished && lastFinished.summary !== true
      && await SessionCompaction.isOverflow({ tokens: lastFinished.tokens, model })) {
    await SessionCompaction.create({ sessionID, agent, model, auto: true })
    continue
  }

  // PATH 4: Normal processing (the common case)
  const processor = SessionProcessor.create({ assistantMessage, sessionID, model, abort })
  const tools = await resolveTools({ agent, session, model, ... })
  const result = await processor.process({ user, agent, abort, sessionID, system, messages, tools, model })
  if (result === "stop") break
  if (result === "compact") {
    await SessionCompaction.create({ sessionID, agent, model, auto: true, overflow: !processor.message.finish })
  }
}
// WHY: prune old tool outputs after loop completes to reclaim context for next turn
SessionCompaction.prune({ sessionID })
```

Dispatch priority: subtask > compaction > overflow > normal. The loop only exits on abort, explicit stop, or a non-tool-call finish reason.

### 5.3 Stream Processing: Doom Loop Detection + Retry

The processor wraps `LLM.stream` with tool-call tracking, doom loop detection, and error classification:

```typescript
export function create(input: { assistantMessage, sessionID, model, abort }) {
  const toolcalls: Record<string, MessageV2.ToolPart> = {}
  let blocked = false
  let attempt = 0
  let needsCompaction = false

  return {
    async process(streamInput: LLM.StreamInput) {
      const shouldBreak = (await Config.get()).experimental?.continue_loop_on_deny !== true
      while (true) {
        try {
          const stream = await LLM.stream(streamInput)
          for await (const value of stream.fullStream) {
            input.abort.throwIfAborted()
            switch (value.type) {
              case "tool-call":
                // WHY: doom loop = last 3 tool calls have same name+input
                const lastThree = parts.slice(-DOOM_LOOP_THRESHOLD)
                if (lastThree.length === DOOM_LOOP_THRESHOLD &&
                    lastThree.every(p => p.type === "tool" && p.tool === value.toolName
                      && JSON.stringify(p.state.input) === JSON.stringify(value.input))) {
                  await Permission.ask({ permission: "doom_loop", patterns: [value.toolName] })
                }
                break
              case "tool-error":
                // WHY: permission/question rejection stops the loop (unless experimental flag)
                if (value.error instanceof Permission.RejectedError ||
                    value.error instanceof Question.RejectedError) {
                  blocked = shouldBreak
                }
                break
            }
            if (needsCompaction) break
          }
        } catch (e) {
          const error = MessageV2.fromError(e, { providerID, aborted: abort.aborted })
          if (MessageV2.ContextOverflowError.isInstance(error)) {
            needsCompaction = true
          } else {
            const retry = SessionRetry.retryable(error)
            if (retry !== undefined) {
              attempt++
              const delay = SessionRetry.delay(attempt, error)
              await SessionStatus.set(sessionID, { type: "retry", attempt, message: retry, next: Date.now() + delay })
              await SessionRetry.sleep(delay, abort).catch(() => {})
              continue  // retry the stream
            }
            assistantMessage.error = error
          }
        }
        // WHY: force-error any still-pending/running tools on stream end
        for (const part of parts) {
          if (part.type === "tool" && part.state.status !== "completed" && part.state.status !== "error") {
            await Session.updatePart({ ...part, state: { status: "error", error: "Tool execution aborted" } })
          }
        }
        if (needsCompaction) return "compact"
        if (blocked) return "stop"
        if (assistantMessage.error) return "stop"
        return "continue"
      }
    },
  }
}
```

### 5.4 LLM Stream: Tool Repair + System Prompt Caching

```typescript
export async function stream(input: StreamInput) {
  // WHY: system prompt kept as exactly 2 strings for Anthropic prompt caching
  const system: string[] = []
  system.push([
    ...(input.agent.prompt ? [input.agent.prompt] : SystemPrompt.provider(input.model)),
    ...input.system,
    ...(input.user.system ? [input.user.system] : []),
  ].filter(x => x).join("\n"))

  // Plugin hook can modify system prompt
  await Plugin.trigger("experimental.chat.system.transform", { sessionID, model }, { system })
  // WHY: collapse back to 2 parts after plugin modification for cache efficiency
  if (system.length > 2 && system[0] === header) {
    const rest = system.slice(1)
    system.length = 0
    system.push(header, rest.join("\n"))
  }

  // Provider options: layered merge (base < model < agent < variant)
  const options = pipe(base, mergeDeep(model.options), mergeDeep(agent.options), mergeDeep(variant))

  return streamText({
    // WHY: lowercase repair catches models that emit "Read" instead of "read"
    // WHY: unknown tools route to "invalid" tool rather than crashing the stream
    async experimental_repairToolCall(failed) {
      const lower = failed.toolCall.toolName.toLowerCase()
      if (lower !== failed.toolCall.toolName && tools[lower]) {
        return { ...failed.toolCall, toolName: lower }
      }
      return {
        ...failed.toolCall,
        input: JSON.stringify({ tool: failed.toolCall.toolName, error: failed.error.message }),
        toolName: "invalid",
      }
    },
    model: wrapLanguageModel({
      model: language,
      middleware: [{
        async transformParams(args) {
          // WHY: per-provider message normalization (empty content, tool ID sanitization, etc.)
          if (args.type === "stream") {
            args.params.prompt = ProviderTransform.message(args.params.prompt, input.model, options)
          }
          return args.params
        },
      }],
    }),
  })
}
```

---

## 6. Provider Patterns

### 6.1 Provider Assembly: Bundled SDKs + Custom Loaders

All AI SDK providers are imported statically and stored in a map:

```typescript
const BUNDLED_PROVIDERS: Record<string, (options: any) => SDK> = {
  "@ai-sdk/amazon-bedrock": createAmazonBedrock,
  "@ai-sdk/anthropic": createAnthropic,
  "@ai-sdk/azure": createAzure,
  "@ai-sdk/google": createGoogleGenerativeAI,
  "@ai-sdk/google-vertex": createVertex,
  "@ai-sdk/google-vertex/anthropic": createVertexAnthropic,
  "@ai-sdk/openai": createOpenAI,
  "@ai-sdk/openai-compatible": createOpenAICompatible,
  "@openrouter/ai-sdk-provider": createOpenRouter,
  "@ai-sdk/xai": createXai,
  "@ai-sdk/mistral": createMistral,
  "@ai-sdk/groq": createGroq,
  "@ai-sdk/deepinfra": createDeepInfra,
  "@ai-sdk/cerebras": createCerebras,
  "@ai-sdk/cohere": createCohere,
  "@ai-sdk/gateway": createGateway,
  "@ai-sdk/togetherai": createTogetherAI,
  "@ai-sdk/perplexity": createPerplexity,
  "@ai-sdk/vercel": createVercel,
  "gitlab-ai-provider": createGitLab,
  "@ai-sdk/github-copilot": createGitHubCopilotOpenAICompatible,
}
```

Custom loaders handle provider-specific initialization:

```typescript
const CUSTOM_LOADERS: Record<string, CustomLoader> = {
  // WHY: Anthropic needs beta headers for interleaved thinking + fine-grained tool streaming
  async anthropic() {
    return {
      autoload: false,
      options: {
        headers: { "anthropic-beta": "interleaved-thinking-2025-05-14,fine-grained-tool-streaming-2025-05-14" },
      },
    }
  },
  // WHY: opencode provider filters out paid models when no API key is present
  async opencode(input) {
    const hasKey = await (async () => {
      const env = Env.all()
      if (input.env.some(item => env[item])) return true
      if (await Auth.get(input.id)) return true
      const config = await Config.get()
      if (config.provider?.["opencode"]?.options?.apiKey) return true
      return false
    })()
    if (!hasKey) {
      for (const [key, value] of Object.entries(input.models)) {
        if (value.cost.input === 0) continue  // WHY: free models kept even without key
        delete input.models[key]
      }
    }
    return { autoload: Object.keys(input.models).length > 0, options: hasKey ? {} : { apiKey: "public" } }
  },
  // WHY: OpenAI uses responses API (not chat completions)
  openai: async () => ({
    autoload: false,
    async getModel(sdk, modelID) { return sdk.responses(modelID) },
  }),
  // WHY: Copilot switches API based on model generation
  "github-copilot": async () => ({
    autoload: false,
    async getModel(sdk, modelID) {
      if (useLanguageModel(sdk)) return sdk.languageModel(modelID)
      return shouldUseCopilotResponsesApi(modelID) ? sdk.responses(modelID) : sdk.chat(modelID)
    },
  }),
}
```

`autoload` determines if a provider appears in the model list without explicit config.

### 6.2 Model Registry: Three-Tier Fallback

```typescript
export const Data = lazy(async () => {
  // 1. Try cached file on disk
  const result = await Filesystem.readJson(Flag.OPENCODE_MODELS_PATH ?? filepath).catch(() => {})
  if (result) return result
  // 2. Try bundled snapshot (compiled into the binary)
  const snapshot = await import("./models-snapshot.js").then(m => m.snapshot).catch(() => undefined)
  if (snapshot) return snapshot
  // 3. Fetch from models.dev API
  if (Flag.OPENCODE_DISABLE_MODELS_FETCH) return {}
  const json = await fetch(`${url()}/api.json`).then(x => x.text())
  return JSON.parse(json)
})

// WHY: .unref() so the interval doesn't prevent process exit
if (!Flag.OPENCODE_DISABLE_MODELS_FETCH) {
  ModelsDev.refresh()
  setInterval(() => ModelsDev.refresh(), 60 * 1000 * 60).unref()
}
```

### 6.3 Provider Transform: Per-Provider Message Normalization

Applied via middleware before messages reach the provider API:

```typescript
// WHY: Anthropic rejects empty content parts
if (model.api.npm === "@ai-sdk/anthropic" || model.api.npm === "@ai-sdk/amazon-bedrock") {
  msgs = msgs.filter(msg => msg.content !== "")
    .map(msg => {
      const filtered = msg.content.filter(part => {
        if (part.type === "text" || part.type === "reasoning") return part.text !== ""
        return true
      })
      if (filtered.length === 0) return undefined
      return { ...msg, content: filtered }
    }).filter(Boolean)
}

// WHY: Claude tool call IDs must match [a-zA-Z0-9_-]
if (model.api.id.includes("claude")) {
  // replace non-alphanumeric chars in toolCallId
}

// WHY: Mistral has two quirks:
// 1. Tool call IDs must be exactly 9 alphanumeric chars
// 2. Tool messages cannot be followed by user messages (inject "Done." assistant)
if (model.providerID === "mistral") {
  const normalizedId = part.toolCallId.replace(/[^a-zA-Z0-9]/g, "").substring(0, 9).padEnd(9, "0")
}
```

Cache markers applied to first 2 system messages + last 2 conversation messages, with provider-specific keys:

```typescript
const providerOptions = {
  anthropic: { cacheControl: { type: "ephemeral" } },
  openrouter: { cacheControl: { type: "ephemeral" } },
  bedrock: { cachePoint: { type: "default" } },
  openaiCompatible: { cache_control: { type: "ephemeral" } },
  copilot: { copilot_cache_control: { type: "ephemeral" } },
}
```

### 6.4 Token Cost: Provider-Specific Accounting

```typescript
export const getUsage = fn(Schema.Struct({ model, usage, metadata }), (input) => {
  // WHY: Anthropic does NOT include cached tokens in inputTokens
  // Other providers (OpenRouter, OpenAI, Gemini) DO include them
  const excludesCachedTokens = !!(input.metadata?.["anthropic"] || input.metadata?.["bedrock"])
  const adjustedInputTokens = excludesCachedTokens
    ? inputTokens
    : inputTokens - cacheReadInputTokens - cacheWriteInputTokens

  // WHY: Anthropic doesn't provide total_tokens; compute from components
  const total = iife(() => {
    if (model.api.npm === "@ai-sdk/anthropic" || model.api.npm === "@ai-sdk/amazon-bedrock") {
      return adjustedInputTokens + outputTokens + cacheReadInputTokens + cacheWriteInputTokens
    }
    return input.usage.totalTokens
  })

  // WHY: Decimal.js used for cost math to avoid floating point errors
  // WHY: reasoning tokens billed at output rate
  const cost = Decimal(tokens.reasoning).mul(costInfo?.output ?? 0).div(1_000_000)

  // WHY: over-200K pricing tier for Anthropic models
  const costInfo = model.cost?.experimentalOver200K && tokens.input + tokens.cache.read > 200_000
    ? model.cost.experimentalOver200K : model.cost
})
```

---

## 7. Edit Tool Strategies

The edit tool uses a 9-strategy replacer chain. This is the non-obvious core of the file editing system. Each strategy is a generator that yields candidate match strings. The chain runs in order, stopping at the first unambiguous match.

```typescript
export function replace(content, oldString, newString, replaceAll = false): string {
  for (const replacer of [
    SimpleReplacer,               // 1. exact string match
    LineTrimmedReplacer,          // 2. trim each line before comparing
    BlockAnchorReplacer,          // 3. match first+last lines, fuzzy middle (Levenshtein)
    WhitespaceNormalizedReplacer, // 4. collapse all whitespace
    IndentationFlexibleReplacer,  // 5. strip leading indentation
    EscapeNormalizedReplacer,     // 6. unescape \\n, \\t, etc.
    TrimmedBoundaryReplacer,      // 7. trim entire block as a unit
    ContextAwareReplacer,         // 8. first+last as anchors, 50% middle line match
    MultiOccurrenceReplacer,      // 9. all exact matches (for replaceAll mode)
  ]) {
    for (const search of replacer(content, oldString)) {
      const index = content.indexOf(search)
      if (index === -1) continue
      // WHY: for non-replaceAll mode, match must be unique (no ambiguity)
      if (replaceAll) return content.replaceAll(search, newString)
      const lastIndex = content.lastIndexOf(search)
      if (index !== lastIndex) continue  // multiple matches = ambiguous, try next replacer
      return content.substring(0, index) + newString + content.substring(index + search.length)
    }
  }
  if (notFound) throw new Error("Could not find oldString in the file...")
  throw new Error("Found multiple matches for oldString...")
}
```

Strategy details:

| # | Strategy | What it handles | LLM error pattern |
|---|----------|----------------|-------------------|
| 1 | SimpleReplacer | Exact match | Model got it right |
| 2 | LineTrimmedReplacer | Trim each line | Trailing spaces added/removed |
| 3 | BlockAnchorReplacer | First+last line anchors, Levenshtein middle | Model paraphrased middle lines |
| 4 | WhitespaceNormalizedReplacer | Collapse whitespace | Extra spaces/newlines |
| 5 | IndentationFlexibleReplacer | Strip indentation | Wrong indent level |
| 6 | EscapeNormalizedReplacer | Unescape `\\n`, `\\t` | Model escaped literals |
| 7 | TrimmedBoundaryReplacer | Trim entire block | Leading/trailing whitespace |
| 8 | ContextAwareReplacer | Anchors + 50% middle | Model approximated content |
| 9 | MultiOccurrenceReplacer | All exact matches | replaceAll mode |

BlockAnchorReplacer Levenshtein thresholds:
- Single candidate in file: threshold `0.0` (always accept if anchors match)
- Multiple candidates: threshold `0.3` (need meaningful middle-line similarity)

The chain ensures models' slightly-off edits still work. Strategies 2-8 progressively relax matching, but each still requires a unique match to avoid applying the wrong edit. Strategy 9 only activates for `replaceAll` mode.
