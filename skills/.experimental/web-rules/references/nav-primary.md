---
title: Use Top Nav or Sidebar for Primary Navigation; Never Hamburger-Only on Desktop
impact: CRITICAL
impactDescription: Hidden-by-default desktop navigation reduces feature discovery by ~50% (NN/g) and cuts engagement with secondary sections by 30-40%
tags: nav, primary-navigation, sidebar, top-nav, mobile-drawer
---

## Use Top Nav or Sidebar for Primary Navigation; Never Hamburger-Only on Desktop

Top-level sections must be visible at viewports ≥ 768 px. Use a top nav for 3-7 sections and a sidebar when there are 5+ sections or deep nesting. A hamburger menu may collapse the same navigation on mobile (`< 768 px`) — never on desktop. Each top-level destination is a noun, not a verb (sections, not actions).

**Incorrect (hamburger-only on desktop, actions mixed in):**

```tsx
// app/(marketing)/layout.tsx
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <header className="flex items-center justify-between p-4">
        <Logo />
        <button onClick={() => setOpen(true)} aria-label="Menu">
          <Menu />
        </button>
        {/* Desktop also has to open a drawer to see sections — kills discovery */}
      </header>
      {children}
    </>
  )
}
```

**Correct (visible top nav at desktop, drawer at mobile, no actions in nav):**

```tsx
// app/(marketing)/layout.tsx
import Link from 'next/link'

const sections = [
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/projects', label: 'Projects' },
  { href: '/team', label: 'Team' },
  { href: '/billing', label: 'Billing' },
]

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <header className="flex items-center gap-8 px-6 h-14 border-b">
        <Logo />
        <nav aria-label="Primary" className="hidden md:flex gap-6">
          {sections.map((s) => (
            <Link key={s.href} href={s.href} className="text-sm hover:text-foreground/80">
              {s.label}
            </Link>
          ))}
        </nav>
        <MobileNavDrawer sections={sections} className="md:hidden ml-auto" />
      </header>
      {children}
    </>
  )
}
```

**Rule:**
- Maximum 7 top-level sections; if you have more, switch to a sidebar
- Each section is a destination (noun), never an action — "New Project" belongs in the page, not the nav
- `aria-label="Primary"` on the nav element so screen-reader users hear the navigation landmark
- Use `next/link`, not `<a href>`, for internal navigation — App Router prefetching kicks in
- Mobile drawer is allowed at `< 768 px` only

Reference: [Hamburger menus and hidden navigation hurt UX metrics — Nielsen Norman Group](https://www.nngroup.com/articles/hamburger-menus/)
