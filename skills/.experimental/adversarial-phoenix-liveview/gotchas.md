# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at creation (dry run, 2026-07-12)

Two blind reviewers per artifact, identical composed prompt, Phoenix 1.8.9 / phoenix_live_view 1.2.6 stack ("Tably", a realtime restaurant floor dashboard + waitlist app — deliberately a different domain than the rules' auction examples):

- **Planted-violation artifact** (15 files: floor + admin LiveViews, two LiveComponents, contexts, API controller, hand-rolled online tracker, JS hook — all 32 rules planted): both reviewers returned overall FAIL with the *identical* 30 rule failures, each with file:line evidence and a concrete located fix. Zero contested rules, zero N/A.
- **The two non-FAILs were unanimous and correct, not misses.** `bound-component-messaging` PASSed for both reviewers via the fan-out carve-out with the citation the rule demands (the component's broadcast topic has sibling floor sockets as genuine second subscribers) — while the same broadcast's *placement* still failed `flow-broadcast-from-context`. Interlocking rules disagreeing about different aspects of one line is the gate working, not flaking.
- **`bound-myself-target` sharpened from the dry run:** both reviewers PASSed it on the rule's original "on the element or its enclosing form" wording, and both *independently* flagged the same latent bug in out-of-scope notes — LiveView applies a form's `phx-target` only to form-lifecycle events (`phx-change`/`phx-submit`); a `phx-click` inside the form does not inherit it, so the artifact's Cancel button actually routes to the parent at runtime. The evidence paragraph now scopes the enclosing-form leg to form events only. Treat unanimous out-of-scope convergence as a rule-sharpening signal even when no verdict was contested.
- **Clean artifact** (independent implementation of the same feature surface, every rule's problem shape exercised on the correct side): both reviewers returned overall PASS — 32 PASS, 0 N/A, 0 contested. Carve-outs were claimed with citations, not asserted: the search form's `phx-auto-recover="ignore"` attribute, the `{@rest}` spread backed by `attr :rest, :global`, and the presentation assign (`:editing`) read by server logic.
- Convergence notes worth keeping: (1) both reviewers ruled that pure data-shaping `Enum.map`s (payload/options builders) are outside `render-keyed-comprehensions` — only `Enum.map` producing template elements fires it; (2) both ruled a wholesale-replaced list assign (`@tables` re-assigned per patch) is not `stream-collections-not-assigns` evidence — only accumulation (`++`, `[x | xs]` across events) is; (3) both treated the missing-CSS repo fact as decisive for `ui-inflight-feedback` (no loading-class styling can exist if no stylesheet exists) — give reviewers the CSS location in stack facts.

Added: 2026-07-12

### Scope guards the reviewers must not override (pre-recorded at creation)

- This gate judges **LiveView-side realtime-UI architecture**, not message delivery. PubSub durability, ordering, exactly-once, idempotent consumers, and persisting broadcast snapshots belong to the sibling gate `adversarial-beam`; OO/enterprise paradigm habits belong to `adversarial-elixir` — reviewers must not import either here.
- **Every rule in this gate fails closed.** There is no fail-open rule; every carve-out must be claimed with the citation its rule names (the second subscriber, the server-side read of a presentation assign, the visible bound on a collection, the public route/render, the tight client timeout).
- **`ui-*` rules gate mechanism presence, never appearance.** A reviewer who writes "the loading state feels wrong" or "this transition is ugly" is outside the gate. The only question is whether the named mechanism (`phx-disable-with`, loading-class styling, `phx-debounce`, `focus_wrap`, `phx-update="ignore"`, a DOM id on a hook) exists.
- **Shapes, not brands.** `Phoenix.Presence`, `Oban`, and `Task.Supervisor` are canonical remedies, not requirements: any tracker with monitored cleanup and distributed conflict semantics satisfies `flow-presence-not-hand-rolled`; any supervisor-owned execution satisfies the must-complete leg of `async-lifecycle-owned-tasks`. Their absence does not make a rule N/A when the problem shape is present.
- **`current_scope` is a spelling, not the rule.** Phoenix 1.8 scaffolds thread `current_scope`; on pre-1.8 codebases any actor-filtered fetch or in-handler permission check satisfies the `trust-*` shape. Do not fail a codebase for the assign name.
- **Plain Repo/context CRUD is exempt from `async-no-blocking-external-calls`** — the rule anchors on named external-client call types (HTTP clients, `:timer.sleep`, long exports), not on "this query looks slow".
- **`render-keyed-comprehensions` claims wire cost, not breakage.** `Enum.map` in a template renders correctly; the violation is forfeited comprehension diffing. Reviewers must not report it as a correctness bug.
- **`flow-broadcast-from-context` is convention-backed** (the phx.gen.live scopes-guide pattern and LiveBeats), not a hexdocs MUST — the rule stands on the multi-writer consequence (other write paths silently never broadcast), and that consequence is the evidence to argue from.
- **Hook placement is not gated.** Colocated hooks (`:type={Phoenix.LiveView.ColocatedHook}`) and app.js-registered hooks both pass `ui-hook-ignore-contract`; only the missing DOM id / missing `phx-update="ignore"` legs fail.
- **`assign_async`/`start_async` are exempt from `state-connected-guard`** — the docs state the task only starts when the socket is connected; do not demand a redundant `connected?` wrapper around them.

Added: 2026-07-12
