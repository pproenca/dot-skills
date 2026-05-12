---
name: web-taste
description: >
  Designs React 19 + Next.js 16 + Tailwind CSS experiences with real
  taste — starting from user goals, not pixels. Use this skill whenever
  the user asks you to build a page, screen, form, dashboard, or any
  user-facing web UI. Trigger when the user says "build a settings
  page", "create a dashboard", "design this properly", "I want this
  to feel premium", "make it look like Linear/Stripe/Vercel", or any
  Next.js App Router / React / Tailwind UI task. Also trigger when
  reviewing UI for design quality, or when the user says the output
  "looks like a wireframe", "feels like Bootstrap", or "looks
  AI-generated." When building any user-facing web view, lean toward
  triggering this skill.
---

# Web Taste

Taste doesn't start at the pixel level. It starts at "who is this
person and what do they need?" The visual refinement is the LAST step.
The first step is understanding the user's world deeply enough that
the interface design feels inevitable — like it couldn't have been
designed any other way.

Your default mode skips straight to layout. It produces technically
correct React that looks generic because it was never grounded in
a real person's needs — a stack of cards, a sidebar, a settings list.
This skill changes the order of operations: think like a designer
first, then write code.

## Phase 0: The 0.5-Second Test (ORIENT before everything)

Before designing anything, answer ONE question:

> **What does the user SEE in the first half-second — before they
> read a single word?**

This is not about content. It's about the SHAPE of the screen.
Close your eyes and picture it. What dominates?

- A **single hero number** with a sparkline? → Analytics / metric dashboard
- A **gradient card** with bold white text? → Status / billing / hero page
- A **table with sticky chrome** and a search bar? → Data console / admin
- A **grid of media cards**? → Library / gallery / content collection
- A **center-aligned form** with generous space? → Sign-up / auth / single-action
- A **two-pane list + detail**? → Email / inbox / CRM
- A **timeline of events**? → Activity feed / audit log

If your answer is "a sidebar and some cards in a content area" →
STOP. That's a CMS theme, not a product. Go back and find the
visual shape that matches what this user actually needs.

Write the 0.5-second answer as the FIRST line of the experience
brief, as a JSDoc comment on the route:

```tsx
// 0.5s: One huge revenue number on black, sparkline pulsing below
export default async function DashboardPage() { ... }
```

This single sentence anchors every decision that follows. If the
code you write doesn't produce that shape, something went wrong.

## Phase 1: Design Thinking (Before You Touch React)

Before writing a single line of JSX, answer these questions. Write
the answers down as comments or in your thinking. If you skip this
phase, your output will look like every other AI-generated UI —
correct but soulless.

### 1. Who is the user?

Not "a SaaS admin." A real person with a context:

- What moment are they in when they open this page? (Triaging the
  morning's alerts? Sharing a link in a meeting? Reviewing the
  quarter before a board call?)
- What did they just do before arriving here? (Clicked a notification
  email? Searched? Followed a deep link from Slack?)
- What do they want to accomplish in under 10 seconds?

This shapes EVERYTHING. A user pasted into the page via a Slack
deep-link needs a giant headline that reorients them. A user with
the page open all day wants quiet chrome and big working space. A
user evaluating during a demo wants the value proposition to be
visible without scrolling.

### 2. What should they FEEL?

This is the question that separates designed products from CRUD
admin panels. Linear doesn't show you a kanban — it makes shipping
feel like an obsession. Stripe doesn't show you payment forms — it
makes commerce feel like a solved problem. Every design choice
serves that emotional goal.

Before choosing components, decide the emotional intent:

- **Focused / Productive** → muted palette, monochrome chrome, single
  accent color, generous space, Inter or system-ui sans
- **Confident / Trustworthy** → deeper blues/greens, clear data
  presentation, generous whitespace, classical proportions
- **Delighted / Premium** → unexpected microinteractions, rich
  gradients, subtle 3D, considered typography (Söhne, Inter Display)
- **Energetic / Bold** → high saturation, large display type,
  asymmetric layouts, strong photography
- **Calm / Editorial** → serif typography, narrow text columns, lots
  of breathing room, restrained color

The emotional intent drives every visual decision downstream: color
tokens, scale, spacing, whether data is listed or visualized,
whether the page feels dense or spacious.

### 3. What are their goals and pain points?

For each page, identify:

- **Primary goal** — the ONE thing most users come here to do
- **Secondary goals** — things some users occasionally need
- **Pain points** — what frustrates users in this domain?

A billing page: the primary goal isn't "see all billing info." It's
"change the payment method that just expired" or "download last
month's invoice for expense reports." The pain point is wading
through plan summaries and feature comparisons to find the one
action that needs doing.

### 4. What features serve those goals?

Map goals to features. Not "what features could this page have?"
but "what's the minimum set of features that makes the primary goal
effortless?" Every feature that doesn't serve a goal is clutter.

Group features by priority:

- **Must-have** — blocks the primary goal without it
- **Should-have** — significantly improves the experience
- **Could-have** — nice but the user doesn't miss it if it's absent

### 5. How do features become routes?

This is information architecture — deciding what goes where in the
App Router:

- **One primary action per route.** If a page tries to do two
  things, split it into two routes or use a sheet/dialog for the
  secondary task.
- **Group by user intent, not by data type.** A user doesn't think
  "I want to see my notification settings." They think "I want
  Slack to stop pinging me during deep work." Group features by
  the problem they solve, not by their technical category.
- **Navigation follows the user's mental model.** `/settings` →
  `/settings/billing` is obvious. `/admin/organizations/{org}/members/{member}/preferences/notifications`
  is six levels deep for something the user sets once. Use parallel
  routes (`@modal`) and intercepting routes for "open as overlay"
  patterns when full navigation is overkill.

### 6. What components serve each feature?

NOW you think about React — but through the lens of user intent:

- **Server Component vs Client Component** — RSC by default. Use
  `'use client'` only when interactivity is required. Don't ship a
  hydration boundary for a list that doesn't need one.
- **Dialog vs Popover vs Sheet vs Full page** — see [ux-modality](../../experimental/web-rules/references/ux-modality.md).
  Pick the lightest container that fits.
- **Form vs separate fields** — Server Actions + `<form action={}>`
  for anything that mutates. Standalone fields with `useOptimistic`
  for live-saving settings.
- **Table vs Card grid vs List** — Table when scanning columns is
  the job (sortable, filterable, compare values). Card grid for
  heterogeneous browse. List for homogeneous rows with one primary
  identifier per row.
- **shadcn/ui vs custom** — shadcn/ui Radix-based primitives are
  the default. Custom components only when no primitive fits.

The component choice IS the design. A `<DataTable>` with sticky
header for a financial dashboard feels precise and bureaucratic. A
gradient card grid for the same data feels exploratory and editorial.
Neither is wrong — the right choice depends on who the user is and
what moment they're in.

## Phase 2: Visual Design

After Phase 1, you know who the user is, what they need, how they
should feel, and what components serve those needs. Now make it
beautiful. The emotional intent from Phase 1 drives every choice here.

### 1. Hierarchy Through Scale

Not just font weight — dramatic scale contrast. The most important
thing on screen should be *physically large*, not just bold.

- **Hero numbers at display scale** — a revenue figure, a count, a
  percentage should dominate the page. Use `text-6xl` or `text-7xl`
  with `font-semibold tracking-tight tabular-nums`. Linear's
  velocity charts use 64-72 px display numbers. Don't shrink
  important data into a `text-sm` row.
- **Supporting text whispers** — everything that isn't the hero
  element gets `text-sm` or `text-xs` in `text-muted-foreground`.
  The contrast between the hero and the support IS the hierarchy.
- **Space as luxury** — leave empty areas. A number floating in a
  sea of background is more powerful than the same number crammed
  into a dense `DataTable`. Space communicates importance.

```tsx
// Hero metric — scale dominates, whisper labels
<section className="p-8">
  <p className="text-sm text-muted-foreground">Net revenue · last 30 days</p>
  <p className="mt-2 text-7xl font-semibold tracking-tight tabular-nums">
    ${(revenue / 100).toLocaleString()}
  </p>
  <p className="mt-2 flex items-center gap-1 text-sm text-emerald-600">
    <ArrowUpRight className="size-4" aria-hidden="true" />
    +12.4% vs prior period
  </p>
</section>
```

### 2. Color Is Math, Not Vibes

NEVER pick colors by hand. Color harmony is a solved mathematical
problem. This skill bundles a palette generator that computes every
color from a single seed hue — analogous harmony, WCAG contrast
validated, light and dark mode variants emitted as CSS custom
properties and a Tailwind config snippet.

**Before writing any view code, run the palette generator:**

```bash
python scripts/generate_palette.py \
  --seed <hue-degrees> \
  --mode both \
  --items <collection-count> \
  --app "App Name"
```

Seed hue guide:

- 0–30° = warm (creative, social, dating, food)
- 30–60° = golden (finance, productivity, mail)
- 60–150° = green (health, fitness, sustainability)
- 150–210° = cyan/teal (developer tools, infra, cloud)
- 210–270° = blue (trust, fintech, enterprise SaaS)
- 270–330° = purple (creative, AI, premium)
- 330–360° = pink/red (energy, gaming, e-commerce)

Paste the generated `:root` and `.dark` CSS custom properties into
`app/globals.css`, and use ONLY those tokens via Tailwind utilities
(`bg-primary`, `text-muted-foreground`, `border-border`). The
palette is computed — every color is mathematically related to the
seed, contrast ratios are pre-validated, and light/dark variants
are included.

Rules that never break:

- **One seed hue per app.** Everything derives from it.
- **Collections use analogous variations** (the `--items` flag),
  not random hues. They sit together because they're ±30° of seed.
- **Never use raw Tailwind palette classes** like `bg-blue-500`,
  `text-red-600`, `border-gray-200` — those don't theme and aren't
  contrast-audited. Use semantic tokens.
- **Use `bg-background`, `text-foreground`, `border-border`,
  `text-primary`** — not ad-hoc `Color(...)` calls or arbitrary
  classes scattered through component code.

### 3. Show Data, Don't List It

When data is the content (analytics, financial stats, progress),
VISUALIZE it instead of putting it in a `LabeledRow`:

- **Sparklines and area charts** for trends over time (Recharts,
  Tremor, or hand-rolled SVG)
- **Gauges and rings** for progress toward a goal
- **Large hero numbers** with delta arrows and percentage chips
- **Heatmaps** for activity by time-of-day or by-day-of-week
- **Color-coded bars** for composition (revenue by source, time split)

A `<dl><dt>Revenue</dt><dd>$8,432</dd></dl>` is information. A large
"$8,432" in `text-6xl tabular-nums` with a sparkline below it is an
*experience*. The emotional intent from Phase 1 tells you which one
to use.

### 4. Card-Based Composition

Don't default to a single bordered container for everything. Compose
with `rounded-xl border bg-card` containers when the content is
heterogeneous:

- Cards with `rounded-xl border bg-card text-card-foreground p-6`
- Each card is a self-contained visual unit with its own hierarchy
- Cards can have gradient backgrounds for visual richness
  (think Vercel deployment cards, Linear cycle cards)
- Use CSS grid with `auto-rows-fr` for equal-height card grids

Tables are for homogeneous scannable data. Cards are for dashboards,
overviews, and content-rich pages where each item has its own story.

### 5. Content Realism

The data IS the design. Every preview tells a coherent story:

- Real names ("Elena Marsh"), plausible numbers ("$47.83", "4.3K"),
  varied lengths, temporal realism ("2 hours ago", "Yesterday")
- Data relationships that make sense (Designer → Design dept)
- If your preview data looks fake (`"Item 1"`, `"Lorem ipsum"`,
  `foo@example.com`), your design looks fake

Generate seed data with a coherent narrative — even in fixtures.

### 6. Restraint

What you leave out defines taste. No instruction headers ("Welcome
to your dashboard"). No uniform icon decorations on every row. No
tutorial overlays. No demo naming. For every element, ask: "what
happens if I remove this?" If nothing — remove it.

### 7. Craft

The invisible details that feel right:

- `tabular-nums` on changing numbers so digits don't reflow
- `tracking-tight` on display headings
- `transition-colors duration-150` on every interactive element
- `hover:` + `focus-visible:` + `active:` states on every button
- `motion-safe:` on transforms (see [acc-reduce-motion](../../experimental/web-rules/references/acc-reduce-motion.md))
- `truncate` + `line-clamp-N` instead of overflow hidden + ellipsis JS
- `font-variant-numeric: tabular-nums` everywhere numbers tick
- Accessibility as design, not compliance (see [web-rules](../../experimental/web-rules/SKILL.md))

### 8. Character

Each page has a distinct personality. Character comes from:

- Domain-appropriate color palettes (cool blue for fintech, warm
  ochre for crafts, vivid green for sustainability)
- Content-specific typography pairings (a serif headline + Inter
  body feels editorial; mono in the chrome feels developer-y)
- Cover the navigation bar — can you still tell what app this is?

If a user dropped into your page with the nav bar covered, would
they know what app they're in? Linear's character is in its sharp
chrome and cycle visualization. Stripe's is in its perfectly-aligned
data tables and trust-blue accent. Find yours.

## Applying Both Phases

When asked to build a route, layout, or component:

1. **Phase 1** — Think through the user, their goals, feature
   groupings, route structure, and component choices. Write brief
   notes (as code comments or in your response) showing your design
   reasoning. This is not optional — it's what separates a designed
   experience from a decorated layout.

2. **Phase 2** — Write the React/Next.js/Tailwind code with all
   eight fundamentals applied. Start with realistic data and seed
   fixtures. Build minimal, add only what earns its place, then
   polish with craft details.

3. **Self-check** — Before finishing, ask: "Would a real user using
   this product in the moment I identified in Phase 1 feel like
   this page was designed for them?" If not, something in Phase 1
   was wrong — go back.

## What "No Taste" Looks Like

```tsx
// NO TASTE — jumped straight to layout, no user thinking
export default function DemoPage() {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <p className="text-gray-600 mb-4">
        Welcome to your dashboard! Here you can see all your data.
      </p>
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div key={i} className="border rounded p-4">
            <h2 className="font-semibold">Item {i}</h2>
            <p className="text-sm text-gray-500">Description</p>
            <button className="bg-blue-500 text-white px-3 py-1 rounded mt-2">
              Action
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
```

No user thinking. No goals. Instruction header ("Welcome to your
dashboard"). Numbered placeholders. Hardcoded `text-gray-*` and
`bg-blue-*`. Generic naming. No character.

## What Taste Looks Like

```tsx
// GOLDEN — Stripe-inspired revenue overview
// User: Maya, finance ops, opens this every morning while drinking coffee
// Emotional intent: CONFIDENT — make the number trustworthy, the trend obvious
// Hero: net revenue dominating the top, sparkline whispering below
export default async function RevenuePage() {
  const [revenue, trend, recent] = await Promise.all([
    getNetRevenue(),
    getTrend(),
    getRecentPayments(),
  ])

  return (
    <main className="mx-auto max-w-6xl px-6 py-8 space-y-8">
      <section>
        <p className="text-sm text-muted-foreground tracking-wide uppercase">
          Net revenue · last 30 days
        </p>
        <h1 className="mt-2 text-7xl font-semibold tracking-tight tabular-nums">
          ${(revenue / 100).toLocaleString()}
        </h1>
        <div className="mt-3 flex items-center gap-3">
          <span className={cn(
            'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium',
            trend.delta >= 0
              ? 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-400'
              : 'bg-destructive/10 text-destructive'
          )}>
            {trend.delta >= 0 ? <ArrowUpRight className="size-3" /> : <ArrowDownRight className="size-3" />}
            {Math.abs(trend.delta).toFixed(1)}%
          </span>
          <span className="text-sm text-muted-foreground">vs prior 30 days</span>
        </div>
        <RevenueSparkline data={trend.points} className="mt-6 h-16 w-full" />
      </section>

      <section aria-labelledby="recent-heading">
        <h2 id="recent-heading" className="text-sm font-medium text-muted-foreground mb-3">
          Recent payments
        </h2>
        <ul className="rounded-xl border bg-card divide-y">
          {recent.map((p) => (
            <li key={p.id} className="flex items-center justify-between px-4 h-14">
              <div className="min-w-0">
                <p className="font-medium truncate">{p.customer}</p>
                <p className="text-xs text-muted-foreground">{p.email}</p>
              </div>
              <p className="font-mono tabular-nums">${(p.amount / 100).toLocaleString()}</p>
            </li>
          ))}
        </ul>
      </section>
    </main>
  )
}
```

Design comment explains user moment and emotional intent. Hero
revenue number dominates the screen (not buried in a `<dl>`).
Tabular-nums keeps digits from reflowing. Semantic tokens
(`text-muted-foreground`, `bg-card`, `border`) — no raw grayscale.
Sparkline supports the hero number, doesn't compete with it. You
know this is a fintech product without reading the title.

## Component Palette Quick Reference

When you instinctively reach for a tutorial component, STOP:

| NEVER (reflex) | GOLDEN (reach for this instead) |
|----------------|-------------------------------|
| `<table>` for everything | Cards for heterogeneous; table for sortable columns |
| `Form` + `Section` boxes | Server Action + flat sections separated by `space-y-8` |
| `<dl><dt><dd>` for metrics | Hero typography `text-6xl tabular-nums` |
| Generic ProgressBar | Sparkline / area chart / radial gauge |
| `<Button>Save</Button>` | Autosave with optimistic UI (see [ux-settings](../../experimental/web-rules/references/ux-settings.md)) |
| `text-gray-500` | `text-muted-foreground` (semantic token) |
| `text-base` for headings | `text-3xl tracking-tight` or larger |
| Default border | Tinted backgrounds, gradients, `bg-card` token |
| `confirm()` for destructive | Typed confirmation OR Undo toast |
| `useState` + `useEffect` for data | Server Component `await getData()` |

Modern stack idioms to reach for: Server Components by default,
Server Actions for mutations, `useOptimistic` for live UI,
`<Suspense>` for streaming, parallel routes (`@modal`) for overlays
with their own loading states, intercepting routes for "open as
modal with a real URL".

Reference apps to study: Linear (sharp chrome, cycle visualization,
keyboard-first), Stripe (perfectly-aligned tables, trust-blue,
generous typography), Vercel (gradient cards, mono in chrome,
deployment cards), Notion (in-context editing, content-as-UI),
Apple-fueled fintech UI (Cash App, Robinhood, Wealthfront).

## The Screen Becomes the Content

Study Linear's issue detail view: the page isn't a form *about* an
issue — the entire screen IS the issue. The title is the page
heading at hero scale. The description IS the body. Actions live in
chrome that fades away. There's no "Edit issue" page; editing
happens in place.

This is the highest level of taste: the UI dissolves into the
content. The page doesn't frame the data — it becomes the data.

Techniques for this:

- **In-place editing** — `contenteditable` on the title and body so
  the page IS the editor. Save on blur via Server Action.
- **Mono in chrome, sans in content** — gives developer tools a
  distinct character without making the body unreadable.
- **Smart typography in lists** — Linear bolds the issue ID prefix
  and leaves the title in regular weight. This tiny detail makes
  identifier-scanning dramatically faster. Find the equivalent
  typographic hierarchy for your domain.
- **Detail views look like read mode** — even in edit-able products,
  the detail view doesn't show a form UI. The same content reads
  beautifully *and* edits in place.

## Reference: Web Design DNA

When making specific design decisions, read `references/web-design-dna.md`
in this skill's directory. It synthesizes patterns from systematically
studying Linear, Stripe, Vercel, Notion, and high-craft consumer apps
(Cash App, Things, Arc) — real components, real measurements, real
design analysis.

Key sections to consult:

- **Three modes of web app design** — Dashboard (data-heavy, dark
  chrome), Utility (CRUD-driven, light surfaces), Editorial (content-
  first, expressive typography)
- **Universal measurements** — card radius (12-16 px), header height
  (56-64 px), content max-width (1024-1280 px)
- **Onboarding templates** — feature-list vs hero-illustration patterns
- **Button hierarchy** — filled primary, outline secondary, ghost
  tertiary; destructive isolated by position not just color
- **Detail-page-becomes-content** — the Linear / Notion technique
- **Empty states** — show structure, not "no data" messages

## The Mindset

You are not a developer who can also design. You are a designer who
thinks about people first and expresses the result in React,
Next.js, and Tailwind. The code is the medium. The product is the
moment when a human opens their browser and the interface feels
like it was made just for them.
