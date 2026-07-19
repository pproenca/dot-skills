---
name: adversarial-ios-design
description: Use this skill to gate iOS SwiftUI design and UX with a pass/fail adversarial review — a single blind reviewer subagent judges screens, diffs, or features against 56 decidable HIG-derived rules, working backwards from mandatory rendered evidence, simulator screenshots (light, dark, accessibility text size) and interaction recordings tiled into filmstrips. Covers navigation/IA (tab bars, five tabs max, system Back), modality and flow grammar (sheets, alerts, unsaved-content protection), layout (44pt targets, safe areas, Dynamic Type), color and contrast, typography floors, Liquid Glass, feedback states (empty, loading, error, launch), motion — filmstrip-primary except the spring-curve and Reduce Motion checks, so code alone never prescribes an unseen animation, and gratuitous decoration fails — plus haptics and craft. Fixes must be the minimal change, removal preferred over addition. Trigger before merging user-facing SwiftUI work. Verdicts only, never fixes; targets without a SwiftUI UI surface abort.
---

# Adversarial iOS Design Gate

An iOS design-and-UX review gate — pass/fail: a single blind reviewer subagent judges the work against this gate's rules with an adversarial mandate, and the work passes only when every rule is PASS or N/A. This skill renders verdicts; it never fixes the work.

The gate judges rendered user interface, not source text. Capturing evidence — simulator screenshots and interaction recordings tiled into filmstrips — is a mandatory protocol step, and the reviewer works backwards from the pixels: observe the captures, suspect violations, then open code only to locate them. Code-only review is the gate's recorded failure mode: it turns the gate into a linter that prescribes animations it has never seen.

The rules are the decidable subset of what an Apple design review would flag — every rule names the evidence that decides it, drawn from the Human Interface Guidelines, WWDC design sessions, and Apple's own measured app conventions. The gate judges the failure modes agents and experienced-but-not-expert developers actually ship: hamburger drawers where tab bars belong, pushed forms that lose drafts on a swipe, alerts that say "Yes"/"No", blank empty states, whole-screen spinners, teleporting state changes, glass painted on content, and text that clips at accessibility sizes.

## When to Apply

- A user-facing SwiftUI screen, feature, or PR is about to merge and needs an objective PASS/FAIL on design and UX quality, not advisory feedback.
- An agent (Claude, Codex) authored the UI and you want an independent check that it follows platform grammar — modality, navigation structure, alert discipline, feedback states — rather than web/Android idioms translated into Swift.
- A screen "works" but feels non-native, and you want the decidable causes enumerated with locations instead of taste adjectives.
- A design polish pass claims Apple-level quality and you want that claim tested against what the screen actually renders — screenshots and filmstrips — not against what the code implies.
- A previous "polish" or gate-driven fix round made the UI busier — added animations, haptics, or decoration — and you want the restraint direction enforced: gratuitous motion fails, and every fix must be the minimal change with removal preferred over addition.
- The diff changes gestures or interaction behavior (recognizers, drag/long-press/resize, custom `ButtonStyle`/`PrimitiveButtonStyle` implementations) — run this gate, with its capture protocol, **before** the sibling architecture gates: recognizer arbitration is invisible to code-only review, a single clean trial is not evidence (see the repeated-trials requirement in [references/_evidence-capture.md](references/_evidence-capture.md)), and sequencing this gate last is how interaction regressions ship looking reviewed.

Do not apply to targets with no SwiftUI user-interface surface — server-side Swift, CLI tools, non-UI packages (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"). SwiftUI architecture and update mechanics (observation, view identity, task lifecycle, list construction) are the sibling `adversarial-swift-ui` gate's job; Swift language quality is `adversarial-swift`'s. Taste judgments this gate cannot decide (hero scale, emotional intent, composition) belong to `ios-taste` — the exclusion list is in [gotchas.md](gotchas.md). Rules whose remedy needs a newer deployment target than the project's are N/A, not FAIL — the reviewer prompt carries the version-gate table.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

Two preconditions before step 1 — both exist because their violation is the gate family's recorded field-failure mode (July 2026: gates run as cleanup drivers on a moving target rendered zero verdicts while the diff grew to 33 files):

- **Frozen target.** Dispatch only against a fixed ref — a commit SHA, stash, or saved diff — recorded as the target manifest. If the code under review is still changing (the worktree keeps collecting edits, other agents are active on it), do not dispatch. A target change while the reviewer is in flight voids the run: report `GATE VOID — target changed` in place of a verdict and re-dispatch against the new frozen state. A dispatched gate must always end in a rendered verdict, a `GATE NOT APPLICABLE`, or a recorded void — never silence, which is indistinguishable from "reviewed".
- **Verdicts, not cleanup.** This gate is a terminal check on finished work. "Run the gate and fix everything aggressively" inverts the contract and is the documented path to scope explosion: implement first, freeze, then gate. After a FAIL, the caller applies fixes within the original target only, and the re-gate dispatches a fresh blind reviewer against the **same target manifest** — the surface never widens between rounds; new code means a new gate invocation with its own manifest.

When other agents may mutate the workspace mid-review, the reviewer reads the rules from an immutable snapshot (e.g. `git archive <ref> <skill-dir> | tar -x -C "$TMPDIR"`) rather than the live checkout — and skill directories are read-only infrastructure, excluded from every cleanup or fix scope.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR, one screen or a whole flow) and note the ref/paths so the review runs against an unambiguous, fixed target. Record the Swift toolchain and minimum deployment target — several rules version-gate on them. Include the repo root — `nav-stack-per-tab`, `flow-onboarding-optional`, and `state-launch-screen-replica` can require reading the App entry point, Info.plist, and asset catalogs beyond the diff hunks.
2. **Capture rendered evidence.** Follow [references/_evidence-capture.md](references/_evidence-capture.md): preflight capture capability first (boot the simulator, take one throwaway screenshot — if that fails, record the named blocker now, not hours into the review), then build and run the target in the simulator, capture light, dark, and accessibility-size screenshots of every affected screen, and record every structure-mutating interaction into 10 fps filmstrips, plus a short idle recording per primary screen. Gesture-bearing interactions need at least 3 consecutive recorded trials in one app session — a single clean run is not evidence for recognizer arbitration. This step is mandatory — skip it only for a named blocker (the project does not build, no simulator runtime, screens unreachable without credentials), recorded in the verdict header. Without captures, screenshot-dependent legs go N/A and motion rules can only report candidates — never FAIL, never PASS.
3. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `nav-*.md`, `flow-*.md`, `layout-*.md`, `color-*.md`, `type-*.md`, `glass-*.md`, `state-*.md`, `motion-*.md`, `haptic-*.md`, `craft-*.md` files).
4. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, the toolchain/deployment facts, and the absolute screenshot, recording, and filmstrip paths (or the named capture blocker). The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
5. **Dispatch one blind reviewer.** Launch a single Task subagent whose entire input is the composed prompt — no conversation context, no commentary alongside it.
6. **Render fail-closed.** The reviewer's structured output is the verdict — there is no merge step. Overall verdict is PASS only when every rule is PASS or N/A; any single FAIL fails the gate. Never average, weigh severity, or waive a rule — a "minor" FAIL is a FAIL. If the reviewer returns "GATE NOT APPLICABLE" (no SwiftUI UI surface), stop and report that instead of a verdict.
7. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate the reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose final result is FAIL must appear in the fix list with a change concrete enough to apply as written — if the reviewer's suggestion only restates the violation, derive the fix from the rule's Correct example before rendering. Enforce the minimality test on every fix before rendering: the smallest change that flips its rule, removal preferred over addition, and nothing added — no animations, haptics, views, state, or abstractions — beyond the rule's named remedy. The fix list is verification material — proof that each FAIL is decidable and flippable — not a work queue: fixes stay inside the declared target, and violations the reviewer noticed outside the target manifest go under the verdict's out-of-scope observations — reported for a future gate invocation, never fixed under this one, never counted in the verdict.

If the same rule flips verdicts across re-reviews of an unchanged target, or a human reads the evidence and overrides the verdict, that is a decidability bug in the rule — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

The reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line`, a quote, or a named screenshot region — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

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
| 8 | Motion | `motion-` | Recording-primary: filmstrips decide teleports, over-long feedback, chrome overshoot, slide-instead-of-zoom, and gratuitous decoration; springs over ease curves and Reduce Motion paths stay code-decidable — code alone otherwise only nominates candidates |
| 9 | Haptics | `haptic-` | Success/error haptics on significant outcomes, no spam triggers, documented pattern meanings, no doubling on standard controls |
| 10 | Craft | `craft-` | Numeric text transitions on fixed-width digits, SF Symbols sized via text APIs with matched weights/variants, no appearance lock |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching the reviewer — it pre-records rule-fidelity guards (the sibling-gate boundary on font/color literals, the two-directional delete-confirmation rule, the absence of any single-accent rule), threshold provenance (the derived 0.5 s motion cap), the screenshot evidence protocol, and the judgment calls this gate deliberately excludes.

## Related Skills

- `adversarial-swift-ui` — the sibling gate for SwiftUI architecture and update mechanics (observation, identity, task lifecycle, lists, animation scope); run both on user-facing SwiftUI work, this gate first when the diff touches gestures or interaction behavior.
- `adversarial-swift` — the sibling gate for Swift language concerns on mixed work.
- `ios-taste` (curated) — the judgment-call design guidance this gate deliberately excludes; use it to *design* the screen, then this gate to *verify* the decidable layer.
- `design-review` (curated) — the advisory web-UI counterpart of this gate's lens.

## Reference Files

| File | Description |
|------|-------------|
| [references/_evidence-capture.md](references/_evidence-capture.md) | Mandatory capture protocol: simulator screenshots, interaction recordings, ffmpeg filmstrips, and how to read them |
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for the blind reviewer, with version gating, the pixels-before-code review order, and the capture protocol |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
