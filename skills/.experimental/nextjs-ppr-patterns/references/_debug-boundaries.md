# Debugging the boundary — what actually rendered static vs dynamic

The rules in this skill tell you how to *write* PPR. They can't tell you what you
actually *got*. With Cache Components the static/dynamic split is implicit — it falls out
of where your `<Suspense>` boundaries, `'use cache'` directives, and runtime reads happen —
so a code read is a hypothesis, not proof. The questions only the running build/app can answer:

- **Which routes/segments are in the static shell, and which render at request time?**
- **What content actually landed in the shell vs streamed in as a dynamic hole?** (the real PPR boundary)
- **Where is the CSR/SSR boundary** — which subtrees are server-rendered HTML vs hydrated `'use client'` islands?
- **How does loading behave** — is the fallback in the shell, how long until the hole swaps in, does it shift layout (CLS)?
- **Why is a route dynamic when you expected it static** (a stray `cookies()`, an uncached `fetch`, a `Math.random()`)?

Reach for this when a PPR result surprises you, when chasing a `blocking-route` build error,
or to *verify* a page renders as the `shell-`, `runtime-`, and `compose-` rules intend. Use the
two instruments below in order — the build is cheapest and most authoritative; drive a browser
when the verdict depends on what was actually received and when. **Stay read-only:** you are
observing the app, not mutating it.

---

## Instrument 1 — Build-time signal (`next build`)

The build is the cheapest source of truth for the static/dynamic split: it runs the prerender and
reports, per route, what it could put in the shell.

```bash
next build
```

Read the route legend in the summary:

- `○` (Static) — fully prerendered into the shell.
- `◐` (Partial Prerender) — a static shell **plus** dynamic holes streamed at request time; this is
  PPR working as intended. At build time Next.js emits the static HTML shell **plus a `postponedState`
  blob** for the holes (adapter/build output identifies these as `renderingMode: 'PARTIALLY_STATIC'`).
- `ƒ` (Dynamic) — rendered entirely at request time. If a route you expected to be partial (`◐`)
  shows as `ƒ`, a runtime read escaped to the page root — see `runtime-request-apis-force-a-boundary`
  and `shell-place-boundaries-low`.

The build is also where the boundary contract is *enforced*: uncached/runtime data that isn't wrapped
or cached fails here with `Uncached data was accessed outside of <Suspense>` (the `blocking-route`
error — see `shell-wrap-uncached-data`). A clean build is your first proof the boundaries are placed
legally. If the error only surfaces in CI / `next build` rather than the dev overlay, run
`next build --debug-prerender` for a prerender stack trace that names the exact component that read
uncached data.

For cache hits/misses, turn on verbose cache logging (also works in `dev`); in dev, the per-request
log also splits **Compile** vs **Render** time so you can see which segments do request-time work:

```bash
NEXT_PRIVATE_DEBUG_CACHE=1 npm run build
# In dev, console logs from a 'use cache' scope are prefixed with `Cache`.
```

---

## Instrument 2 — chrome-devtools-mcp via mcporter (the rendered truth)

When the verdict depends on what the *browser* received and when, drive a real Chrome via
**`chrome-devtools-mcp`**, invoked from the CLI with **`mcporter`**. Configure it once per the
[mcporter Chrome config](https://raw.githubusercontent.com/steipete/agent-scripts/refs/heads/main/skills/browser-use/mcporter-config.md);
the `chrome-devtools` server reattaches to your existing logged-in profile (use `chrome-isolated`
only for a deliberately clean session). See the
[browser-use skill](https://raw.githubusercontent.com/steipete/agent-scripts/refs/heads/main/skills/browser-use/SKILL.md)
for the workflow. The thin browser-use wrapper covers `navigate`/`snapshot`/`click`/`fill`/`evaluate`;
the richer introspection below (console, performance traces, throttling) comes from the underlying
`chrome-devtools-mcp` tools — call them directly. Confirm arg shapes first; they evolve:

```bash
mcporter list chrome-devtools --schema                              # authoritative arg shapes
mcporter call chrome-devtools.list_pages --args '{}' --output text  # smoke test / find the tab
mcporter call chrome-devtools.select_page --args '{"pageId":0}' --output text  # target the tab (id from list_pages)
mcporter daemon restart                                             # if calls hang or the list is stale
```

### The static shell vs the hydrated DOM — diff them to find the holes

This is the single most direct way to *see* the PPR boundary. The raw HTML response is exactly the
static shell (it's what ships before any JS); the live DOM is the shell **plus** everything that
streamed in. The difference is your set of dynamic holes.

```bash
# A) The static shell — raw HTML, no JS executed. Dynamic holes appear here as their
#    Suspense fallback/skeleton, NOT as real content (see shell-suspense-is-the-boundary).
curl -s https://app.local/dashboard > /tmp/ppr-shell.html

# B) The hydrated DOM after streaming completes.
mcporter call chrome-devtools.navigate_page --args '{"type":"url","url":"https://app.local/dashboard"}' --output text
mcporter call chrome-devtools.evaluate_script --output text \
  --args '{"function":"() => document.documentElement.outerHTML"}' > /tmp/ppr-live.html

# C) What is in (B) but not (A) = the content that streamed in (the dynamic holes).
diff <(sort /tmp/ppr-shell.html) <(sort /tmp/ppr-live.html) | head -40
```

Sanity checks on the result:

- A personalized/uncached value (a name from `cookies()`, a live count) present in `ppr-shell.html`
  means it leaked into the static shell — likely a missing boundary or wrongly-cached request data
  (`cache-pass-runtime-values-as-props`).
- A skeleton/fallback present in the shell but the real widget only in the live DOM is PPR working as
  intended (`compose-single-dynamic-hole`).

### Locate the CSR/SSR boundary (hydration islands)

`'use client'` components are the only interactive (hydrated) islands; everything else is static
server HTML. React 19 stamps no public DOM marker for hydration roots, so confirm islands
*behaviorally* rather than by selector, and pull console messages to catch hydration mismatches (the
classic CSR/SSR-boundary bug where server and client HTML disagree):

```bash
# The static-shell-vs-DOM diff above already shows which subtrees are dynamic. A control is a
# client island if interacting with it changes state WITHOUT a navigation:
mcporter call chrome-devtools.take_snapshot --args '{}' --output text          # get fresh uids
mcporter call chrome-devtools.click --args '{"uid":"<from snapshot>","includeSnapshot":true}' --output text

# Hydration mismatches and other client errors surface in the console:
mcporter call chrome-devtools.list_console_messages --args '{}' --output text
```

### Loading behavior — fallback→content swap, streaming, CLS

Record a trace around the load to measure how long the hole shows its fallback and whether the swap
shifts layout — the runtime proof behind `compose-parallel-holes` and `shell-place-boundaries-low`.

```bash
mcporter call chrome-devtools.performance_start_trace --args '{"reload":true}' --output text
# (page loads under trace)
mcporter call chrome-devtools.performance_stop_trace --args '{}' --output json   # summary includes CLS + long tasks
# Drill into a named insight — pick the name from the list the trace reports (e.g. LCPBreakdown):
mcporter call chrome-devtools.performance_analyze_insight --args '{"insightName":"LCPBreakdown"}' --output json
```

Slow networks expose streaming you can't see locally — throttle, then re-run the trace:

```bash
mcporter call chrome-devtools.emulate --args '{"cpuThrottlingRate":4}' --output text
```

---

## Reading the evidence

| Symptom observed | Likely cause | Rule |
|---|---|---|
| Route is `ƒ` (fully dynamic) when you expected partial | A runtime read (`cookies`/`headers`/`searchParams`) or uncached `fetch` at the page root | `runtime-request-apis-force-a-boundary`, `shell-place-boundaries-low` |
| `Uncached data was accessed outside of <Suspense>` at build | Uncached/runtime data not wrapped or `'use cache'`d | `shell-wrap-uncached-data` |
| Personalized value appears in `curl` shell HTML | It leaked into the static shell (missing boundary, or cached request data) | `cache-pass-runtime-values-as-props`, `shell-suspense-is-the-boundary` |
| Whole page is one big fallback / empty shell | One boundary wrapped too much, or the app opted out of the shell | `shell-place-boundaries-low`, `compose-do-not-opt-out-the-shell` |
| Hydration mismatch in the browser console | Non-deterministic value rendered without `connection()`/cache | `runtime-gate-nondeterminism-with-connection` |
| Hole never streams in / build hangs ~50s | A runtime Promise passed into a `'use cache'` scope | `cache-pass-runtime-values-as-props` |

## Guardrails

- **Read-only.** `curl`, traces, console reads, and `evaluate_script` reads observe the app.
  `click`/`fill` are only for *driving* to the state under test — never to mutate real data, and not
  against a production account that can write.
- **Reattach, don't spawn.** Prefer the `chrome-devtools` (existing-profile) server; use
  `chrome-isolated` only for a deliberately signed-out session.
- **Don't commit artifacts.** `/tmp/ppr-*.html`, trace JSON, and screenshots are evidence for the
  investigation, not repo files.
