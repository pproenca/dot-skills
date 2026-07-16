# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Navigation & Information Architecture (nav)

**Description:** The structural skeleton a user navigates — tab bars over hand-rolled drawers, tabs that navigate rather than act, a stable tab bar with at most five entries, one navigation stack per tab, the system Back button, a title on every screen, and search surfaced through the system affordances. These decisions are the most expensive to get wrong because every other screen inherits them; a drawer where a tab bar belongs or a shared stack across tabs makes the whole app feel foreign to iOS regardless of how polished individual screens are.

## 2. Modality & Flow Grammar (flow)

**Description:** How tasks enter and leave the screen — self-contained tasks as sheets with Cancel/Done affordances, unsaved-content protection on interactive dismiss, fullScreenCover reserved for immersive content, one sheet at a time, alerts reserved for actionable problems with verb-labeled buttons, confirmation dialogs anchored to the destructive action that triggered them, no confirmations on routine undoable deletes, onboarding that is optional, and settings that stay minimal and in context. Modality grammar is the difference between an app that respects the user's work and one that silently discards a draft on a swipe.

## 3. Layout & Visual Hierarchy (layout)

**Description:** The geometry of the screen — hit targets at 44×44 points with clearance between adjacent controls, buttons inset from the display edges, backgrounds that bleed edge-to-edge while text and controls respect the safe areas, no fixed-height cages around Dynamic Type text, and nested corner radii that stay concentric with their container. These are the physical failures: too-small targets are unusable, clipped text is illegible at accessibility sizes, and clashing corner geometry reads instantly as non-native.

## 4. Color & Contrast (color)

**Description:** How color carries structure and survives every appearance — system background colors instead of pure white/black or brand fills, the semantic label ladder for text hierarchy instead of ad-hoc grays, semantic colors kept to their defined roles, numeric contrast floors (4.5:1 for text up to 17 pt, 3:1 at 18 pt or bold), state never conveyed by color alone, custom colors and full-color images with dark-appearance variants, and a legibility layer between text and the imagery beneath it. Color failures are invisible on the author's device and glaring on everyone else's.

## 5. Typography (type)

**Description:** The floors and conventions of the type system this gate can decide from evidence — no user-visible text below 11 points, no Ultralight/Thin/Light weights on UI text, and title-style capitalization for section headers per the iOS 26 convention. Type-role and hierarchy judgment stays with a taste skill; these three checks are the ones that are simply wrong, not merely debatable.

## 6. Materials & Liquid Glass (glass)

**Description:** Where the system material may live — Liquid Glass only in the floating controls-and-navigation layer, never on content or stacked glass-on-glass; at most one tinted prominent action per bar; and no custom paint behind bars or mixed scroll-edge-effect styles that defeat the system's own legibility treatments. Misplaced glass is the fastest way for an iOS 26 app to look like it misunderstood the design system it adopted.

## 7. Feedback States (state)

**Description:** What the screen shows when the happy path isn't available — a designed empty state instead of a blank list, skeleton placeholders instead of a whole-screen spinner, determinate progress when the work is measurable and no vague "Loading…" labels, error states that explain the cause and offer a recovery action, and a launch screen that is a chrome-only replica of the first screen. Users meet these states constantly; an app with beautiful content and blank empty states was designed for the demo, not the user.

## 8. Motion (motion)

**Description:** Whether change on screen moves the way iOS moves — visible structural changes animated rather than teleporting, springs instead of ease curves for movement, bounce capped where the element is interface chrome, brief feedback on direct interaction, a Reduce Motion path for large or repeating custom animation, and zoom transitions when detail content visibly originates from a tapped element. Motion is where an otherwise-correct screen most often feels wrong in the hand.

## 9. Haptics (haptic)

**Description:** Touch feedback used the way the system means it — success/error notification haptics on the outcomes the app itself celebrates or mourns, no haptics on high-frequency or trivial triggers, system patterns kept to their documented meanings, and no doubled haptics on standard controls that already play their own. Haptics are asymmetric: absence on a significant outcome is a missed signal, presence on every tap is noise the user turns off.

## 10. Craft (craft)

**Description:** The small mechanical details reviewers can check that separate shipped-by-Apple from almost — changing numbers animated with numeric text transitions on fixed-width digits, SF Symbols sized through the text APIs with weights and variants matched to context, and no forced color scheme or in-app appearance switch overriding the user's systemwide choice.
