---
title: Empty States Explain Why and Offer the Next Action
impact: HIGH
impactDescription: Generic "no data" placeholders cause 40-60% bounce on first-run pages; structured empty states with a CTA convert 2-3× better
tags: feed, empty-states, first-run, no-results, onboarding
---

## Empty States Explain Why and Offer the Next Action

An empty state is not a missing UI — it's a moment with a job. There are three kinds: (1) first-run (the user has never created data), (2) no-results (search/filter returned nothing), (3) cleared (everything has been processed/dismissed). Each needs a different message and a primary action. Show the structure of what's missing — a skeleton, a sample preview, or the empty containers — not a generic "No data" line.

**Incorrect (generic "No data" with no path forward):**

```tsx
function Projects({ projects }: { projects: Project[] }) {
  if (projects.length === 0) {
    return <p className="text-center p-12">No projects.</p>
  }
  return <ProjectList projects={projects} />
}

function SearchResults({ q, results }: { q: string; results: Item[] }) {
  if (results.length === 0) return <p>No results.</p>
  return <Results items={results} />
}
```

**Correct (first-run vs no-results vs cleared, each with the right action):**

```tsx
import { FolderPlus, SearchX, CheckCircle2 } from 'lucide-react'

// 1. FIRST-RUN — describe the value + primary CTA
function ProjectsEmpty() {
  return (
    <div className="mx-auto max-w-md text-center p-12 space-y-4">
      <div className="mx-auto size-14 rounded-full bg-primary/10 flex items-center justify-center">
        <FolderPlus className="size-7 text-primary" aria-hidden="true" />
      </div>
      <div>
        <h2 className="text-lg font-semibold">Create your first project</h2>
        <p className="mt-1 text-sm text-muted-foreground">
          Projects organize your work and let you invite collaborators.
        </p>
      </div>
      <Button asChild>
        <Link href="/projects/new">New project</Link>
      </Button>
    </div>
  )
}

// 2. NO-RESULTS — what was searched + how to broaden
function SearchEmpty({ query }: { query: string }) {
  return (
    <div className="mx-auto max-w-md text-center p-12 space-y-4">
      <SearchX className="mx-auto size-10 text-muted-foreground" aria-hidden="true" />
      <div>
        <h2 className="text-lg font-semibold">No matches for "{query}"</h2>
        <p className="mt-1 text-sm text-muted-foreground">
          Check the spelling or try a shorter search.
        </p>
      </div>
      <Button variant="outline" asChild>
        <Link href="?">Clear search</Link>
      </Button>
    </div>
  )
}

// 3. CLEARED — celebrate, and offer the next sensible action
function InboxCleared() {
  return (
    <div className="mx-auto max-w-md text-center p-12 space-y-4">
      <CheckCircle2 className="mx-auto size-10 text-success" aria-hidden="true" />
      <h2 className="text-lg font-semibold">Inbox zero</h2>
      <p className="text-sm text-muted-foreground">Nothing left to handle. Nice work.</p>
      <Button variant="ghost" size="sm" asChild>
        <Link href="/archive">View archived</Link>
      </Button>
    </div>
  )
}
```

**Rule:**
- Choose the right type: first-run (explain value + CTA), no-results (refine query), cleared (celebrate + next destination)
- Icon + heading + 1-2 sentences + primary action — in that order
- Heading is a noun or imperative ("Create your first project"), not a negation ("No data")
- The primary CTA does the most likely next thing; secondary CTA (if any) gives an alternate path
- Use the success icon for "cleared", a muted icon for "no results", and the primary color icon for "first-run"

Reference: [Empty states UX — NN/g](https://www.nngroup.com/articles/empty-state-interface-design/)
