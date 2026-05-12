---
name: web-rules
description: Strict design and UX rules for React 19 + Next.js 16 (App Router) + Tailwind CSS 4. Covers navigation, interaction design, accessibility, user feedback, UX patterns, and visual design. Use when designing, building, or reviewing any user-facing web feature on this stack. Trigger when the user asks to "build a settings page", "add a dialog", "design this form", "review for accessibility", "fix dark mode", or any Next.js App Router / React 19 / Tailwind UI task. Also trigger when the user says output "looks off", "isn't accessible", or "doesn't follow best practices."
---

# React 19 + Next.js 16 + Tailwind CSS Best Practices

Comprehensive strict-rules reference for web apps built on React 19, the Next.js 16 App Router, and Tailwind CSS 4. Contains 34 rules across 6 categories. Each rule is stated as an Always/Never directive with a quantified impact, an incorrect example, and a correct example.

## Stack Contract

All guidance assumes:

- **React 19** with Server Components by default; Client Components only when interactivity is required (`'use client'` at the top)
- **Next.js 16 App Router** with `app/` directory, `layout.tsx`, `page.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, parallel routes, intercepting routes
- **Server Actions** for mutations (`'use server'`) — never `useEffect` for data fetching
- **Tailwind CSS 4** with the `@theme` directive, `dark:` variant, container queries, and the standard 4pt spacing scale
- **lucide-react** as the canonical icon system
- **No CSS-in-JS** (no styled-components, no emotion) — Tailwind utility classes only, with `cn()` from `clsx` + `tailwind-merge` for conditional classes
- **shadcn/ui primitives** (Radix-based) preferred for dialogs, popovers, dropdowns, tooltips, toasts

## When to Apply

Reference these rules when:

- Building any user-facing route, layout, or component
- Reviewing PRs for design / UX / accessibility regressions
- Choosing between modality types (dialog vs popover vs full-page)
- Implementing forms with Server Actions and `useFormState` / `useOptimistic`
- Configuring loading and error boundaries
- Designing onboarding, permissions, or settings flows
- Ensuring dark mode, focus management, and keyboard navigation work end-to-end

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Navigation | CRITICAL | `nav-` |
| 2 | Interaction Design | CRITICAL | `inter-` |
| 3 | Accessibility | CRITICAL | `acc-` |
| 4 | User Feedback | HIGH | `feed-` |
| 5 | UX Patterns | HIGH | `ux-` |
| 6 | Visual Design | HIGH | `vis-` |

## Quick Reference

### 1. Navigation (CRITICAL)

- [`nav-primary`](references/nav-primary.md) - Use top nav (3-7 sections) or sidebar; never hamburger-only on desktop
- [`nav-app-router`](references/nav-app-router.md) - Use App Router layouts, parallel routes, and `<Link>` for all internal navigation
- [`nav-page-actions`](references/nav-page-actions.md) - Place primary actions in the page header; never bury them in scroll

### 2. Interaction Design (CRITICAL)

- [`inter-touch-targets`](references/inter-touch-targets.md) - 44×44 px minimum touch target (WCAG 2.5.5)
- [`inter-pointer-patterns`](references/inter-pointer-patterns.md) - Use standard hover/click/long-press patterns; never invent new ones
- [`inter-microinteractions`](references/inter-microinteractions.md) - Always confirm interaction with visual feedback within 100ms
- [`inter-keyboard-navigation`](references/inter-keyboard-navigation.md) - Every interactive element must be reachable and operable by keyboard
- [`inter-drag-drop`](references/inter-drag-drop.md) - Provide a keyboard-accessible alternative whenever drag is offered
- [`inter-revalidation`](references/inter-revalidation.md) - Use `revalidatePath`/`revalidateTag` after mutations; never rely on client refresh
- [`inter-row-actions`](references/inter-row-actions.md) - Use a single "row action" pattern per list (kebab menu OR hover actions OR swipe)
- [`inter-search`](references/inter-search.md) - Debounce search input by 200-300ms and reflect query in the URL

### 3. Accessibility (CRITICAL)

- [`acc-labels`](references/acc-labels.md) - Every interactive element has an accessible name
- [`acc-text-scaling`](references/acc-text-scaling.md) - All text scales to 200% browser zoom without horizontal scroll
- [`acc-color-contrast`](references/acc-color-contrast.md) - WCAG AA: 4.5:1 body text, 3:1 large/UI
- [`acc-reduce-motion`](references/acc-reduce-motion.md) - Respect `prefers-reduced-motion: reduce`
- [`acc-color-independent`](references/acc-color-independent.md) - Never rely on color alone to convey meaning
- [`acc-focus-management`](references/acc-focus-management.md) - Always render a visible focus ring; trap focus inside modals
- [`acc-relative-units`](references/acc-relative-units.md) - Use `rem` for text and spacing; never fix text size in `px`
- [`acc-responsive-layout`](references/acc-responsive-layout.md) - Every layout works at 320 px width without horizontal scroll

### 4. User Feedback (HIGH)

- [`feed-loading-states`](references/feed-loading-states.md) - Always use `loading.tsx` or `<Suspense>` with a skeleton matching final layout
- [`feed-error-states`](references/feed-error-states.md) - Every route segment has `error.tsx` with a Try-Again action
- [`feed-toasts`](references/feed-toasts.md) - Use toasts only for confirmations of non-blocking actions
- [`feed-success-confirmation`](references/feed-success-confirmation.md) - Confirm every destructive or irreversible action with explicit visible feedback
- [`feed-empty-states`](references/feed-empty-states.md) - Empty states explain why and offer the next action

### 5. UX Patterns (HIGH)

- [`ux-onboarding`](references/ux-onboarding.md) - Onboarding never exceeds 3 screens; always skippable
- [`ux-permissions`](references/ux-permissions.md) - Request browser permissions in-context, not on page load
- [`ux-modality`](references/ux-modality.md) - Choose dialog / popover / full-page by content weight; never stack modals
- [`ux-destructive-confirmation`](references/ux-destructive-confirmation.md) - Destructive actions require a typed confirmation OR an undo window
- [`ux-data-entry`](references/ux-data-entry.md) - Use Server Actions + progressive enhancement; never disable submit while typing
- [`ux-undo`](references/ux-undo.md) - Prefer undo over confirmation for everyday actions
- [`ux-settings`](references/ux-settings.md) - Settings are autosaved on change; never gated behind a Save button

### 6. Visual Design (HIGH)

- [`vis-dark-mode`](references/vis-dark-mode.md) - Use CSS custom properties + `dark:` variant; never hardcode `text-black`/`bg-white`
- [`vis-icon-system`](references/vis-icon-system.md) - Use lucide-react with `1.5px` stroke and `size-4`/`size-5` standard sizes
- [`vis-spacing`](references/vis-spacing.md) - Use the Tailwind 4 pt scale and container queries; never use ad-hoc `px` margins

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
