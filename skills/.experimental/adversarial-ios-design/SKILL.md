---
name: adversarial-ios-design
description: Use this skill to gate iOS SwiftUI design and UX with a pass/fail adversarial review — two blind reviewers independently judge screens, diffs, or features against 55 decidable HIG-derived rules — navigation and IA (tab bars over drawers, five tabs max, a stack per tab, system Back button, search affordances), modality and flow grammar (sheets for self-contained tasks, Cancel/Done placement, unsaved-content protection, alert and confirmation discipline, onboarding and settings restraint), layout (44pt targets, safe areas, Dynamic Type cages, concentric corners), color and contrast (system backgrounds, label ladder, WCAG floors, dark variants, scrims), typography floors, Liquid Glass placement, feedback states (empty, loading, error, launch), motion (springs, bounce caps, Reduce Motion, zoom transitions), haptics, and craft. Trigger before merging user-facing SwiftUI work or to audit a screen for Apple-designer polish. Verdicts only, never fixes; targets without a SwiftUI UI surface abort.
---

# Adversarial iOS Design Gate

An iOS design-and-UX review gate — pass/fail: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The rules are the decidable subset of what an Apple design review would flag — every rule names the evidence that decides it, drawn from the Human Interface Guidelines, WWDC design sessions, and Apple's own measured app conventions. The gate judges the failure modes agents and experienced-but-not-expert developers actually ship: hamburger drawers where tab bars belong, pushed forms that lose drafts on a swipe, alerts that say "Yes"/"No", blank empty states, whole-screen spinners, teleporting state changes, glass painted on content, and text that clips at accessibility sizes.

## When to Apply

- A user-facing SwiftUI screen, feature, or PR is about to merge and needs an objective PASS/FAIL on design and UX quality, not advisory feedback.
- An agent (Claude, Codex) authored the UI and you want an independent check that it follows platform grammar — modality, navigation structure, alert discipline, feedback states — rather than web/Android idioms translated into Swift.
- A screen "works" but feels non-native, and you want the decidable causes enumerated with locations instead of taste adjectives.
- A design polish pass claims Apple-level quality and you want that claim tested against HIG-derived evidence, optionally with light/dark simulator screenshots unlocking the rendered-evidence rule legs.

Do not apply to targets with no SwiftUI user-interface surface — server-side Swift, CLI tools, non-UI packages (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"). SwiftUI architecture and update mechanics (observation, view identity, task lifecycle, list construction) are the sibling `adversarial-swift-ui` gate's job; Swift language quality is `adversarial-swift`'s. Taste judgments this gate cannot decide (hero scale, emotional intent, composition) belong to `ios-taste` — the exclusion list is in [gotchas.md](gotchas.md). Rules whose remedy needs a newer deployment target than the project's are N/A, not FAIL — the reviewer prompt carries the version-gate table.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR, one screen or a whole flow) and note the ref/paths so both reviewers see the same thing. Record the Swift toolchain and minimum deployment target — several rules version-gate on them. Include the repo root — `nav-stack-per-tab`, `flow-onboarding-optional`, and `state-launch-screen-replica` can require reading the App entry point, Info.plist, and asset catalogs beyond the diff hunks. Collect light and dark simulator screenshots of the affected screens if available — they unlock the screenshot-dependent rule legs; without them those legs go N/A, never PASS.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `nav-*.md`, `flow-*.md`, `layout-*.md`, `color-*.md`, `type-*.md`, `glass-*.md`, `state-*.md`, `motion-*.md`, `haptic-*.md`, `craft-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, the toolchain/deployment facts, and the screenshot paths (or "none"). The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (no SwiftUI UI surface), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line`, a quote, or a named screenshot region — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Navigation & Information Architecture | `nav-` | TabView over drawers/button grids, tabs navigate not act, ≤5 tabs, stable tab bar, one NavigationStack per tab, system Back button, a title on every screen, search via system affordances |
| 2 | Modality & Flow Grammar | `flow-` | Sheets for self-contained tasks, Cancel leading/Done trailing, dirty-sheet dismiss protection, fullScreenCover for media/multistep only, one sheet at a time, actionable-only alerts with verb buttons, confirmationDialog for intentional destruction, no confirmations on undoable deletes, optional onboarding with in-context permissions, minimal in-context settings |
| 3 | Layout & Visual Hierarchy | `layout-` | 44×44 pt hit targets with clearance, buttons inset from edges, backgrounds bleed while content respects safe areas, no fixed-height cages on Dynamic Type text, concentric nested corner radii |
| 4 | Color & Contrast | `color-` | System background colors, semantic label ladder, semantic roles kept, numeric contrast floors, never state by color alone, dark variants for custom colors and images, legibility layers between text and imagery |
| 5 | Typography | `type-` | 11 pt minimum, no Ultralight/Thin/Light UI text, title-style section headers |
| 6 | Materials & Liquid Glass | `glass-` | Glass only in the floating layer and never glass-on-glass, one tinted action per bar, no paint behind bars or mixed scroll-edge styles |
| 7 | Feedback States | `state-` | Designed empty states, skeletons over whole-screen spinners, determinate progress without vague labels, error states with cause and recovery, chrome-only launch screen replica |
| 8 | Motion | `motion-` | Animated structural changes, springs over ease curves, bounce ≤0.4 on chrome, brief interaction feedback, Reduce Motion paths, zoom transitions for originating content |
| 9 | Haptics | `haptic-` | Success/error haptics on significant outcomes, no spam triggers, documented pattern meanings, no doubling on standard controls |
| 10 | Craft | `craft-` | Numeric text transitions on fixed-width digits, SF Symbols sized via text APIs with matched weights/variants, no appearance lock |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching reviewers — it pre-records rule-fidelity guards (the sibling-gate boundary on font/color literals, the two-directional delete-confirmation rule, the absence of any single-accent rule), threshold provenance (the derived 0.5 s motion cap), the screenshot evidence protocol, and the judgment calls this gate deliberately excludes.

## Related Skills

- `adversarial-swift-ui` — the sibling gate for SwiftUI architecture and update mechanics (observation, identity, task lifecycle, lists, animation scope); run both on user-facing SwiftUI work.
- `adversarial-swift` — the sibling gate for Swift language concerns on mixed work.
- `ios-taste` (curated) — the judgment-call design guidance this gate deliberately excludes; use it to *design* the screen, then this gate to *verify* the decidable layer.
- `design-review` (curated) — the advisory web-UI counterpart of this gate's lens.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer, with version gating and the screenshot protocol |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
