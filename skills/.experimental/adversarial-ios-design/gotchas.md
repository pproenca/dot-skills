# Gotchas

## Field failure: code-only dispatch turned the gate into an animation generator

The gate was dispatched on real work with no captures. Every screenshot-dependent leg
went N/A, everything else was decided from code, and the motion FAILs — decided from
the mere absence of `withAnimation` — produced a fix list that sprayed animations
across the codebase: a busier UI, slower and uglier code, zero design improvement, and
no fix ever proposed *removing* anything. The v0.2.0 redesign is the response, and its
four legs stand together — do not weaken one on evolve:

1. Evidence capture is a mandatory protocol step ([references/_evidence-capture.md](references/_evidence-capture.md)),
   with named blockers as the only exemption.
2. The reviewer judges pixels before code — the Review Order section of the reviewer prompt.
3. Motion rules are recording-primary (see "Capture evidence protocol" below); code
   alone nominates candidates reported as N/A, never FAIL.
4. Every fix must pass the minimality test — smallest change that flips the rule,
   removal preferred over addition, nothing added beyond the rule's named remedy.

Added: 2026-07-17

## Rule-fidelity guards — patterns this gate must not import or contradict

These are pre-recorded so the reviewer judges by this gate's rules, not by community lore
or by the sibling gates' territory. The reviewer prompt carries the same list; keep
the two in sync.

### Inline font/color literals belong to the architecture sibling
`adversarial-swift-ui` (`access-semantic-fonts-and-colors`, `access-scaledmetric-custom-spacing`)
owns the literal-vs-semantic **mechanism** for fonts, colors, and spacing. This gate judges
**values and structure** instead: the 11 pt floor, banned thin weights, asset-catalog dark
appearances, computed contrast, spacing literals below the 12/24 pt clearance. A reviewer
who fails `.font(.system(size: 24))` here for being a literal is importing the sibling's rule.
Added: 2026-07-16

### A fixed-size hero display numeral is not a violation here
`ios-taste` deliberately recommends display-scale numerals. Whether the size literal needs
`@ScaledMetric` backing is the sibling gate's question; no rule in this gate touches it.
Added: 2026-07-16

### Confirmation on routine deletes fails, absence of confirmation on irreversible ones also fails
`flow-no-confirm-undoable-deletes` is deliberately two-directional. The reviewer must not import
"always confirm destructive actions" lore — the HIG says the opposite for common, undoable
deletions. Both legs require the recoverability evidence named in the rule.
Added: 2026-07-16

### No single-accent-color rule exists
Apple Health uses a dedicated color per domain; Fitness uses one accent in four placements.
Both are compliant. Only the per-bar tint count (`glass-one-tinted-action-per-bar`) is
enforced. A reviewer counting accent hues across screens is inventing a rule.
Added: 2026-07-16

### `.easeInOut` is not automatically a violation
`motion-springs-over-curves` carves out pure opacity crossfades and constant-rate
non-interactive motion (`.linear` on shimmer/marquee/indeterminate progress). The curve is
only a violation on animations that move or resize views.
Added: 2026-07-16

## Threshold provenance

### The 0.5 s feedback-duration cap is derived, not Apple-published
`motion-brief-feedback` anchors on Apple's default spring response (0.55) and the HIG's
"brevity and precision" language. The rule text discloses this. If it produces verdicts
that flip between runs, tighten the trigger list (which interactions count as direct
feedback) rather than debating the number.
Added: 2026-07-16

### No sub-300 ms spinner rule
Apple publishes no such number ("a moment or two" is the HIG's language). The intent lives
structurally in `state-skeleton-over-spinner` (whole-screen spinner swap vs placeholder).
Do not add a millisecond threshold on review.
Added: 2026-07-16

## Capture evidence protocol

Capture is a dispatcher duty, not an input option: build and run the target, screenshot
every affected screen (light, dark, accessibility text size), record every
structure-mutating interaction plus an idle pass per primary screen, and tile recordings
into 10 fps filmstrips — commands and reading guide in
[references/_evidence-capture.md](references/_evidence-capture.md).

Screenshot-dependent legs (edge contact in `layout-inset-buttons`, rendered contrast in
`color-contrast-floors` / `color-scrim-over-images`, dark-mode image survival in
`color-dark-variants`) are N/A with reason "screenshot evidence unavailable" when no capture
covers them — never PASS without the capture, never FAIL on code evidence alone. One further
leg uses screenshots as **fallback** evidence rather than required evidence: the
letterbox-band leg of `layout-bleed-backgrounds-respect-safe-areas` decides from code when
the composition is unambiguous and from a capture when it is not.

Motion is two-tier. Tier 1 — `motion-animate-structural-changes`, `motion-bounce-cap`,
`motion-brief-feedback`, `motion-zoom-transitions`, `motion-no-gratuitous-animation` —
FAILs only on filmstrip evidence; code alone nominates a candidate reported as N/A
("recording evidence unavailable — candidate at file:line"). Tier 2 —
`motion-springs-over-curves` and `motion-reduce-motion-path` — stays code-decidable: the
curve expression deterministically produces the defect, the missing Reduce Motion guard is
a structural absence, and both fixes reduce or swap motion, never add it. The tier split is
deliberate; making tier 2 recording-required would blind the gate to deterministic defects
without preventing any add-animation fix.
Added: 2026-07-16; revised 2026-07-17 (capture made mandatory, motion tiers added)

## Judgment calls deliberately excluded from this gate

Routed to `ios-taste` / teaching territory because a blind reviewer cannot decide them
from artifact evidence alone: minimize typefaces; important-items-near-the-top placement;
negative-space and density judgment; "realistic"/"excessive" motion; menu label clarity;
"appropriate" tab count beyond the ≤5 floor; onboarding "fast, fun" quality; haptic
intensity-matching; single-accent discipline; relevance ranking of search results; medium
detent choice; progress pacing fidelity; state restoration across launches.
Added: 2026-07-16

## Proven both ways (July 2026 dry run)

- **FAIL side:** a coffee-journal app with ~20 planted violations across all 10 categories
  (hamburger drawer, pushed Save-form, Yes/No alert, 30 pt target, 9 pt text, Ultralight
  title, ALL-CAPS headers, Color.white/.gray, color-only status dot, no empty state,
  whole-screen "Loading…" spinner, bare error text, 0.8 s easeInOut, scroll-offset haptic,
  resized SF Symbol, appearance lock, Dark Mode toggle). Both blind reviewers returned
  overall FAIL and caught every planted violation with file:line evidence.
- **PASS side:** a clean hike-logging app. The gate first caught **five genuine
  author-unintended bugs** across two rounds (unqueried-empty search void, unread error
  phase in the search tab, launch-screen background mismatched with the grouped first
  screen, unanimated skeleton→content swap, and an unanimated `.loading` mutation reachable
  from Retry) — each unanimous, each with the correct located fix. After fixing them, round
  3 returned unanimous PASS with zero failures and zero contested rules.
- The strongest decidability evidence is the PASS side: the rules repeatedly failed a
  "clean" artifact on real defects the author did not plant.

(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

Added: 2026-07-16

## v0.2.0 field dry run (2026-07-17, real app — MaddieConsole clinic console)

First end-to-end run of the evidence-first protocol on a real working tree. Outcome: overall
FAIL — 2 unanimous FAILs, 3 contested, 50 unanimous PASSes with evidence. What it proved:

- **The recording-primary design worked as intended.** The one motion FAIL
  (`motion-animate-structural-changes`) was grounded by both blind reviewers in the same
  filmstrip tiles (search results teleporting between adjacent frames), citing the same
  mutation site, and the fix was one `withAnimation` at that site — no animation spray.
  The idle filmstrip cleared `motion-no-gratuitous-animation` affirmatively.
- **The minimal-fix constraint held.** One of the five fixes is a pure removal (delete a
  confirmation dialog); none adds machinery beyond the rule's named remedy.
- **Rendered evidence caught what code reading wouldn't own:** the AX5 capture showed the
  schedule timeline rendering zero appointment cards at accessibility sizes (reproduced on
  two simulators) — reported out-of-scope since no rule decides canvas mis-layout, but it
  was the most user-visible defect found. Candidate for a future rule leg.

Operational gotchas for the capture step:
- **Capture on a dedicated simulator.** A UI-test run (`xcodebuild test`) on the shared
  simulator SIGTERMs and relaunches the app and drives its UI — it contaminated early
  captures (phantom menus/sheets/scrolls) until the dry run moved to its own device and
  waited for a quiet window. Check `ps` for `xcodebuild test` before capturing.
- **Pass `--udid` to every rocketsim command.** RocketSim otherwise follows the *focused*
  simulator window, which silently drifts to another device mid-session; taps then land on
  the wrong simulator while simctl captures the right one. The `--udid` flag exists on all
  interact/elements/wait subcommands even though the skill docs don't mention it.
- **Verify every capture against its intended content** (view the PNG, don't trust the tap
  delta): silent tap failures shift a whole screenshot series one screen out of label sync.
  In the iOS 26 search tab the tab bar morphs into the search field, so tab taps fail until
  search is closed.
- **ffmpeg tile output needs `-frames:v 1`** or recordings longer than one tile page error out.
- **Single-frame spot checks lie:** `select=eq(n,N)` on a sparse-encoded simulator recording
  silently writes nothing when frame N doesn't exist, leaving a stale file from the previous
  run. Always regenerate the full filmstrip instead.

Contested rules recorded (one dry run — record, don't rewrite yet; sharpen if repeated):
- **`nav-system-back-button`** (FAIL vs PASS): is a pushed screen's *edit mode* with explicit
  Cancel/Save replacements inside the modal carve-out, or does the carve-out require an
  enclosing sheet/cover? The rule text should decide edit-mode explicitly.
- **`flow-confirmationdialog-destructive`** (FAIL vs PASS): does "anchored to the triggering
  control" mean the modifier's attachment point in code, or is a root-attached dialog with
  correct roles/verbs compliant? Name the evidence (modifier attachment site) explicitly.
- **`flow-one-sheet-at-a-time`** (FAIL vs PASS): coverage split, not ambiguity — one reviewer
  missed a nested `.sheet` inside a sheet-presented form. Consider requiring reviewers to
  grep `.sheet(` and audit every site inside sheet-presented content.

(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer. Under the current protocol, a rule that produced a split here would instead be watched for a flipped verdict across re-reviews of an unchanged target.)

Added: 2026-07-17

## Contested-verdict history

### Round-1 dry run produced four contested rules — all sharpened before release
Two blind reviewers per artifact, July 2026 dry run. Splits and the fixes applied:

- **`color-contrast-floors`** (FAIL vs N/A on `Color.gray`-on-`Color.white`): one reviewer
  computed the system constants, the other declined. Sharpened — the rule now computes only
  pairs with at least one custom recoverable value; all-system-constant pairings route to
  `color-label-ladder`/`color-system-backgrounds`.
- **`layout-bleed-backgrounds-respect-safe-areas`** (N/A vs FAIL on `.background(Color.white)`
  without `ignoresSafeArea`): sharpened — solid single-color fills on content containers are
  not letterbox evidence (SwiftUI extends them ambiguously); the code leg now names decorative
  artwork layers (gradient/Image/Canvas) only.
- **`haptic-significant-outcomes`** (N/A vs FAIL on a "Saved!" alert with no success haptic):
  one reviewer routed the alert to `flow-alerts-actionable-only` and skipped it here.
  Sharpened — outcome UI that violates another rule still counts as this rule's predicate;
  each rule judges its own axis.
- **`craft-numeric-text`** (FAIL vs N/A on a `Stepper`'s string-interpolated title): sharpened —
  standard controls' own title labels are N/A; the subject is a `Text` displaying a changing
  metric.

(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

Added: 2026-07-16

### Field context: the gate that never ran (maddie-ios calendar, July 2026)

In the session that degraded the calendar, this gate was announced ("the calendar fix
is user-facing, so I'm also applying the iOS design gate at the end"), sequenced last
behind the code gates, and never dispatched — the session died before it. The failures
the user reported (tap flaking into drag, dead resize handles, a bespoke Move/Cancel
menu unlike Apple Calendar) were all in this gate's territory. Hence the SKILL.md
ordering rule: on gesture/interaction diffs this gate runs first, and gesture-bearing
interactions need ≥3 consecutive recorded trials in one app session (see
[references/_evidence-capture.md](references/_evidence-capture.md)).

Added: 2026-07-17

### Rule candidate from the July 2026 field audit (next evolve)

**Native-parity for standard interaction grammars** — when a screen reimplements an
interaction Apple ships a canonical grammar for (calendar event lift-move-resize,
list swipe actions, pull-to-refresh), the custom version must match the native
grammar's phases or FAIL. Field case: a bespoke two-button glass "Move / Cancel" menu
replaced Apple Calendar's continuous press–lift–drag, adding a second interaction
mode alongside the gesture and accessibility paths — three movement entry points with
different lifecycles. Needs a decidable evidence spec (probably: side-by-side
recording of the native app vs the target, phase-by-phase filmstrip comparison)
before it can be a rule.

Added: 2026-07-17
