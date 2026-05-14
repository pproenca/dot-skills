# Web Taste — Code Examples & Component Palette

Concrete before/after examples and the component-choice reference table.
Pulled out of `SKILL.md` to keep the main skill lean.

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
| `<Button>Save</Button>` | Autosave with optimistic UI (see [ux-settings](../../../experimental/web-rules/references/ux-settings.md)) |
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
