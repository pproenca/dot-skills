---
name: dev-rfc
description: >
  Create well-structured RFCs and technical proposals for software projects.
  Use this skill whenever the user wants to write an RFC, technical proposal,
  design doc, architecture doc, or system design overview. Also trigger when the
  user says things like "write an RFC", "I need to propose a new system",
  "create a technical proposal", "document the architecture", "write up the design",
  "I need a design doc", or "explain the system architecture in a doc".
  Even if they just say "RFC", "design doc", or "arch doc", use this skill.
  Covers both RFCs (proposing what to build) and architecture docs (documenting
  an existing codebase).
---

# Dev RFC Skill

Write RFCs and technical proposals that serve two purposes: **aligning stakeholders on what to build and why** (RFCs), and **helping engineers understand how a system works** (architecture docs). Most real proposals blend both — the skill helps you pick the right sections for the situation.

## Reference Templates

Read `references/template.md` for the three structural templates:

- **RFC** — for pre-build alignment. Focuses on abstract, approaches (with fair comparison), service SLAs, observability, and rollout plan.
- **Architecture Doc** — for documenting built systems. Focuses on diagrams, source tree, data flow, design philosophy.
- **One-Pager** — for small changes (< 1 week). Problem, Proposed Solution, Rollout. ~20 lines.

## Step 0: Pick the Mode

Ask the user (or infer from context) which situation they're in:

| Situation | Mode | Key question the doc answers |
|-----------|------|------------------------------|
| Planning a new system or major change | **RFC** | "Should we build this, and how?" |
| Documenting an existing system | **Architecture Doc** | "How does this system work?" |
| Proposing a change to an existing system | **RFC** (with before/after diagrams in Detailed Design) | "Why are we changing this, and what will it look like?" |
| Small scoped change (< 1 week) | **One-Pager** | "What and why, briefly?" |

For changes to existing systems, use the RFC structure as the backbone but include before/after architecture diagrams in the **Detailed Design** section, with `[NEW]` and `[CHANGED]` markers on components.

### File Placement

- **Formal proposal or RFC** — `docs/rfcs/RFC-NNN-title.md` as primary location
- **Architecture doc for the whole project** — `ARCHITECTURE.md` at the repo root
- **Subsystem doc** — `docs/design/subsystem-name.md` or alongside the code it describes

If the user hasn't specified where to put the doc, ask.

## Step 1: Understand the Project

Before writing anything, build a mental model.

**For RFCs:**
- Clarify the problem statement and constraints with the user
- Understand who the stakeholders and approvers are
- Ask about existing systems this interacts with or replaces
- Identify hard constraints (timeline, budget, compatibility, compliance)
- Ask what alternatives have already been considered or rejected

**For architecture docs:**
- Read the project's README, CLAUDE.md, and any existing docs
- Explore the source tree to identify major subsystems and their boundaries
- Trace the main data flow from input to output
- Look at key types/interfaces that flow between modules
- Check git history for context on architectural decisions

## Step 2: Draft the Document

Follow the appropriate structure from `references/template.md`. The sections to include depend on mode and project complexity — the template has scaling guidance for small/medium/large projects.

**The most important sections per mode:**

RFC — the sections approvers care about most:
1. **Abstract** — 3-5 sentence executive summary. A reader should be able to decide whether to read the full RFC from this alone.
2. **Approaches** — all evaluated options with fair comparison. This is what distinguishes an RFC from a spec.
3. **Service SLAs & Observability** — production readiness. Shows the proposal accounts for how the system will behave and be monitored in production.

Architecture Doc — the sections new contributors care about most:
1. **High-Level Architecture** (with diagram) — the single-glance understanding.
2. **Source Tree** — the "where do I find X" index.
3. **Key Design Decisions** — the "why is it done this way" answers.

## Step 3: Write Effective Content

**Not all systems are pipelines.** Choose the diagram shape that matches the system:
- **Pipeline** — compilers, data pipelines, ETL. Linear stages with data flowing through.
- **Request-flow** — services, APIs. Request path through middleware, handlers, dependencies.
- **Event-flow** — event-driven systems. Producers, queues/topics, consumers.
- **Layer diagram** — web apps, CRUD. UI → API → service → data layers.

The diagram is the centerpiece. A reader should understand the overall system flow from it alone. Use ASCII box-drawing art. Label stages with module paths and descriptions. Show data formats between stages.

**Be concrete, not abstract.** Instead of "Module A processes the input and passes it to Module B", write: "`Preprocessor::preprocess()` emits `String` (expanded text with line markers), which `Lexer::tokenize()` consumes to produce `Vec<Token>`." For proposals, use proposed type/interface names.

**Approaches should present genuine alternatives with fair pros/cons.** Don't strawman alternatives to make the recommended approach look better. Each approach should have real strengths acknowledged. A reviewer who disagrees with your recommendation should feel their preferred option was represented honestly.

**Goals & Non-Goals should be specific and falsifiable.** Example (for "migrate auth to OAuth2"):

> **Goals:**
> - All user-facing login flows use OAuth2 authorization code flow by end of Q3
> - Support Google and GitHub as identity providers at launch
> - Session token storage meets SOC 2 requirements (encrypted at rest, 24h max lifetime)
>
> **Non-Goals:**
> - Migrating service-to-service auth (stays on mTLS for now)
> - Building a custom identity provider — we'll use Auth0
> - Supporting SAML (enterprise SSO is a separate Q4 project)

**Service SLAs should be concrete.** Don't say "high availability" — state "99.95% uptime." Don't say "low latency" — state "P99 under 300ms." Justify each target.

**Separate decisions from philosophy.** Key Design Decisions are factual choices ("We use SSA form"). Design Philosophy captures principles that guide ongoing decisions ("Separation of concerns through representations").

## Step 4: Review Checklist

**For RFCs:**
- [ ] Is the Abstract clear enough that a reader can decide whether to read the full RFC?
- [ ] Does Approaches honestly represent all options with genuine pros/cons?
- [ ] Is the Recommendation well-justified — does it explain what's being given up?
- [ ] Are Service SLAs concrete with specific numbers, not vague ("high availability")?
- [ ] Are Goals & Non-Goals specific enough to evaluate the proposal against?
- [ ] Is there a concrete rollback plan with decision criteria?
- [ ] Are Open Questions clearly flagged for approver input?

**For architecture docs:**
- [ ] Can someone unfamiliar with the project understand the flow from the diagram alone?
- [ ] Are concrete types and method names in Data Flow accurate?
- [ ] Do Key Design Decisions cover what a new contributor needs first?
- [ ] Are cross-references to other docs (README, per-module docs) included?

## Step 5: Collect Feedback & Iterate (Optional)

After writing the RFC, offer to open a review UI in the user's browser. The review UI runs a local server that auto-saves feedback, supports multiple revision rounds, and lets the user explicitly approve the document.

> **Path resolution:** In the commands below, `$SKILL_PATH` refers to the absolute path of this SKILL.md file. Resolve it as the directory containing this file (e.g., if SKILL.md is at `/path/to/dev-rfc/SKILL.md`, then `$(dirname "$SKILL_PATH")` is `/path/to/dev-rfc`). **Requires Bun (or Node 22+ with `--experimental-strip-types`).**

### First Round

1. Save the RFC to its target file path.
2. Start the review server:
   ```bash
   bun run "$(dirname "$SKILL_PATH")/scripts/generate_review.ts" <doc-path> --title "<project name>"
   ```
   This starts an HTTP server on `localhost:3118` and opens the browser. Feedback auto-saves to `<doc-dir>/.rfc-review/feedback.json` as the user types (800ms debounce). The server also serves the latest version of the markdown on each refresh.
3. Tell the user: *"I've opened the RFC review in your browser at http://localhost:3118. Add feedback to any section, highlight text for inline comments, then click **Submit Feedback** (for revisions) or **Approve** (if it looks good). Your feedback auto-saves as you type."*
4. When the user says they're done reviewing, read feedback from the workspace:
   ```bash
   cat <doc-dir>/.rfc-review/feedback.json
   ```

### Check Status

- **`"status": "approved"`** — The user approved the RFC. Stop iterating. Announce that the RFC is finalized.
- **`"status": "needs_revision"`** — The user wants changes. Proceed to revision.
- **`"status": "draft"`** — The user closed the browser mid-review. Ask if they want to continue or if the current draft feedback is sufficient.

### Revision Guidelines

When revising, prioritize feedback in this order (most specific → most general):
1. **Inline comments** (`inline_comments`) — targeted at specific text. Address each one.
2. **Section feedback** (`sections[].feedback`) — per-section concerns. Revise the relevant section.
3. **Overall feedback** (`overall_feedback`) — broad themes. Apply across the document.

Empty feedback for a section means no concerns — skip it. Don't make changes where no feedback was given.

### Subsequent Rounds

After revising the RFC, start the next review round with the previous feedback visible as read-only context:

```bash
bun run "$(dirname "$SKILL_PATH")/scripts/generate_review.ts" <doc-path> --title "<project name>" \
  --previous-feedback <doc-dir>/.rfc-review/feedback-history/feedback-round-N.json \
  --iteration N+1
```

The server automatically archives the previous `feedback.json` to `feedback-history/feedback-round-N.json` on startup. The reviewer sees their previous feedback (read-only) above each section, so they can verify their concerns were addressed.

Repeat the check-status → revise → re-launch loop until the user approves or opts out.

### Termination

Stop iterating when any of these happen:
- The user clicks **Approve** in the UI (`"status": "approved"`)
- The user says "looks good", "ship it", "done", or similar
- The user explicitly says they don't want more rounds

### Static Fallback

If the server can't start (port conflict, environment issue), fall back to static mode:
```bash
bun run "$(dirname "$SKILL_PATH")/scripts/generate_review.ts" <doc-path> --title "<project name>" --static
```
This opens a standalone HTML file. Feedback downloads as `feedback.json` to `~/Downloads` on submit. Ask the user where the file landed.

Skip this step entirely if the user wants the doc written directly without a review loop, or for one-pagers.

## Step 5b: Live Authoring Mode (Optional)

Instead of writing the entire RFC and then reviewing, use **live authoring mode** where the UI opens first with a skeleton of all planned sections, you write sections one at a time, each section appears in the browser in real-time, and the user gives per-section feedback before you write the next section.

### When to Use Live Mode

- The user wants to collaborate on the RFC as it's being written
- The RFC is complex and benefits from iterative alignment on each section
- The user explicitly asks for "live", "interactive", or "step-by-step" mode

### Launch the Live Server

1. Plan the section headings for the RFC based on the template and project scope.
2. Start the server in live mode:
   ```bash
   bun run "$(dirname "$SKILL_PATH")/scripts/generate_review.ts" --live --title "<project name>" \
     --sections '["Abstract","Motivation","Goals and Non-Goals","Detailed Design","Approaches","Service SLAs","Rollout Plan"]'
   ```
   This opens the browser showing a skeleton with all planned sections as pending cards.
3. Tell the user: *"I've opened the RFC in live authoring mode at http://localhost:3118. I'll write each section one at a time — you can approve or request changes on each section before I move to the next."*

### Section-by-Section Protocol

For each section in order:

1. **Write the section content** as markdown.
2. **Push it to the server:**
   ```bash
   curl -s -X POST http://localhost:3118/api/section/add \
     -H 'Content-Type: application/json' \
     -d '{"id": "abstract", "heading": "Abstract", "markdown": "## Abstract\n\nYour content here..."}'
   ```
   The section appears in the browser immediately via SSE.
3. **Wait for user feedback:**
   ```bash
   curl -s http://localhost:3118/api/wait-feedback?section=abstract
   ```
   This blocks until the user clicks "Approve" or "Request Changes" in the browser (5-minute timeout).
4. **Handle the response:**
   - `{"action": "approve"}` — Move to the next section.
   - `{"action": "request_changes", "text": "..."}` — Read the feedback, revise the section, then push the update:
     ```bash
     curl -s -X POST http://localhost:3118/api/section/update \
       -H 'Content-Type: application/json' \
       -d '{"id": "abstract", "markdown": "## Abstract\n\nRevised content..."}'
     ```
     Then call `/api/wait-feedback?section=abstract` again.
   - `{"timeout": true}` — The user hasn't responded in 5 minutes. Prompt them in the CLI or retry.

### Completion

Once all sections are approved, assemble the full markdown from all approved sections and write it to the target file path. The user can also click "Finalize RFC" in the browser once all sections are approved.

### Fallback

If live mode encounters issues, fall back to batch mode (Step 5) by writing the full RFC first and then opening the standard review UI.

## Tone and Style

- Present tense, declarative voice for architecture docs. Future tense only for proposals.
- Concise — every word should earn its place
- Prefer showing (diagrams, code, type signatures) over telling
- Short paragraphs — this is reference material, not prose
- Markdown formatting: bold for emphasis, code blocks for types/paths, tables for comparisons

## Doc Sizing

| Change size | Format | Sections |
|------------|--------|----------|
| Small (< 1 week, single component) | **One-pager** | Problem, Proposed Solution, Rollout |
| Medium (1-4 weeks, multiple components) | **Standard RFC** | Full RFC or architecture doc |
| Large (> 1 month, cross-team) | **Full RFC + sub-docs** | Top-level doc + linked sub-docs for subsystems |

## Review Workflow Guidance

Include the status in the metadata header:

1. **Draft** — Author is still writing. Not ready for formal review.
2. **In Review** — Shared with approvers. Specify what feedback is needed.
3. **Approved** — Approvers signed off. Plan of record.
4. **Superseded** — Newer RFC replaces this one. Link to replacement.
5. **Deprecated** — System no longer exists or proposal was abandoned.
