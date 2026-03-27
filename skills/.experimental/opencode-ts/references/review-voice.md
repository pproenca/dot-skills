# PR Review Voice -- What Gets Pushed Back On and Why

Source: actual PR review comments from `sst/opencode` core maintainers.

Reviewers studied:
- **thdxr** (Dax Raad) -- top contributor, 1949 commits. Repo owner. Reviews naming, consistency, architecture.
- **adamdotdevin** (Adam) -- second contributor, 1848 commits. Reviews UI/app code, package scope, existing library reuse.
- **kitlangton** -- core contributor. Reviews Effect-TS patterns, type safety, code correctness, naming in services.
- **rekram1-node** -- core contributor. Reviews provider code, API correctness, docs, scope creep from external PRs.

---

## 1. Naming Consistency

The codebase enforces a strict naming convention. If you use `projectId` instead of `projectID`, it gets called out.

### thdxr on PR #15120 -- camelCase convention for IDs

> "stupid nit but we use `projectID` everywhere"

```diff
+export type Workspace = {
+  id: string
+  branch: string | null
+  projectId: string        // <-- WRONG: should be projectID
```

**Rule**: ID suffixes are always uppercase: `projectID`, `sessionID`, `messageID`. Never `projectId`, `sessionId`.

### kitlangton on PR #19150 -- naming local state

> "We usually call this `state` (not `cache`)"

**Rule**: Follow the codebase's existing vocabulary. If every service calls its internal store `state`, do not invent `cache`.

### AGENTS.md style guide -- single-word names

The style guide is explicit:

> "Use single word names by default for new locals, params, and helper functions."
> "Good short names to prefer: `pid`, `cfg`, `err`, `opts`, `dir`, `root`, `child`, `state`, `timeout`."
> "Examples to avoid unless truly required: `inputPID`, `existingClient`, `connectTimeout`, `workerPath`."

---

## 2. Do Not Touch Unrelated Code

External PRs that change files beyond their stated scope get pushed back immediately.

### adamdotdevin on PR #15863 -- unrelated package modifications

> "pedantic, but let's leave this untouched"

(on changes to `packages/opencode/src/session/processor.ts`)

> "again, pedantic, but would prefer this package not touched at all"

(on changes to `packages/opencode/src/session/prompt.ts`)

**Rule**: If your PR is about the UI, do not touch session processing code. If your PR fixes a bug, do not refactor adjacent code. Stay in scope.

### rekram1-node on PR #14586 -- unrelated reformatting

> "why change this unrelated stuff?"

```diff
-    if (model.api.npm === "@ai-sdk/anthropic") {
+    if (model.api.npm === "@ai-sdk/anthropic" || model.api.npm === "@ai-sdk/amazon-bedrock") {
```

The contributor also refactored surrounding code (restructuring an `if` chain, changing variable names). The reviewer wanted only the one-line fix plus its test:

> "why can't we just have this change +1 test for it, ill cleanup later cause we should be a bit better at doing this across the board but there was a special case that caused errors in the past"

**Rule**: Minimal diffs. One change per PR. Do not refactor while fixing.

---

## 3. No Type Casts (`as any`)

Type casts are rejected immediately with no discussion.

### kitlangton on PR #16956 -- `as any` in import command

> "no! bad robot."

```diff
-              data: msg.info,
+              data: msg.info as any,
```

And again on the same PR:

> "no casts"

```diff
-              data: part,
+              data: part as any,
```

**Rule**: If the types do not align, fix the types. Never cast to `any`. The AGENTS.md is explicit: "Avoid using the `any` type."

---

## 4. Use Existing Libraries, Do Not Reinvent

### adamdotdevin on PR #15863 -- custom hooks vs community primitives

> "let's swap this out with https://primitives.solidjs.community/package/resize-observer/#createelementsize (i think we already have this package installed and some usage of it)"

(on a custom `use-element-height.ts` hook)

> "let's swap this out with https://primitives.solidjs.community/package/page-visibility/#usepagevisibility"

(on a custom `use-page-visible.ts` hook)

> "could replace this with https://primitives.solidjs.community/package/media/#createmediaquery"

(on a custom `use-reduced-motion.ts` hook)

**Rule**: Before writing a custom utility, check if a community primitive already exists. The project uses `@solid-primitives/*` heavily. Do not add custom hooks that duplicate them.

---

## 5. Do Not Add Custom Provider Logic -- Use models.dev

External contributors frequently try to add provider-specific code directly into the codebase. This is always rejected.

### rekram1-node on PR #14104 -- hardcoding provider in source

> "If you want to add a new provider, please make a PR to models.dev (see how all other providers work)"

```diff
+    // Add IONOS AI Model Hub provider if not already in models.dev
+    if (!database["ionos"]) {
+      const ionosAPI = {
+        npm: "@ai-sdk/openai-compatible",
+        url: "https://openai.inference.de-txl.ionos.com/v1",
+      }
```

### rekram1-node on PR #13991 -- provider not in models.dev

> "hm I dont see this provider in models.dev?"

### rekram1-node on PR #14052 -- redundant config

> "this already comes from models.dev"

### rekram1-node on PR #13765 -- dynamic model fetching not needed

> "do we need this? If the models are in models.dev ... Note that Im adding the dynamic model fetching this week for all the primary providers, I dont think we need this one..."

> "Believe this is in models.dev"

> "I think models.dev handles this now"

**Rule**: Provider definitions, model lists, API URLs, and env var names all live in `models.dev`. Do not duplicate them in the opencode source. Make a PR to models.dev instead.

---

## 6. Do Not Promote Third-Party Services as "Recommended"

### rekram1-node on PR #13765 -- provider promotion rejected (5 separate comments)

> "don't want to add as recommended provider"

(on adding Kilo to the recommended provider list in the auth command)

> "don't want to add as recommended provider"

(on adding Kilo to the CLI auth flow sort order)

> "We don't want to add this as a recommended provider."

(on adding Kilo to the TUI provider dialog)

**Rule**: The recommended provider list is curated. External providers should work through `models.dev` and the generic auth flow. Do not add promotional copy, special sort order, or recommendation badges for third-party services.

---

## 7. Question Why Code Was Removed

### adamdotdevin on PR #7130 -- safety guard removed

> "why remove this? this was added because of conflicts between the terminal component and the prompt input, does removing it not cause any issues there?"

```diff
   const handlePaste = async (event: ClipboardEvent) => {
-    if (!isFocused()) return
```

### kitlangton on PR #18433 -- accidental deletion of `result.push`

> "Looks like this may have been accidentally deleted? Unless I'm missing something :)"

```diff
-        result.push(msg)
```

> "Do you need to push the message still?"

**Rule**: When you remove code, the reviewer will ask why. Have a reason. If you are refactoring, make sure you are not silently dropping logic.

---

## 8. Question Unexplained Changes

### kitlangton on PR #16948 -- unexplained variable rename

> "??? why the change from input -> config?"

```diff
-      projectID: input.projectID,
+      projectID: config.projectID,
```

### kitlangton on PR #16948 -- unnecessary type alias

> "why the alias????"

```diff
+import type { WorkspaceInfo as WorkspaceInfoType } from "./types"
```

### kitlangton on PR #16948 -- unexplained structural change

> "???? why this?"

```diff
-      const row = { ...Session.toRow(exportData.info), project_id: Instance.project.id }
+      const row = {
+        ...Session.toRow({ ...exportData.info, projectID: Instance.project.id }),
+        project_id: Instance.project.id,
+      }
```

### kitlangton on PR #16948 -- type change without explanation

> "Wat?"

```diff
-            info: Session.Info
+            info: SDKSession
```

**Rule**: Every change in a PR must have a clear reason. If the reviewer cannot understand why a line changed from reading the diff, the PR will be blocked with "???" until explained.

---

## 9. Correctness Over Cleverness

### rekram1-node on PR #14283 -- logic that cannot work

> "U removed the 4.6 cases like opus-4.6 and sonnet-4.6, so isAnthropicAdaptive will never be true for the vercel ai gateway provider"

> "This will not work"

### rekram1-node on PR #17053 -- wrong system prompt logic

> "WRONG"

(single word, on incorrect agent permission wiring in the system prompt)

### kitlangton on PR #16948 -- wrong assertion

> "Shouldn't this compare against Project.global?"

```diff
-        expect(Instance.project.id).not.toBe("global")
+        expect(String(Instance.project.id)).not.toBe("global")
```

**Rule**: Reviewers will test your logic mentally. If a condition can never be true, or a comparison does not test what it claims to test, it will be caught.

---

## 10. Effect-TS Patterns

### kitlangton on PR #17961 -- follow existing patterns for global services

> "Look at `opencode/packages/opencode/src/account/effect.ts` and `account/index.ts`. I forgot this was a requirement for these global services."

### kitlangton on PR #18971 -- use the Effect service, not raw calls

> "I think Auth has been Effectified so we can depend on and use that service."

> "Should use the `config` helper above?"

### kitlangton on PR #15487 -- extract magic numbers

> "extract the magic number 1 here. it's used a few places."

```ts
const current = (db: DbClient) => {
  const state = db.select().from(AccountStateTable).where(eq(AccountStateTable.id, 1)).get()
```

### kitlangton on PR #15487 -- question data model design

> "the active_account_id + selected_org_id thing is a bit weird. why not just put the selected org id on the account state too? so that's the selector. I know we forget the last selected org per account... but does that matter? maybe?"

### kitlangton on PR #15487 -- no hardcoded defaults for services in development

> "I don't think we want a default at this time."

```ts
const serverDefault = "https://web-14275-d60e67f5-pyqs0590.onporter.run"
```

**Rule**: Effect services follow a specific pattern in this codebase. Look at existing services (`account/effect.ts`, `account/index.ts`) before writing new ones. Use `Effect.cached` for deduplication. Use existing Effect services rather than raw calls.

---

## 11. Testing Patterns

### kitlangton on PR #18433 -- unnecessary Promise.all

> "I don't think these need to be wrapped in Promise.all :)"

```diff
-    expect(MessageV2.toModelMessages(input, model)).toStrictEqual([
+    expect(await Promise.all([MessageV2.toModelMessages(input, model)])).toStrictEqual([
```

Preferred:

> "`expect(await MessageV2.toModelMessages(input, model)).toStrictEqual([` should be fine"

### rekram1-node on PR #14586 -- suspicious test changes

> "hm im not sure if this one is correct"

(on a test that was restructured but the reviewer suspected the new assertions did not match the original intent)

### rekram1-node on PR #16069 -- flaky test workaround

> "flaky!"

```diff
+  // powershell + windows just isnt that fast... we need to wait
+  await page.waitForTimeout(3_000)
```

**Rule from AGENTS.md**: "Avoid mocks as much as possible. Test actual implementation, do not duplicate logic into tests."

---

## 12. UI Code -- Use Correct Variants and Patterns

### adamdotdevin on PR #8513 -- wrong button variant

> "Should be `ghost` I think"

(on a Button component using `variant: "secondary"` instead of `variant: "ghost"`)

### adamdotdevin on PR #10651 -- use focus-visible, not focus

> "Why not just change this to focus-visible?"

```diff
       &:hover:not(:disabled),
-      &:focus:not(:disabled),
```

### adamdotdevin on PR #8513 -- duplicate CORS middleware

> "Why add this and not remove the one below? Only need it once, just moved up here right?"

### adamdotdevin on PR #8513 -- batch state updates

> "Minor, but could do a single setStore for each of these here"

(on multiple individual `setStore()` calls that could be batched)

**Rule**: Know the UI component library. Use the right variant (`ghost` vs `secondary`). Use `focus-visible` not `focus` for keyboard-only focus styles. Batch SolidJS store updates.

---

## 13. Platform and Cross-Platform Concerns

### rekram1-node on PR #13992 -- use EOL for cross-platform newlines

> "u should use EOL instead"

```diff
-      process.stderr.write(`Exporting session: ${sessionID ?? "latest"}`)
+      process.stderr.write(`Exporting session: ${sessionID ?? "latest"}\n`)
```

### rekram1-node on PR #18900 -- null byte splitting for file paths

> "Should we do what zed does and split on null bytes instead? Can't this break if file names have tabs in them?"

### rekram1-node on PR #14166 -- base64 content size calculation

> "I think they will always be base64 right"

> "If files content is base64, does this actually calculate the size correctly?"

**Rule**: Think about Windows. Think about encoding. Think about file paths with special characters.

---

## 14. Scope Discipline for CLI and Console Output

### rekram1-node on PR #13571 -- use the project's UI, not console

> "prolly shouldnt use console here, should use UI consistent w/ other commands."

```diff
+      } catch {
+        console.error(`Session not found: ${args.sessionID}`)
```

**Rule**: CLI output should go through the project's output utilities (prompts, formatters), not raw `console.error`. Stay consistent with how other commands display errors.

---

## 15. Documentation Precision

### rekram1-node on PR #14313 -- vague claims in docs

> "what is this common pattern u are referring to?"

```markdown
+Prefer unique names unless you intentionally want to replace a built-in tool. A common pattern is to create `safe_bash` and disable `bash` using [permissions](/docs/permissions).
```

### rekram1-node on PR #14313 -- scope creep in descriptions

> Prolly change:
> "the custom tool takes precedence for that session."
> TO
> "the custom tool takes precedence."

**Rule**: Docs must be precise. Do not claim something is a "common pattern" without evidence. Do not add unnecessary qualifiers that imply temporary behavior when it is permanent.

---

## Summary of Rejection Patterns

| Pattern | Frequency | Who catches it |
|---------|-----------|----------------|
| Wrong naming convention (`projectId` vs `projectID`) | High | thdxr, kitlangton |
| Touching unrelated files | High | adamdotdevin, rekram1-node |
| `as any` casts | Immediate reject | kitlangton |
| Custom hooks that duplicate community primitives | High | adamdotdevin |
| Hardcoding provider info instead of using models.dev | Very high | rekram1-node |
| Promoting third-party services | High | rekram1-node |
| Removing code without explaining why | Medium | adamdotdevin, kitlangton |
| Unexplained changes (the "???" pattern) | High | kitlangton |
| Logic that cannot work as written | Medium | rekram1-node |
| Not following Effect-TS service patterns | Medium | kitlangton |
| Unnecessary test complexity | Medium | kitlangton |
| Wrong UI component variants | Medium | adamdotdevin |
| Platform-specific assumptions | Medium | rekram1-node |
| Raw console output in CLI commands | Low | rekram1-node |
| Vague or imprecise documentation | Low | rekram1-node |

---

## The Unwritten Rules (Inferred from Review Patterns)

1. **Minimal diffs win.** The smaller the PR, the faster it merges. Multi-concern PRs get each concern questioned separately.

2. **The codebase has a vocabulary.** Learn it. `state` not `cache`. `projectID` not `projectId`. `dir` not `directory`. `cfg` not `config` for locals.

3. **External contributors get the most scrutiny on scope.** If you are not a core maintainer, keep your PR to exactly one thing.

4. **"WRONG" is a valid review comment.** Core maintainers are blunt. Do not take it personally. Fix it and move on.

5. **Questions are blockers.** When a reviewer writes "???" or "why this?", the PR will not merge until answered. These are not rhetorical.

6. **Existing patterns are law.** Before writing new code, find an existing example in the codebase and follow its structure exactly.

7. **models.dev is the source of truth for providers.** This is the single most common rejection reason for external PRs.

8. **Effect-TS services have a specific wiring pattern.** Look at `account/effect.ts` and `account/index.ts` before creating new services.

9. **The AGENTS.md style guide is enforced.** Single-word names, no destructuring, no `else`, `const` over `let`, early returns, no mocks in tests.

10. **UI changes need to use the right primitives.** SolidJS community primitives, correct component variants, `focus-visible` over `focus`, batched store updates.
