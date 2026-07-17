# Evidence Capture — Mandatory Protocol Step

This gate judges rendered user interface, not source text. A review dispatched without
captures decides almost every rule from code inference — which turns the gate into a
linter that prescribes motion and feedback it has never seen. Capture is therefore a
**protocol step, not an option**: the dispatching agent builds and runs the target,
captures the screens, and records the interactions **before** composing the reviewer
prompt. "No captures were provided" is only a valid state when a named blocker is
recorded in the verdict header.

## Preflight — verify capture capability before dispatching anything

Before the build, before composing prompts: boot the simulator and take one throwaway
screenshot (`xcrun simctl io booted screenshot "$TMPDIR/preflight.png"`). Sandboxed
environments commonly cannot reach CoreSimulator at all — discovering that hours into
a review (the July 2026 failure mode) silently degrades every motion verdict to code
inference. If the preflight fails, record the named blocker in the verdict header
**now** and decide up front whether a captures-absent review is still worth
dispatching — do not find out mid-run.

## What to produce

| Evidence | Of what | Unlocks |
|----------|---------|---------|
| Light + dark screenshot | Every screen the target touches | Rendered-contrast, scrim, dark-variant, edge-contact, and letterbox legs |
| One accessibility-size screenshot (`accessibility-extra-extra-extra-large`) | The densest affected screen | Citable clipping evidence corroborating `layout-no-fixed-text-cages` (the rule itself stays code-decidable) |
| Recording → filmstrip | Every interaction that mutates visible structure (add/delete/toggle/expand/load) and every push from an artwork cell | All tier-1 motion rules (`motion-animate-structural-changes`, `motion-no-gratuitous-animation`, `motion-bounce-cap`, `motion-brief-feedback`, `motion-zoom-transitions`) |
| Idle recording → filmstrip (5 s, no input) | Each primary screen at rest | The ambient-motion leg of `motion-no-gratuitous-animation` |

Name files so reviewers can cite regions: `evidence/<screen>-<light|dark|ax5>.png`,
`evidence/<interaction>-filmstrip.png`. Put them in the session scratchpad and pass
**absolute paths** into the reviewer prompt.

## Build, install, launch

```bash
xcrun simctl boot "iPhone 16 Pro"        # skip if a device is already booted
xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcrun simctl install booted <path/to/App.app>
xcrun simctl launch booted <bundle.id>
```

## Screenshots

```bash
xcrun simctl ui booted appearance light
xcrun simctl io booted screenshot evidence/invoice-list-light.png
xcrun simctl ui booted appearance dark
xcrun simctl io booted screenshot evidence/invoice-list-dark.png

xcrun simctl ui booted content_size accessibility-extra-extra-extra-large
xcrun simctl io booted screenshot evidence/invoice-list-ax5.png
xcrun simctl ui booted content_size large                    # restore the default
```

Navigate between captures with the `rocketsim` CLI (preferred — it reads the
accessibility tree and taps by element), or by hand if rocketsim is unavailable.

## Recordings and filmstrips

Start the recording in the background, drive the interaction, then stop it with SIGINT:

```bash
xcrun simctl io booted recordVideo --codec h264 evidence/delete-row-rec.mp4 &
REC_PID=$!
# drive the interaction (rocketsim tap on the Delete button, etc.)
kill -INT "$REC_PID"; wait "$REC_PID"
```

Tile the recording into a filmstrip — at `fps=10` **each tile is 100 ms**, which is the
unit reviewers count in:

```bash
ffmpeg -i evidence/delete-row-rec.mp4 -vf "fps=10,scale=240:-1,tile=8x4" \
  evidence/delete-row-filmstrip.png
```

For a long or subtle interaction, dump individual frames instead so a reviewer can zoom:

```bash
ffmpeg -i evidence/delete-row-rec.mp4 -vf fps=10 evidence/delete-row-frame-%03d.png
```

### Gesture-bearing interactions need repeated trials

For any interaction backed by custom gesture handling — drag, long-press, resize
handles, sequenced/exclusive recognizer chains, custom `ButtonStyle` or
`PrimitiveButtonStyle` implementations — one clean run proves nothing: recognizer
arbitration fails intermittently, not deterministically. Record **at least 3
consecutive trials of the same interaction in one app session** (tap → tap → tap,
drag → drag → drag) as a single recording. Any diverging trial — a tap that lifts
into a drag, a stationary press that never mounts its handles — is violation-grade
evidence even when the other trials succeed. Field case (July 2026): a gesture
rewrite shipped a tap path that worked once then flaked; every single-trial check
had been green.

### Reading a filmstrip

- **Teleport** — the structural change is complete between two adjacent tiles with no
  intermediate geometry: content snapped instead of animating.
- **Duration** — count tiles from the input frame to the settled frame; each tile is
  100 ms, so more than 5 tiles of feedback on a direct interaction exceeds the 0.5 s cap.
- **Overshoot/bounce** — the element crosses its settled position and comes back across
  tiles; on interface chrome that indicates bounce above the cap.
- **Ambient motion** — anything that changes across the tiles of an *idle* recording is
  motion no user caused; if it is not a progress indicator, it is gratuitous-animation
  evidence.
- **Zoom vs slide** — on a push from an artwork cell, either the tapped cell visibly
  grows into the detail screen (zoom) or the detail slides in from the trailing edge
  while the artwork teleports (slide).

## When capture is blocked

Only these count as blockers, and the verdict header must name the one that applied:
the project does not build; no simulator runtime for the deployment target is
installed; the affected screens are unreachable without credentials or backend state
the dispatcher cannot fabricate. "Didn't attempt capture" is not a blocker — it is a
protocol violation.

Consequences of a recorded blocker: screenshot-dependent legs go N/A; tier-1 motion
rules report their code-level candidates as N/A ("recording evidence unavailable —
candidate at file:line"), never FAIL and never PASS. The gate stays honest about what
it has not seen instead of guessing from code.
