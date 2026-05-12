# Web Design DNA — Cross-Product Synthesis

Patterns extracted from studying Linear, Stripe, Vercel, Notion, Cash App,
and Arc as of 2026. Sources: live product UI, public design system docs,
component libraries (shadcn/ui, Radix, Tremor), and engineering blog
deep-dives.

## The Three Modes of Modern Web App Design

### Mode 1: Console (Linear, Vercel, Sentry, Stripe Dashboard)
- **Background**: Near-black in dark mode (#0a0a0a / #131414), off-white
  in light mode (#fafafa)
- **Chrome**: Minimal. Sidebar with subtle dividers, header with sticky
  page actions, no big illustrations
- **Content**: Dense lists of issues / deployments / customers / events
- **Data**: Inline charts, sparklines, status pills, monospace identifiers
- **Emotion**: Focused, productive, control. The user is the operator.
- **Typography**: Inter / Geist / SF Pro — sans-serif workhorse. Monospace
  for IDs and code (Geist Mono, JetBrains Mono).
- **Navigation**: Sidebar primary, keyboard-first (Cmd+K palette mandatory)
- **Use when**: The app's purpose is operating, monitoring, or managing
  ongoing systems

### Mode 2: Editorial (Notion, Stripe Marketing, Cash App, Things)
- **Background**: White or very light surface, generous max-width content
  columns (640-720px for prose)
- **Chrome**: Disappears — only navigation chrome and one action button
- **Content**: Long-form text, headings, in-place editing, embedded media
- **Data**: Inline (the data IS the content)
- **Emotion**: Calm, considered, focused on the single thing you're making
- **Typography**: Often serif headlines (Tiempos, Söhne, Charter) paired
  with sans-serif body. Larger sizes than typical SaaS.
- **Navigation**: Minimal. Sidebar that hides on focus, or top-only nav
- **Use when**: The app's purpose is creating, reading, or thinking

### Mode 3: Spectacle (Stripe homepage, Linear marketing, Vercel deploys)
- **Background**: Animated or gradient — the page IS the experience
- **Chrome**: Almost none — full-bleed visuals, micro-interactions on
  every element
- **Content**: One bold idea per screen; scroll reveals supporting
  evidence
- **Data**: Decorative when present; always with motion
- **Emotion**: Premium, ambitious, "this product is serious"
- **Typography**: Very large display sizes (text-7xl, text-8xl),
  optical letter-spacing, custom variable fonts
- **Navigation**: Top nav with scroll-aware blur/shrink
- **Use when**: Marketing pages, hero feature reveals, deployment
  ceremonies (Vercel's "deploying" screen is theater)

Most products MIX modes: Linear is Console (the app) + Spectacle (the
marketing site) + Editorial (the issue detail). Pick mode per route.

## Universal Design Principles

### 1. The Page IS The Content
Linear's issue detail is the issue. Notion's page is the document.
Stripe's invoice view is the invoice. In none of these does the UI
"frame" the data — the content IS the UI surface. Look for opportunities
to make the page disappear into its content.

Implementation in Next.js:
```tsx
// Linear-style issue detail — no "edit" mode, the page IS the editor
'use client'
export function IssueDetail({ issue }: { issue: Issue }) {
  return (
    <article className="mx-auto max-w-3xl p-8 space-y-6">
      <input
        defaultValue={issue.title}
        className="w-full text-3xl font-semibold tracking-tight bg-transparent border-none focus:outline-none"
        onBlur={(e) => updateTitleAction(issue.id, e.target.value)}
      />
      <RichTextEditor
        defaultValue={issue.body}
        onBlur={(body) => updateBodyAction(issue.id, body)}
      />
    </article>
  )
}
```

### 2. One Accent Color, Used Sparingly
Linear uses a single brand purple (~#5e6ad2) in:
- Active sidebar item background
- Primary button fill
- Pull-quote borders
- Cycle progress
That's it. Four placements across the entire product.

Stripe uses indigo-blue (#635bff) similarly: primary CTA, link color,
active state. Trust + simplicity.

Anti-pattern: rainbow palettes where every section has its own brand
color. Use semantic tokens; reserve hue variation for *content
categorization* (chart series, status pills), not for chrome.

### 3. Card vs Row Grammar
- **Card**: Used for dashboards, summaries, marketing grids. Self-
  contained, rounded corners (12-16px), subtle border or shadow,
  generous padding (24px). Cards say "here's a snapshot — tap to
  dive deeper."
- **Row**: Used for lists where each item has the same shape (issues,
  customers, deployments, files). Full-width, divider-separated,
  compact padding (8-12px vertical). Rows say "here's structured
  data — scan and act."

The transition from card -> row signals depth level. Dashboard cards
link to row-based detail lists.

### 4. Onboarding: Three Templates

**Feature List** (Notion, Linear, Vercel):
```text
[Icon — same color, same style for all rows]  Bold Title
                                              Description (1 sentence)
[Icon]  Bold Title
        Description
[Icon]  Bold Title
        Description
        [=== Get started ===]
```

**Hero Illustration** (Stripe, Cash App):
```text
[Large custom illustration — brand character]
            Bold Headline
            Body subhead (centered)
[=== Primary CTA ===]      Secondary link
```

**Empty Slate** (Linear new workspace, Notion new page):
```text
[Single brand symbol]
"You don't have any X yet"
"X are great for Y."
[=== Create your first X ===]
```

Use Feature List for "here's what this product does" (3 screens max).
Use Hero Illustration for marketing pages. Use Empty Slate for in-app
first-run.

### 5. Button Hierarchy
- **Primary**: Filled with accent color, white text. One per page.
- **Secondary**: Outline / ghost in foreground color. Up to 3 per page.
- **Tertiary**: Text-only link in muted-foreground; underline on hover.
- **Destructive**: Filled destructive color, isolated by position
  (rightmost in dialogs, bottom of "Danger zone" sections), never
  primary on a page.

shadcn/ui Button variants line up: `default`, `outline`, `ghost`,
`link`, `destructive`. Use them; do not introduce new variants
unless you've fully redesigned the hierarchy.

### 6. Empty States Show Structure, Not Absence
When there's no data:

- Show the *skeleton* of what would be there (a dotted card outline,
  a faded sample row) so the user understands the shape
- Or show the *first step* (Linear's "Create your first issue")
- Never show "No data" alone

Stripe's empty payments table shows a faded sample row + arrow
pointing to "Test mode" + how to send a test payment. Educational
emptiness.

### 7. Glass-on-Gradient Detail Views
For high-craft detail screens (a deploy detail, a customer profile,
a release post):
```text
Layer 0: Full-bleed gradient or accent background
Layer 1: Frosted glass cards (backdrop-blur-xl bg-white/5 dark:bg-white/5)
Layer 2: Strong text contrast on the glass
```

Vercel's deploy detail does this (gradient + dashboard cards on glass).
Cash App's send/receive screen does this (gradient background + frosted
card with the amount).

Tailwind recipe:
```tsx
<div className="relative">
  <div className="absolute inset-0 bg-gradient-to-br from-violet-500/30 via-indigo-500/20 to-blue-500/30" />
  <div className="relative z-10 rounded-2xl backdrop-blur-xl bg-white/40 dark:bg-black/40 border border-white/10 p-6">
    {/* content */}
  </div>
</div>
```

### 8. Inline Data Enhancement
Instead of "View metrics →", Linear embeds a sparkline in the cycle
card. Instead of "See deploys →", Vercel embeds a heatmap of
deployments per day. The preview IS the data — no navigation needed
for first-level insight.

Use Tremor, Recharts, or hand-rolled SVG with `viewBox` to fit the
chart into a card. Keep them small (40-80px tall) — they're a hint,
not the destination.

### 9. Keyboard-First Power Patterns

The hallmark of a "Console" app is keyboard mastery:

- **Cmd+K palette** — every action discoverable by typing. Use cmdk
  (the library shadcn/ui ships) or kbar
- **Jump nav** — Cmd+1..9 for top-level sections
- **Vim-style row navigation** — j/k to move, Enter to open
- **Selection state** — keyboard arrows + Shift to multi-select

Linear is the gold standard. If you're building a Console app, ship
Cmd+K on day one.

```tsx
import { Command } from 'cmdk'

export function CommandPalette() {
  return (
    <Command.Dialog>
      <Command.Input placeholder="Type a command or search..." />
      <Command.List>
        <Command.Group heading="Actions">
          <Command.Item onSelect={() => createIssue()}>
            <Plus className="size-4" /> New issue
            <kbd className="ml-auto">⌘N</kbd>
          </Command.Item>
        </Command.Group>
        <Command.Group heading="Navigation">
          <Command.Item onSelect={() => router.push('/inbox')}>Inbox</Command.Item>
        </Command.Group>
      </Command.List>
    </Command.Dialog>
  )
}
```

### 10. Typography That Scans
Linear's issue list bolds the issue ID prefix (e.g., **ENG-1432**)
and leaves the title in regular weight. Stripe's customer list bolds
the email. Vercel's deploy list bolds the commit message. Each app
identifies the MOST LIKELY scan pattern of its content and uses font
weight to support it.

For your app: figure out what users scan FOR (a number, a name, a
status?) and bold that — let everything else be regular weight.

### 11. Dark Mode Is the Default for Console, Light for Editorial
Linear, Vercel, Sentry, Datadog, GitHub: default dark. The operator
mindset wants quiet chrome. Notion, Stripe Marketing, Substack:
default light. The editorial mindset wants paper.

Always ship both. Let users override. Use `next-themes` with
`defaultTheme="system"`.

### 12. Optimistic UI Is Visible Polish
The difference between Linear's "instant" feel and a typical CRUD
app is `useOptimistic`. Every interaction renders the expected
result on the next paint (16ms), then reconciles. The server round-
trip is hidden.

Use `useOptimistic` for:
- Toggling status (mark issue done, like post)
- Reordering (drag a row, drop in new position)
- Quick edits (rename inline, change priority)

```tsx
'use client'
import { useOptimistic } from 'react'

export function StatusToggle({ issue }: { issue: Issue }) {
  const [optimisticStatus, setStatus] = useOptimistic(issue.status)
  return (
    <button onClick={() => {
      const next = optimisticStatus === 'done' ? 'open' : 'done'
      setStatus(next)
      startTransition(() => updateStatusAction(issue.id, next))
    }}>
      {optimisticStatus === 'done' ? <CheckCircle2 className="text-success" /> : <Circle />}
    </button>
  )
}
```

## Measurements Reference (the de-facto standards)

| Element | Size | Tailwind | Notes |
|---------|------|----------|-------|
| Sidebar width | 240-280 px | `w-60` / `w-72` | Wider for long item names (Linear), narrower for icon-led (Vercel) |
| Top nav / header height | 56-64 px | `h-14` / `h-16` | h-14 for compact consoles, h-16 for editorial |
| Page content max-width | 1024-1280 px | `max-w-5xl` / `max-w-6xl` | 1280 for dashboards, 720 for prose |
| Card corner radius | 12-16 px | `rounded-xl` / `rounded-2xl` | rounded-xl is the safest default |
| Border color (light) | #e4e4e7 (zinc-200) | `border-border` | Use the token |
| Border color (dark) | #2a2a2a | `border-border` | Same token, different value |
| Input height | 36-44 px | `h-9` / `h-11` | h-11 for primary forms (touch targets), h-9 for dense filters |
| Button height | 32-40 px | `h-8` / `h-10` | h-10 default; h-8 for inline / row actions |
| Icon (in row) | 16 px | `size-4` | Default |
| Icon (button) | 20 px | `size-5` | Tap-target friendly |
| Avatar (row) | 32 px | `size-8` | List density |
| Avatar (header) | 40 px | `size-10` | Profile card |
| Avatar (detail) | 96-120 px | `size-24` / `size-28` | Profile poster |
| Stat card padding | 24 px | `p-6` | Standard dashboard card |
| Row vertical padding | 8-12 px | `py-2` / `py-3` | Density depends on context |
| List row min height | 44 px | `min-h-11` | WCAG touch-target — see [inter-touch-targets](../../experimental/web-rules/references/inter-touch-targets.md) |
| Hero number font | text-6xl - text-7xl | `text-6xl` / `text-7xl` | 60-72 px display values |
| Page heading font | text-2xl - text-3xl | `text-2xl tracking-tight` | Page H1s |
| Section heading font | text-sm font-medium uppercase | `text-sm font-medium text-muted-foreground tracking-wide uppercase` | Section labels |
| Body font | text-sm - text-base | `text-sm` | text-sm for dense, text-base for editorial |
| Code font | text-xs - text-sm mono | `font-mono text-xs` | IDs and code snippets |

## Apps to Study by Pattern

| If you're building... | Study | What to copy |
|----------------------|-------|--------------|
| Issue / ticket tracker | Linear, GitHub Issues | Sidebar nav, Cmd+K, status pills, in-place edit |
| Analytics / metrics | Tremor demos, Vercel Analytics, Stripe Dashboard | Hero number, sparkline, time-range selector |
| CRM / customers | Stripe Customers, Pipedrive | Sticky filters, dense table, drawer for detail |
| Settings | Linear, Stripe Account | Grouped sections, autosave, account switcher |
| Auth / sign-up | Vercel, Stripe, Clerk | Single-action page, social + email, no chrome |
| Editor / canvas | Notion, Linear, Figma | The page IS the editor, slash commands, comments in margin |
| Marketing site | Stripe, Vercel, Linear | Display typography, gradient hero, scroll-reveal |
| Payment / fintech | Stripe Checkout, Cash App | One number dominates, trust signals, single CTA |

## The Highest Form

The highest level of taste is when the chrome dissolves into the
content. Linear's issue page doesn't *show* an issue — it IS the
issue. Notion's page doesn't *contain* your writing — it IS your
writing. Stripe Checkout doesn't *frame* the transaction — the
transaction renders on plain trust-blue space.

This is the goal. Frames are a cost. The product is the moment when
the user forgets the UI exists and is just doing the thing.
