# CODE ATLAS -- opencode TypeScript Architecture

> Root: `packages/opencode/src/`
> Entry: `index.ts` (yargs CLI), `server/server.ts` (Hono HTTP)
> Runtime: Bun, Effect-TS for DI/services, Drizzle for SQLite

---

## 1. MODULE MAP

```
packages/opencode/src/
|
|-- index.ts                 CLI entry point (yargs). Registers all commands.
|-- node.ts                  Node.js-specific entry (alternate runtime)
|
|-- FOUNDATION LAYER (no domain imports)
|   |-- global/              XDG paths (data, cache, config, state). Side-effectful init.
|   |-- id/                  Prefixed monotonic ID generator (ses_, msg_, prt_, evt_, etc.)
|   |-- flag/                Environment variable flags. Pure reads from process.env.
|   |-- installation/        Version, channel, upgrade detection. HttpClient for update checks.
|   |-- util/                Pure utilities: log, filesystem, glob, git, hash, lock, process,
|   |                        context (ALS), error, color, network, schema helpers, etc.
|   |-- effect/              Effect-TS service infrastructure:
|   |   |-- instance-state.ts    ScopedCache keyed by Instance.directory
|   |   |-- run-service.ts       makeRuntime() -- shared MemoMap for all services
|   |   |-- instance-registry.ts Disposer registry for per-instance cleanup
|   |   |-- cross-spawn-spawner.ts  Effect ChildProcessSpawner via cross-spawn
|
|-- STORAGE LAYER
|   |-- storage/             Dual storage system:
|   |   |-- db.ts            SQLite via Drizzle (Database.Client, .use, .transaction)
|   |   |-- db.bun.ts        Bun SQLite init
|   |   |-- db.node.ts       Node SQLite init
|   |   |-- storage.ts       JSON file storage (read/write/list with file locks)
|   |   |-- schema.sql.ts    Drizzle schema for event_sequence, event tables
|   |   |-- schema.ts        Re-exports
|   |   |-- json-migration.ts  Legacy JSON-to-SQLite data migration
|
|-- EVENT LAYER
|   |-- bus/                 In-process pub/sub:
|   |   |-- bus-event.ts     BusEvent.define() -- schema-typed event definitions
|   |   |-- global.ts        GlobalBus -- Node EventEmitter, cross-instance
|   |   |-- index.ts         Bus -- Effect PubSub, per-instance scoped
|   |-- sync/                Event sourcing on SQLite:
|   |   |-- index.ts         SyncEvent.define/run/replay/project -- persisted events
|   |   |-- event.sql.ts     Drizzle tables: event, event_sequence
|   |   |-- schema.ts        EventID branded type
|
|-- CONFIGURATION LAYER
|   |-- config/              Cascading JSONC config (managed > global > project > env):
|   |   |-- config.ts        Config.Service (Effect), Config.get(), schema, merge logic
|   |   |-- paths.ts         Config file path resolution
|   |   |-- markdown.ts      ConfigMarkdown -- YAML frontmatter parser for AGENTS.md/SKILL.md
|   |   |-- tui.ts           TUI-specific config
|   |   |-- tui-schema.ts    TUI config Zod schema
|   |   |-- migrate-tui-config.ts  Migration from old TUI format
|   |-- env/                 Per-instance env var isolation (via Instance.state)
|   |-- flag/                Static env var flags (compile-time constants)
|
|-- AUTH LAYER
|   |-- auth/                Provider auth storage (OAuth, API key, WellKnown):
|   |   |-- index.ts         Auth.Service (Effect). JSON file at Global.Path.data/auth.json
|   |-- account/             Opencode account management (device code flow, orgs):
|   |   |-- index.ts         Account.Service re-exports
|   |   |-- repo.ts          AccountRepo -- SQLite persistence
|   |   |-- schema.ts        AccountID, AccessToken, RefreshToken, DeviceCode, etc.
|
|-- PROVIDER LAYER
|   |-- provider/            LLM provider abstraction:
|   |   |-- provider.ts      Provider namespace: model registry, SDK instantiation,
|   |   |                    imports all @ai-sdk/* providers directly
|   |   |-- models.ts        ModelsDev -- fetches model metadata from models.dev
|   |   |-- schema.ts        ProviderID, ModelID branded types
|   |   |-- auth.ts          Provider-specific auth resolution
|   |   |-- transform.ts     ProviderTransform -- per-provider option tweaks
|   |   |-- error.ts         Provider error types
|   |   |-- sdk/             Custom SDK adaptors (copilot, etc.)
|
|-- PROJECT LAYER
|   |-- project/             Project identity and lifecycle:
|   |   |-- project.ts       Project.Service -- CRUD, fromDirectory, git root detection
|   |   |-- instance.ts      Instance -- ALS context (directory, worktree, project)
|   |   |-- bootstrap.ts     InstanceBootstrap() -- init sequence for an instance
|   |   |-- state.ts         Instance.state() -- per-instance memoized state
|   |   |-- vcs.ts           Vcs -- git status, diff summary
|   |   |-- project.sql.ts   Drizzle ProjectTable
|   |   |-- schema.ts        ProjectID branded type
|
|-- DOMAIN LAYER
|   |-- session/             Core session management:
|   |   |-- index.ts         Session namespace -- CRUD, messages, fork, share, events
|   |   |-- schema.ts        SessionID, MessageID, PartID branded types
|   |   |-- session.sql.ts   Drizzle tables: session, permission
|   |   |-- message-v2.ts    MessageV2 -- User/Assistant/Info schema, Part types
|   |   |-- prompt.ts        SessionPrompt -- orchestrates message->LLM->tools loop
|   |   |-- llm.ts           LLM.stream() -- Vercel AI SDK streamText wrapper
|   |   |-- processor.ts     SessionProcessor -- handles stream events, tool calls
|   |   |-- system.ts        SystemPrompt -- provider-specific system prompts
|   |   |-- instruction.ts   InstructionPrompt -- AGENTS.md/CLAUDE.md injection
|   |   |-- compaction.ts    SessionCompaction -- context window management
|   |   |-- summary.ts       SessionSummary -- post-session diff summary
|   |   |-- status.ts        SessionStatus -- busy/idle tracking
|   |   |-- retry.ts         SessionRetry -- LLM retry logic
|   |   |-- revert.ts        SessionRevert -- snapshot-based undo
|   |   |-- todo.ts          Todo -- todowrite persistence
|   |   |-- projectors.ts    SyncEvent projectors for session/message/part tables
|   |   |-- prompt/          Text prompt templates (.txt files)
|   |-- agent/               Agent definitions and generation:
|   |   |-- agent.ts         Agent.Service (Effect) -- build/plan/explore/general/title/etc.
|   |   |-- prompt/          Agent-specific prompt templates
|   |-- command/             Slash commands (/init, /review, custom, MCP, skill):
|   |   |-- index.ts         Command.Service (Effect) -- aggregates all command sources
|   |   |-- template/        Built-in command templates (.txt)
|   |-- permission/          Permission evaluation engine:
|   |   |-- index.ts         Permission.Service (Effect) -- ask/reply flow with Deferred
|   |   |-- evaluate.ts      Pure rule evaluation (pattern matching)
|   |   |-- arity.ts         Rule arity/specificity comparison
|   |   |-- schema.ts        PermissionID branded type
|   |-- question/            Interactive question flow (like Permission but for info):
|   |   |-- index.ts         Question.Service (Effect) -- ask/answer with Deferred
|   |   |-- schema.ts        QuestionID branded type
|
|-- TOOL LAYER
|   |-- tool/                Tool system:
|   |   |-- tool.ts          Tool.define() -- tool interface, auto-truncation wrapper
|   |   |-- registry.ts      ToolRegistry.Service (Effect) -- collects built-in + plugin tools
|   |   |-- schema.ts        Tool-related schemas
|   |   |-- truncate.ts      Truncate -- output size management
|   |   |-- bash.ts          BashTool
|   |   |-- read.ts          ReadTool
|   |   |-- edit.ts          EditTool
|   |   |-- write.ts         WriteTool
|   |   |-- glob.ts          GlobTool
|   |   |-- grep.ts          GrepTool
|   |   |-- task.ts          TaskTool (subagent spawner)
|   |   |-- batch.ts         BatchTool (parallel tool calls)
|   |   |-- webfetch.ts      WebFetchTool
|   |   |-- websearch.ts     WebSearchTool
|   |   |-- codesearch.ts    CodeSearchTool
|   |   |-- lsp.ts           LspTool
|   |   |-- question.ts      QuestionTool
|   |   |-- skill.ts         SkillTool
|   |   |-- plan.ts          PlanTool (enter/exit plan mode)
|   |   |-- todo.ts          TodoWriteTool
|   |   |-- apply_patch.ts   ApplyPatchTool (OpenAI-style)
|   |   |-- multiedit.ts     MultiEditTool
|   |   |-- ls.ts            LsTool
|   |   |-- invalid.ts       InvalidTool (catch malformed calls)
|   |   |-- *.txt            Tool description templates
|
|-- INTEGRATION LAYER
|   |-- plugin/              Plugin system:
|   |   |-- index.ts         Plugin.Service (Effect) -- load, trigger hooks
|   |   |-- shared.ts        Plugin resolution, compatibility checks
|   |   |-- codex.ts         Built-in Codex auth plugin
|   |   |-- copilot.ts       Built-in Copilot auth plugin
|   |   |-- install.ts       npm plugin installation
|   |   |-- meta.ts          Plugin metadata
|   |-- mcp/                 MCP (Model Context Protocol) client:
|   |   |-- index.ts         MCP.Service (Effect) -- manages MCP server connections
|   |   |-- auth.ts          MCP auth helpers
|   |   |-- oauth-provider.ts  MCP OAuth provider
|   |   |-- oauth-callback.ts  MCP OAuth callback handler
|   |-- skill/               Skill discovery and loading:
|   |   |-- index.ts         Skill.Service (Effect) -- scan SKILL.md files
|   |   |-- discovery.ts     Discovery.Service -- pull skills from URLs
|   |-- lsp/                 Language Server Protocol:
|   |   |-- index.ts         LSP.Service (Effect) -- manages LSP server lifecycles
|   |   |-- client.ts        LSPClient -- JSON-RPC connection
|   |   |-- server.ts        LSPServer -- built-in server definitions
|   |   |-- language.ts      Language detection
|   |   |-- launch.ts        LSP process spawning
|   |-- snapshot/            Git-based file snapshots:
|   |   |-- index.ts         Snapshot.Service (Effect) -- shadow git repo for undo
|   |-- format/              Code formatter orchestration:
|   |   |-- index.ts         Format.Service (Effect) -- prettier, biome, etc.
|   |   |-- formatter.ts     Built-in formatter definitions
|
|-- INFRASTRUCTURE LAYER
|   |-- file/                File system operations for the project:
|   |   |-- index.ts         File.Service (Effect) -- content, diff, search, ls
|   |   |-- ignore.ts        .gitignore/.opencodeignore handling
|   |   |-- protected.ts     Protected file detection
|   |   |-- ripgrep.ts       Ripgrep integration
|   |   |-- time.ts          FileTime -- mtime tracking for LSP
|   |   |-- watcher.ts       FileWatcher -- filesystem change detection
|   |-- filesystem/          Effect FileSystem wrapper with extras:
|   |   |-- index.ts         AppFileSystem.Service -- isDir, readJson, findUp, glob
|   |-- bun/                 Bun process runner:
|   |   |-- index.ts         BunProc -- run Bun commands, install packages
|   |   |-- registry.ts      PackageRegistry -- npm package resolution
|   |-- shell/               Shell utilities:
|   |   |-- shell.ts         Shell.killTree, Shell.detect, Shell.env
|   |-- patch/               Patch application (OpenAI apply_patch format):
|   |   |-- index.ts         Patch namespace -- parse and apply unified diffs
|   |-- ide/                 IDE integration (VS Code, Cursor, etc.):
|   |   |-- index.ts         Ide namespace -- extension installation
|   |-- pty/                 Pseudo-terminal management:
|   |   |-- index.ts         Pty.Service (Effect) -- spawn, attach, WebSocket relay
|   |   |-- schema.ts        PtyID branded type
|   |-- worktree/            Git worktree management:
|   |   |-- index.ts         Worktree.Service (Effect) -- create/remove/reset worktrees
|
|-- SERVER LAYER
|   |-- server/              HTTP API (Hono):
|   |   |-- server.ts        Server namespace -- ControlPlaneRoutes, listen, openapi
|   |   |-- instance.ts      InstanceRoutes -- per-directory middleware + route mounting
|   |   |-- projectors.ts    initProjectors() -- wires SyncEvent projectors
|   |   |-- event.ts         Event schema
|   |   |-- error.ts         HTTP error helpers
|   |   |-- middleware.ts     Error handler middleware
|   |   |-- mdns.ts          mDNS service publishing
|   |   |-- routes/          Route handlers:
|   |   |   |-- global.ts    /global/* -- cross-instance endpoints
|   |   |   |-- session.ts   /session/* -- CRUD, prompt, messages
|   |   |   |-- config.ts    /config/* -- read/write config
|   |   |   |-- project.ts   /project/* -- project info
|   |   |   |-- provider.ts  /provider/* -- models, auth
|   |   |   |-- permission.ts /permission/* -- ask/reply
|   |   |   |-- question.ts  /question/* -- ask/answer
|   |   |   |-- file.ts      /file/* -- read, diff, ls
|   |   |   |-- mcp.ts       /mcp/* -- server status, tools
|   |   |   |-- pty.ts       /pty/* -- terminal sessions
|   |   |   |-- event.ts     /event -- SSE event stream
|   |   |   |-- tui.ts       /tui/* -- TUI-specific endpoints
|   |   |   |-- experimental.ts  /experimental/* -- feature flags
|   |   |   |-- workspace.ts /workspace/* -- worktree/workspace management
|
|-- CLI LAYER
|   |-- cli/                 CLI commands and TUI:
|   |   |-- bootstrap.ts     CLI bootstrap wrapper (Instance.provide + InstanceBootstrap)
|   |   |-- cmd/             Yargs command modules:
|   |   |   |-- run.ts       Default command (TUI or headless)
|   |   |   |-- serve.ts     `opencode serve` -- headless HTTP server
|   |   |   |-- agent.ts     `opencode agent` -- agent management
|   |   |   |-- models.ts    `opencode models` -- list models
|   |   |   |-- providers.ts `opencode providers` -- list providers
|   |   |   |-- account.ts   `opencode account` -- login/logout
|   |   |   |-- generate.ts  `opencode generate` -- code generation
|   |   |   |-- export.ts    `opencode export` -- session export
|   |   |   |-- import.ts    `opencode import` -- session import
|   |   |   |-- mcp.ts       `opencode mcp` -- MCP server management
|   |   |   |-- plug.ts      `opencode plugin` -- plugin management
|   |   |   |-- github.ts    `opencode github` -- GitHub integration
|   |   |   |-- pr.ts        `opencode pr` -- PR workflow
|   |   |   |-- session.ts   `opencode session` -- session management
|   |   |   |-- tui/         TUI (terminal UI) commands
|   |   |-- effect/          CLI-specific Effect helpers
|   |   |-- error.ts         CLI error formatting
|   |   |-- logo.ts          ASCII logo
|   |   |-- ui.ts            Terminal output helpers
|   |   |-- network.ts       Network option resolution
|   |   |-- upgrade.ts       Auto-upgrade logic
|
|-- CONTROL PLANE
|   |-- control-plane/       Multi-workspace orchestration:
|   |   |-- workspace.ts     Workspace CRUD (worktree + cloud adapters)
|   |   |-- workspace.sql.ts Drizzle WorkspaceTable
|   |   |-- workspace-router-middleware.ts  Routes requests to correct instance
|   |   |-- schema.ts        WorkspaceID branded type
|   |   |-- types.ts         WorkspaceInfo schema
|   |   |-- sse.ts           SSE parsing utilities
|   |   |-- adaptors/        Workspace type adaptors (local worktree, cloud, etc.)
|
|-- SHARING
|   |-- share/               Session sharing:
|   |   |-- share-next.ts    ShareNext -- upload sessions to opencode.ai
|   |   |-- share.sql.ts     Drizzle SessionShareTable
|
|-- ACP (Agent Communication Protocol)
|   |-- acp/                 Agent-to-agent communication:
|   |   |-- agent.ts         ACP agent implementation
|   |   |-- session.ts       ACP session management
|   |   |-- types.ts         ACP type definitions
```

---

## 2. DEPENDENCY GRAPH

### Layer Diagram (arrows = "imports from")

```
 FOUNDATION (no domain deps)
 +-----------+  +------+  +------+  +--------------+  +--------+
 | global/   |  | id/  |  | flag/|  | installation/|  | util/* |
 +-----------+  +------+  +------+  +--------------+  +--------+
       |             |         |           |               |
       +------+------+---------+-----------+-------+-------+
              |                                    |
              v                                    v
 STORAGE                                    EFFECT INFRA
 +------------------+                       +------------------+
 | storage/db.ts    |<---+                  | effect/          |
 | storage/storage  |    |                  |   instance-state |
 +------------------+    |                  |   run-service    |
              |          |                  +------------------+
              v          |                         |
 EVENT LAYER             |                         |
 +----------+ +--------+ |                         |
 | bus/     | | sync/  |-+                         |
 +----------+ +--------+                           |
     |  ^         |                                |
     |  |         v                                |
     |  +--- (all domain modules publish/subscribe)|
     |                                             |
     v                                             v
 CONFIG + AUTH                              All Service layers use
 +----------+ +--------+                   InstanceState + makeRuntime
 | config/  | | auth/  |
 +----------+ +--------+
     |   |        |
     v   v        v
 PROVIDER
 +------------------+
 | provider/        |
 +------------------+
     |
     v
 PROJECT
 +------------------+
 | project/         |
 |   instance.ts    |  <-- ALS context, everything reads from here
 |   project.ts     |
 |   bootstrap.ts   |
 +------------------+
     |
     +-----+-----+-----+-----+-----+-----+
     |     |     |     |     |     |     |
     v     v     v     v     v     v     v
 DOMAIN MODULES (all depend on project/instance)
 +-------+ +-----+ +-------+ +----------+ +--------+
 |session | |agent| |command| |permission| |question|
 +-------+ +-----+ +-------+ +----------+ +--------+
     |         |        |
     v         v        v
 TOOL LAYER
 +------------------+
 | tool/registry.ts | --> all tool/*.ts
 +------------------+
     |
     v
 INTEGRATION LAYER
 +------+ +-----+ +-------+ +--------+ +------+ +--------+
 |plugin| | mcp | | skill | |snapshot| | lsp  | | format |
 +------+ +-----+ +-------+ +--------+ +------+ +--------+
     |
     v
 INFRASTRUCTURE
 +------+ +----+ +------+ +-----+ +---+ +--------+ +-----+
 | file | |bun | | shell| |patch| |ide| |worktree| | pty |
 +------+ +----+ +------+ +-----+ +---+ +--------+ +-----+
     |
     v
 SERVER LAYER
 +------------------+
 | server/server.ts | --> server/instance.ts --> server/routes/*
 +------------------+
     |
     v
 CLI LAYER
 +------------------+
 | cli/cmd/*        | --> cli/bootstrap.ts
 +------------------+
```

### Key Import Relationships

```
session/index.ts imports:
  <- storage/db (Database, SessionTable)
  <- bus (Bus.publish)
  <- sync (SyncEvent.run)
  <- config (Config.get)
  <- provider/schema (ModelID, ProviderID)
  <- project/instance (Instance.project, Instance.directory)
  <- permission (Permission.Ruleset)
  <- snapshot (Snapshot.FileDiff)
  <- session/message-v2, session/prompt, session/schema

session/prompt.ts imports:
  <- session/index (Session)
  <- agent/agent (Agent)
  <- provider/provider (Provider)
  <- tool/registry (ToolRegistry)
  <- mcp (MCP)
  <- lsp (LSP)
  <- plugin (Plugin)
  <- permission (Permission)
  <- command (Command)
  <- session/llm (LLM)
  <- session/processor (SessionProcessor)

agent/agent.ts imports:
  <- config (Config.Service)
  <- provider (Provider)
  <- auth (Auth.Service)
  <- skill (Skill.Service)
  <- plugin (Plugin)
  <- permission (Permission)

tool/registry.ts imports:
  <- config (Config.Service)
  <- plugin (Plugin.Service)
  <- all tool/*.ts files

server/instance.ts imports:
  <- project/bootstrap (InstanceBootstrap)
  <- project/instance (Instance.provide)
  <- all server/routes/* files
```

---

## 3. DATA FLOW

### A. HTTP Request -> Response

```
HTTP Request
  |
  v
server/server.ts  ControlPlaneRoutes()
  |-- middleware: auth, cors, compress, logging
  |-- route: /global/*  --> server/routes/global.ts
  |-- route: /auth/*    --> inline handlers
  |-- middleware: WorkspaceRouterMiddleware
  |       |
  |       v
  |   server/instance.ts  InstanceRoutes
  |       |-- middleware: Instance.provide(directory, InstanceBootstrap)
  |       |       |
  |       |       +-- project/instance.ts: creates ALS context
  |       |       +-- project/bootstrap.ts: Plugin.init, Format.init,
  |       |       |   LSP.init, File.init, FileWatcher.init, Vcs.init,
  |       |       |   Snapshot.init
  |       |       |
  |       |-- route: /session/*  --> session route handler
  |       |       |
  |       |       v
  |       |   Session.list() / Session.get() / SessionPrompt.chat()
  |       |       |
  |       |       v
  |       |   Database.use(db => db.select().from(SessionTable)...)
  |       |       |
  |       |       v
  |       |   c.json(result)  --> HTTP Response
  |       |
  |       |-- route: /config/*   --> Config.get/set
  |       |-- route: /provider/* --> Provider.list/models
  |       |-- route: /permission/* --> Permission.ask/reply
  |       |-- route: /file/*     --> File.read/diff/ls
  |       |-- route: /mcp/*      --> MCP.status/tools
  |       |-- route: /pty/*      --> Pty.create/attach
  |       |-- route: /event      --> SSE stream (Bus.subscribeAll)
```

### B. CLI Command -> Output

```
CLI invocation: `opencode [command] [args]`
  |
  v
index.ts  yargs.parse()
  |-- middleware: Log.init, Database migration check
  |
  v
cli/cmd/run.ts (default) or specific command
  |
  v
cli/bootstrap.ts
  |-- Instance.provide({ directory, init: InstanceBootstrap, fn })
  |       |
  |       v
  |   project/instance.ts  (ALS context created)
  |   project/bootstrap.ts (services initialized)
  |       |
  |       v
  |   command handler executes:
  |       |
  |       v
  |   (for `serve`): Server.listen(opts)
  |   (for `run`):   TUI starts, SessionPrompt.chat()
  |   (for others):  Direct domain calls
  |       |
  |       v
  |   Instance.dispose()  (cleanup)
```

### C. Session Prompt -> Tool Execution -> Result

```
SessionPrompt.chat(sessionID, userMessage)
  |
  v
1. Resolve model: Provider.defaultModel() / Agent config
  |
  v
2. Build system prompt:
   SystemPrompt.provider(model) + InstructionPrompt (AGENTS.md)
   + Plugin.trigger("experimental.chat.system.transform")
  |
  v
3. Resolve tools:
   ToolRegistry.tools(model, agent)
     |-- Built-in tools (BashTool, ReadTool, EditTool, etc.)
     |-- Plugin tools (plugin.trigger "tool.definition")
     |-- MCP tools (MCP.tools())
     |-- Custom tools from config dirs (tools/*.ts)
  |
  v
4. Apply permission filter:
   Permission.disabled(toolIDs, agent.permission)
  |
  v
5. Create SessionProcessor:
   processor = SessionProcessor.create(assistantMessage)
  |
  v
6. LLM.stream(input)  -- Vercel AI SDK streamText()
   |
   +--[stream loop]-------------------------------------+
   |                                                     |
   |  event: "text-delta"                                |
   |    -> Session.updatePart(TextPart)                  |
   |    -> Session.updatePartDelta()                     |
   |                                                     |
   |  event: "tool-call"                                 |
   |    -> Permission.ask(ruleset, patterns)             |
   |       |-- action=allow: proceed                     |
   |       |-- action=ask:   Bus.publish(Permission.Asked)|
   |       |     wait for Deferred<void, RejectedError>  |
   |       |-- action=deny:  throw DeniedError           |
   |    -> tool.execute(args, ctx)                       |
   |       |-- ctx.ask() for nested permissions          |
   |       |-- Format.file() after edits                 |
   |       |-- LSP.touchFile() for diagnostics           |
   |    -> Session.updatePart(ToolPart)                  |
   |                                                     |
   |  event: "finish"                                    |
   |    -> check shouldContinue (has tool results?)      |
   |    -> if yes: loop with updated messages            |
   |    -> if no:  break                                 |
   +-----------------------------------------------------+
  |
  v
7. Post-processing:
   SessionCompaction.maybe(sessionID)  -- auto-compact if needed
   SessionSummary.generate(sessionID)  -- git diff summary
   Snapshot.commit()                   -- save snapshot
  |
  v
8. Return MessageV2.WithParts to caller
```

### D. Event Sourcing Flow (SyncEvent)

```
Domain action (e.g. Session.create):
  |
  v
SyncEvent.run(Session.Event.Created, { sessionID, info })
  |
  v
Database.transaction("immediate"):
  |-- EventSequenceTable: read seq, increment
  |-- Projector function: insert into SessionTable
  |-- EventTable: insert event record
  |-- Database.effect(() => {
  |       Bus.publish(event)        -- in-process notification
  |       GlobalBus.emit("event")   -- cross-instance notification
  |   })
```

---

## 4. BOOTSTRAP SEQUENCE

```
=== Process Start (index.ts) ===

1. Global.Path init (global/index.ts)
   - Create XDG directories (data, cache, config, state, log, bin)
   - Check/reset cache version

2. Yargs middleware (index.ts)
   - Log.init()
   - Set process.env flags (AGENT, OPENCODE, OPENCODE_PID)
   - Check for first-run database migration (JsonMigration)
   - Database.Client() -- opens SQLite, applies Drizzle migrations

3. Command dispatch (e.g. `serve`)
   - Server.listen() or cli/bootstrap.ts

=== Per-Instance Bootstrap (project/bootstrap.ts) ===

Called via Instance.provide({ directory, init: InstanceBootstrap })

1. Instance context creation (project/instance.ts)
   - Project.fromDirectory(directory)
     - Detect git root, compute projectID
     - Database.use: upsert ProjectTable
   - Set ALS context: { directory, worktree, project }

2. InstanceBootstrap() sequence:
   a. Plugin.init()        -- load internal + npm plugins, trigger hooks
   b. ShareNext.init()     -- initialize share URL resolution
   c. Format.init()        -- detect available formatters (prettier, biome)
   d. LSP.init()           -- configure LSP server definitions
   e. File.init()          -- setup file service state
   f. FileWatcher.init()   -- start filesystem watcher
   g. Vcs.init()           -- track git status
   h. Snapshot.init()      -- initialize shadow git repo

3. Bus.subscribe(Command.Event.Executed)
   - On /init command: mark project as initialized

=== Server Startup (server/server.ts, server/projectors.ts) ===

1. initProjectors()       -- wire SyncEvent projectors (session/message/part)
   - SyncEvent.init({ projectors: sessionProjectors })
   - This freezes event definitions (no new SyncEvent.define after this)

2. Server.listen()        -- Bun.serve with Hono app
   - ControlPlaneRoutes: auth, cors, compress, /global/*, /auth/*
   - WorkspaceRouterMiddleware: routes to correct instance
   - InstanceRoutes: per-request Instance.provide + all domain routes
```

---

## 5. MODULE BOUNDARIES

### Allowed Dependencies (by convention)

```
RULE 1: Layers import downward only
  CLI -> Server -> Domain -> Storage -> Foundation
  (never upward)

RULE 2: Foundation modules have ZERO domain imports
  global/, id/, flag/, util/, effect/
  These can be imported by anything.

RULE 3: Storage layer imports only Foundation
  storage/db.ts imports: util/context, util/lazy, global, flag, id, installation

RULE 4: Bus layer imports only Storage + Foundation
  bus/ imports: util/log, project/instance (for directory key)
  sync/ imports: storage/db, bus/bus-event, flag

RULE 5: Config imports Storage + Foundation + Auth
  config/ imports: storage, global, flag, auth, env, bus, installation, bun

RULE 6: Domain modules import Config + Auth + Storage + Bus
  session/, agent/, command/, permission/, question/
  These are the "business logic" layer.

RULE 7: Tools import Domain (session, agent, permission)
  tool/ imports session (for context), permission (for ask),
  but NOT server/ or cli/

RULE 8: Server imports everything except CLI
  server/ can import any domain/tool/integration module

RULE 9: CLI imports everything
  cli/ is the outermost layer, can import server + domain
```

### Known Acceptable Cross-Cuts

```
project/instance.ts
  - Imported by NEARLY EVERY module (provides ALS context)
  - This is by design: Instance.directory, Instance.worktree, Instance.project

bus/global.ts
  - Simple EventEmitter, imported by bus/, project/, control-plane/
  - Cross-instance communication channel

effect/instance-state.ts + effect/run-service.ts
  - Imported by every Service module (Config, Agent, Tool, etc.)
  - The DI backbone of the codebase
```

### Dependency Direction Violations to Watch

```
CAUTION: session/prompt.ts is a "god file"
  - Imports from 20+ modules: agent, provider, tool/registry, mcp, lsp,
    plugin, permission, command, config, bus, session/*, tool/*
  - This is the orchestration nexus; changes here affect everything

CAUTION: config/config.ts imports heavily
  - Imports: auth, env, bus, global-bus, installation, bun, filesystem,
    plugin/shared, config/markdown, config/paths, account
  - Config needs to know about plugins for dependency resolution

AVOID: Domain modules should not import server/
  - session/ should never import from server/routes/
  - If a domain module needs server URL, use Flag or inject it

AVOID: tool/*.ts should not import session/index.ts directly
  - Tools receive context via Tool.Context, not by importing Session
  - Exception: tool/task.ts (subagent) needs SessionPrompt
```

### Clean Seams

```
1. Tool.Info interface (tool/tool.ts)
   - Clean boundary between tool implementation and orchestration
   - Tools know nothing about HTTP, CLI, or streaming
   - Input: args + Context. Output: { title, metadata, output }

2. Effect Service boundary
   - Every Service exposes an Interface + layer + defaultLayer
   - Consumers use Service.of() or the async wrapper functions
   - Layers compose via Layer.provide() -- explicit dependency declaration

3. SyncEvent projectors (sync/index.ts)
   - Clean separation: event definition (domain) vs projection (storage)
   - Projectors registered once at server startup

4. Bus events (bus/bus-event.ts)
   - Typed event definitions, decoupled pub/sub
   - Modules define events, other modules subscribe

5. Provider abstraction (provider/provider.ts)
   - All LLM SDKs hidden behind Provider.getLanguage()
   - Session/LLM layer only sees the Vercel AI SDK interface
```

---

## 6. FILE NAMING CONVENTIONS

### When a module gets `index.ts`

```
Directory modules use index.ts when:
  - The module IS the namespace (bus/, session/, file/, permission/, etc.)
  - index.ts re-exports or IS the main namespace definition
  - Other files in the dir are internal implementation details

Examples:
  bus/index.ts         -- Bus namespace (the public API)
  session/index.ts     -- Session namespace (CRUD, events, types)
  permission/index.ts  -- Permission namespace
  auth/index.ts        -- Auth namespace
```

### When a module gets a named file instead

```
Named files when:
  - The module has a clear single-word identity
  - Used inside a directory with multiple peer concepts

Examples:
  config/config.ts     -- not index.ts, because config/ has peers (paths, markdown, tui)
  provider/provider.ts -- not index.ts, because provider/ has peers (models, auth, schema)
  agent/agent.ts       -- not index.ts, because agent/ has prompt/ subdir
  flag/flag.ts         -- single file module, named for clarity
  shell/shell.ts       -- single file module
  id/id.ts             -- single file module
```

### When a module gets `schema.ts`

```
schema.ts appears when:
  - A module defines branded ID types (SessionID, MessageID, etc.)
  - The schema is shared across multiple files in the module

Pattern: schema.ts exports branded Identifier types
  session/schema.ts    -- SessionID, MessageID, PartID
  permission/schema.ts -- PermissionID
  question/schema.ts   -- QuestionID
  provider/schema.ts   -- ProviderID, ModelID
  project/schema.ts    -- ProjectID
  control-plane/schema.ts -- WorkspaceID
  pty/schema.ts        -- PtyID
  sync/schema.ts       -- EventID
  storage/schema.ts    -- re-exports
  tool/schema.ts       -- tool-related schemas
```

### When a module gets `.sql.ts`

```
*.sql.ts files define Drizzle ORM table schemas:
  session/session.sql.ts     -- SessionTable, PermissionTable
  project/project.sql.ts     -- ProjectTable
  account/account.sql.ts     -- AccountTable
  sync/event.sql.ts          -- EventTable, EventSequenceTable
  storage/schema.sql.ts      -- core storage tables
  share/share.sql.ts         -- SessionShareTable
  control-plane/workspace.sql.ts -- WorkspaceTable

Convention: {entity}.sql.ts sits alongside {entity}.ts
```

### When a module gets a separate types file

```
Rare. Types are usually co-located in the main namespace file.

Exception:
  control-plane/types.ts     -- WorkspaceInfo shared across adaptors
  acp/types.ts               -- ACP protocol types
```

### Directory vs single file

```
DIRECTORY when:
  - Module has 3+ files (implementation, schema, sql, sub-modules)
  - Module has sub-directories (agent/prompt/, session/prompt/)
  - Module is a "service" with Effect Service + layer + state

SINGLE FILE when:
  - Module is a pure utility or simple namespace
  - No sub-components needed

Single-file modules that COULD be directories but aren't:
  flag/flag.ts       -- just env var reads
  id/id.ts           -- just ID generation
  shell/shell.ts     -- just shell utilities

These stay as single files because they have no sub-components.
```

---

## 7. EFFECT-TS SERVICE PATTERN

Every major module follows this pattern:

```typescript
export namespace Module {
  // 1. Zod schemas
  export const Info = z.object({ ... })

  // 2. Effect Service class
  export interface Interface {
    readonly method: (input: X) => Effect.Effect<Y>
  }
  export class Service extends ServiceMap.Service<Service, Interface>()("@opencode/Module") {}

  // 3. Layer (DI wiring)
  export const layer = Layer.effect(Service, Effect.gen(function* () {
    const dep = yield* DependencyService  // pull deps from context
    const state = yield* InstanceState.make(...)  // per-instance state
    return Service.of({ method: ... })
  }))

  // 4. Default layer (self-contained, provides all deps)
  export const defaultLayer = layer.pipe(
    Layer.provide(Dep1.defaultLayer),
    Layer.provide(Dep2.defaultLayer),
  )

  // 5. Runtime bridge (async wrappers for non-Effect code)
  const { runPromise } = makeRuntime(Service, defaultLayer)

  export async function method(input: X): Promise<Y> {
    return runPromise((svc) => svc.method(input))
  }
}
```

Modules using this pattern:
`Agent`, `Auth`, `Bus`, `Command`, `Config`, `File`, `Format`, `LSP`,
`MCP`, `Permission`, `Plugin`, `Pty`, `Question`, `Skill`, `Snapshot`,
`ToolRegistry`, `Worktree`, `Account`, `Project`, `Installation`

---

## 8. QUICK REFERENCE -- WHERE TO PUT NEW CODE

```
New tool?           -> tool/{name}.ts  (Tool.define, add to registry.ts)
New CLI command?    -> cli/cmd/{name}.ts  (yargs command, add to index.ts)
New API route?      -> server/routes/{name}.ts  (Hono, mount in instance.ts)
New domain entity?  -> {name}/index.ts + {name}/schema.ts + {name}/{name}.sql.ts
New provider?       -> provider/provider.ts  (add to SDK init map)
New Effect service? -> {name}/index.ts  (Service, Interface, layer, defaultLayer)
New bus event?      -> In the module that owns it: BusEvent.define()
New sync event?     -> In the module that owns it: SyncEvent.define() + projector
New util function?  -> util/{category}.ts
New config option?  -> config/config.ts  (add to Info schema)
New flag?           -> flag/flag.ts
New formatter?      -> format/formatter.ts
New LSP server?     -> lsp/server.ts
New plugin hook?    -> @opencode-ai/plugin types + plugin/index.ts
New branded ID?     -> {module}/schema.ts using id/id.ts Identifier
```
