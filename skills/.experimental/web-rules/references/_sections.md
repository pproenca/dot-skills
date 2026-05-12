# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Navigation (nav)

**Impact:** CRITICAL
**Description:** Primary navigation, App Router structure, and page-action placement define how users move through your app. Navigation is the most fundamental UX topic — getting it wrong makes every screen harder to reach. In Next.js 16 the App Router shapes the entire app's mental model.

## 2. Interaction Design (inter)

**Impact:** CRITICAL
**Description:** Pointer/touch targets, keyboard navigation, microinteractions, drag-and-drop, revalidation, row actions, and search define how users physically interact with your app. Getting these wrong breaks the platform feel and locks out keyboard and touch users.

## 3. Accessibility (acc)

**Impact:** CRITICAL
**Description:** Labels, text scaling, color contrast, reduced motion, focus management, relative units, and responsive layout are not optional. WCAG 2.2 AA is the legal baseline in the EU (EAA, June 2025) and many US states. Failing accessibility excludes 20%+ of users.

## 4. User Feedback (feed)

**Impact:** HIGH
**Description:** Loading states (Suspense + loading.tsx), error states (error.tsx + boundaries), toast notifications, success confirmation, and empty states communicate system status. With Server Components streaming, feedback quality determines perceived performance.

## 5. UX Patterns (ux)

**Impact:** HIGH
**Description:** Onboarding, permission requests, modality (dialog/popover/sheet), destructive confirmation, data entry with Server Actions, undo, and settings organization follow established web patterns. Diverging from them costs users — even when the divergence is technically "better."

## 6. Visual Design (vis)

**Impact:** HIGH
**Description:** Dark mode (Tailwind `dark:` + `prefers-color-scheme`), icon system (lucide-react sizing and stroke conventions), and spacing (Tailwind's 4pt scale and container queries) ensure your app looks native to the modern web and adapts to all viewports and themes.
