---
title: Document Design System Boundaries in a Living ADR
impact: LOW-MEDIUM
impactDescription: prevents scope creep and "why don't we have X?" questions
tags: org, documentation, adr, decisions
---

## Document Design System Boundaries in a Living ADR

Without explicit boundaries, a Rails design system either grows to absorb everything (becoming an over-engineered framework) or stays unclear enough that developers build around it. A short Architecture Decision Record (ADR) states what is in the design system, what is explicitly out of scope, and why. This prevents the same debates from recurring every quarter.

**Incorrect (no documentation -- everyone has a different mental model):**

```text
Developer A: "Why don't we have a DatePicker component?"
Developer B: "I thought we were using ViewComponent for everything?"
Developer C: "Are we supposed to use the FormBuilder or write custom markup?"
Lead: "I'll answer these questions... again... for the fourth time..."
```

**Correct (a living ADR that answers boundary questions):**

```markdown
# ADR: Design System Scope and Boundaries

**Status:** Active
**Last updated:** 2024-11-15
**Authors:** Team consensus (sprint retro 2024-11-12)

## What We Use

| Layer | Tool | Count |
|-------|------|-------|
| Form fields | `DesignSystemFormBuilder` | 1 builder, 8 field types |
| Shared partials | `app/views/shared/` | 12 partials |
| Stimulus controllers | `app/javascript/controllers/` | 6 custom + 4 from stimulus-components |
| View helpers | Resource-scoped helpers | 5 helper modules |
| Design tokens | Tailwind theme config | Colors, spacing, typography |

## What We Explicitly Do NOT Use

| Decision | Why |
|----------|-----|
| ViewComponent gem | Partials + helpers are sufficient at our scale (~40 views). Revisit at 100+ views. |
| Storybook / Lookbook | Not worth the maintenance cost for < 15 shared components. |
| Design token pipeline (Style Dictionary) | Tailwind config is our single source of truth. No need for a build step. |
| Component library gem | We are not building a reusable library. This is app-specific. |
| Custom CSS framework | Tailwind covers our needs. Custom CSS is limited to tokens and overrides. |

## When to Revisit

- **Add ViewComponent** when shared partials exceed 20 or when we need preview/testing isolation
- **Add Lookbook** when the team exceeds 5 frontend contributors
- **Add token pipeline** when we need to share tokens between Rails and a mobile app

## Principles

1. Extract after duplication, not before
2. Prefer Rails conventions over custom abstractions
3. Every addition must reduce total code, not add a new layer
4. If you can solve it with a partial + helper, do that first
```

Keep this document in one of these locations:
- `docs/adr/design-system-scope.md` (if you use ADR format)
- `ARCHITECTURE.md` in the project root (if you prefer a single file)
- A wiki page linked from the README (if your team uses a wiki)

Update the ADR when:
- A new tool is adopted (e.g., adding ViewComponent)
- A pattern is deprecated (e.g., moving from partials to components)
- The team size or codebase size crosses a threshold listed in "When to Revisit"

The document should stay under 30 lines of content (excluding the table). If it needs more, the design system might be over-scoped.

Reference: [Architectural Decision Records](https://adr.github.io/)
