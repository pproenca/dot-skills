# Runtime Capture — reviewing the running UI, not just the code

A static read of CSS/JSX tells you what the code *intends*; it can't tell you what the
browser actually *renders*. A screenshot is a single frozen frame. Some of the most
common design defects only exist in motion and across time:

- the easing/duration the code declares vs. what runs after the framework, GPU, and main-thread contention have their say;
- dropped frames and jank during a transition (a screenshot is always 60fps);
- layout shift (CLS) as content streams in;
- the real focus order and the live accessibility tree as a user moves through the app;
- whether a multi-page flow holds together when you actually click through it.

When the review touches the `motion-`, `interact-`, `flow-`, `state-`, or `access-`
categories and the verdict depends on rendered behaviour, drive a real browser and
capture the evidence. This skill stays **read-only**: you *observe* the running app,
you do not modify it.

## Tooling

Capture runs through **`chrome-devtools-mcp`** (Chrome's DevTools exposed as MCP tools),
invoked from the CLI with **`mcporter`**. Configure it once per the
[mcporter Chrome config](https://github.com/steipete/agent-scripts/blob/main/skills/browser-use/mcporter-config.md);
the default `chrome-devtools` server reattaches to your existing Chrome profile (logged-in
state intact). Use the `chrome-isolated` server only when you need a clean, signed-out session.

Confirm the exact tool arguments before relying on them — they evolve with the package:

```bash
mcporter list chrome-devtools --schema          # authoritative arg shapes for every tool
mcporter call chrome-devtools.list_pages --args '{}' --output text   # smoke test
mcporter daemon restart                         # if calls hang or the page list is stale
```

> The thin `browser-use` SKILL wraps only snapshot/navigate/click/fill/evaluate. The
> richer introspection below (performance traces, animation timing, a11y tree) comes from
> the underlying `chrome-devtools-mcp` tools — call them directly.

## What to capture, by review category

### Walk the multi-page flow → `flow-`

Click through the real journey and snapshot each step; this is the only way to see the
app shell drift, lost scroll/filters, and broken entry points that single-screen review misses.

```bash
mcporter call chrome-devtools.list_pages --args '{}' --output text
mcporter call chrome-devtools.select_page --args '{"pageId":1}' --output text
mcporter call chrome-devtools.navigate_page --args '{"type":"url","url":"https://app.local/orders"}' --output text
mcporter call chrome-devtools.take_snapshot --args '{}' --output text          # a11y-tree snapshot of page 1
mcporter call chrome-devtools.click --args '{"uid":"1_42","includeSnapshot":true}' --output text
mcporter call chrome-devtools.navigate_page --args '{"type":"back"}' --output text   # test Back: is scroll/filter state restored?
```

Open a route directly in a fresh tab to test entry-point integrity (`flow-entry-point-integrity`):

```bash
mcporter call chrome-devtools.new_page --args '{"url":"https://app.local/orders/8231"}' --output text
mcporter call chrome-devtools.take_snapshot --args '{}' --output text          # does a deep link render, or break?
```

### Animation timeline + jank + CLS → `motion-`, `interact-`

Record a trace around the interaction, then read the insights for long tasks, dropped
frames, and layout shift — the measured truth behind `motion-under-300ms` and
`interact-bridge-route-transitions`.

```bash
mcporter call chrome-devtools.performance_start_trace --args '{"reload":false}' --output text
mcporter call chrome-devtools.click --args '{"uid":"1_42"}' --output text       # trigger the transition under trace
mcporter call chrome-devtools.performance_stop_trace --args '{}' --output json
mcporter call chrome-devtools.performance_analyze_insight --args '{"insightName":"CLSCulprits"}' --output json
```

### Real frame rate + computed motion → `motion-`, `interact-`

`evaluate_script` runs JS in the page, so you can read what actually animated and sample
the frame rate during a second of interaction:

```bash
# What is actually animating, and with what timing the browser resolved?
mcporter call chrome-devtools.evaluate_script --output json --args '{"function":"() => document.getAnimations().map(a => ({ name: a.animationName || a.transitionProperty, duration: a.effect.getComputedTiming().duration, easing: a.effect.getComputedTiming().easing }))"}'

# Sample FPS and accumulated layout shift over ~1s (run, then trigger the interaction)
mcporter call chrome-devtools.evaluate_script --output json --args '{"function":"async () => { const shifts=[]; const po=new PerformanceObserver(l=>{for(const e of l.getEntries()) if(!e.hadRecentInput) shifts.push(e.value);}); po.observe({type:\"layout-shift\",buffered:true}); let f=0; const t0=performance.now(); await new Promise(r=>{const tick=()=>{f++; performance.now()-t0<1000?requestAnimationFrame(tick):r();}; requestAnimationFrame(tick);}); po.disconnect(); return { fps:f, cls:+shifts.reduce((a,b)=>a+b,0).toFixed(4) }; }"}'
```

### Accessibility tree + focus order → `access-`, `interact-`

The verbose snapshot is the a11y tree as assistive tech sees it. Read `activeElement`
before and after a navigation to confirm focus moves to new content
(`interact-move-focus-on-navigation`):

```bash
mcporter call chrome-devtools.take_snapshot --args '{"verbose":true}' --output text
mcporter call chrome-devtools.evaluate_script --output json --args '{"function":"() => ({ tag: document.activeElement?.tagName, label: document.activeElement?.textContent?.trim().slice(0,40) })"}'
```

### Under throttle and at breakpoints → `resp-`, `motion-`

Motion that's smooth on your machine janks on a mid-tier phone. Emulate the constraint,
then re-run the FPS/trace capture:

```bash
mcporter call chrome-devtools.emulate --args '{"cpuThrottlingRate":4}' --output text   # 4x CPU slowdown
mcporter call chrome-devtools.resize_page --args '{"width":390,"height":844}' --output text   # phone viewport for resp-
mcporter call chrome-devtools.emulate --args '{"colorScheme":"dark"}' --output text   # check the dark-mode pass
```

## Folding captured evidence into the review

A runtime finding makes the **Before** column a *measurement*, not a guess — that is the
whole point of capturing. Cite the number so the author can reproduce it:

| Severity | Before | After | Why |
| --- | --- | --- | --- |
| High | route change measured 412ms, 11 dropped frames, CLS 0.18 (`performance_analyze_insight`) | render a skeleton during pending; wrap the swap in `startViewTransition` | A blank 412ms flash with a layout jump reads as broken; `interact-bridge-route-transitions` |
| Medium | `getAnimations()` shows the toast easing resolved to `linear` despite the CSS `ease-out` | scope the `transition` so the keyframe isn't overridden | Linear motion feels mechanical; `motion-ease-out-custom` |

## Guardrails

- **Read-only.** Capture is observation. `click`/`fill`/`navigate_page` are for *walking*
  the app to reach the state under review — never to mutate real data. Don't run capture
  against production with a logged-in account that can write.
- **Reattach, don't spawn.** Prefer the `chrome-devtools` (existing-profile) server; reach
  for `chrome-isolated` only for a deliberately clean session.
- **Don't commit artifacts.** Trace JSON, screenshots, and snapshots are evidence for the
  review, not repo files.
