# Gotchas

## Rule-fidelity guards — patterns this gate must not import or contradict

These are pre-recorded so reviewers judge by this gate's rules, not by community lore
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
`flow-no-confirm-undoable-deletes` is deliberately two-directional. Reviewers must not import
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
"brevity and precision" language. The rule text discloses this. If it produces contested
verdicts, tighten the trigger list (which interactions count as direct feedback) rather
than debating the number.
Added: 2026-07-16

### No sub-300 ms spinner rule
Apple publishes no such number ("a moment or two" is the HIG's language). The intent lives
structurally in `state-skeleton-over-spinner` (whole-screen spinner swap vs placeholder).
Do not add a millisecond threshold on review.
Added: 2026-07-16

## Screenshot evidence protocol

Screenshot-dependent legs (edge contact in `layout-inset-buttons`, rendered contrast in
`color-contrast-floors` / `color-scrim-over-images`, dark-mode image survival in
`color-dark-variants`) are N/A with reason "screenshot evidence unavailable" when no capture
covers them — never PASS without the capture, never FAIL on code evidence alone. One further
leg uses screenshots as **fallback** evidence rather than required evidence: the
letterbox-band leg of `layout-bleed-backgrounds-respect-safe-areas` decides from code when
the composition is unambiguous and from a capture when it is not. Provide light **and** dark
captures when dispatching the gate to unlock these legs.
Added: 2026-07-16

## Judgment calls deliberately excluded from this gate

Routed to `ios-taste` / teaching territory because two blind reviewers cannot decide them
from artifact evidence: minimize typefaces; important-items-near-the-top placement;
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

Added: 2026-07-16

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

Added: 2026-07-16
