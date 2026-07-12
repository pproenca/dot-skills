# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the architectural mistakes with the widest blast radius go first; the verdict
report's fix list follows this order.

This is a pass/fail review gate, not a performance skill, so there are no impact
tiers. Each rule names a wrong assumption about what a LiveView *is* — a stateful
process rendering change-tracked diffs over a lossy socket, not a page controller
bolted to a JS framework — and carries an **Evidence of violation** paragraph:
the artifact evidence that decides PASS/FAIL/N/A, with carve-outs that must be
claimed with citable evidence (fail closed otherwise).

---

## 1. State Ownership & Lifecycle (state)

**Description:** LiveViews written as if each render were a fresh page. Full
remounts (`push_navigate`) where a patch keeps the process and its state alive,
params-dependent data loaded in `mount` (stale after every patch) or
params-independent data loaded in `handle_params` (re-fetched on every patch),
subscriptions and timers started during the throwaway disconnected mount, and
forms that silently lose user input on reconnect because the auto-recovery
contract (`id` + `phx-change`) was never wired. The wrong assumption: "a
LiveView is a page." It is a long-lived process with a documented lifecycle —
mount once, patch many, die and recover — and state must be placed where that
lifecycle preserves it.

## 2. Realtime Data Flow (flow)

**Description:** Broadcast topology decided by whatever file was open. Domain
events broadcast from inside the LiveView event handler (so every other write
path — jobs, seeds, API controllers — silently emits nothing), one global topic
that every client subscribes to and filters per-message in `handle_info`
(every socket pays for every event), and who's-online tracking hand-rolled as a
GenServer map that accumulates ghosts on crash and netsplit. The wrong
assumption: "realtime means broadcasting whatever, from wherever." Broadcasts
belong beside the write in the context, topics carry the scope that narrows
delivery, and presence is a solved distributed-systems problem — use a tracker
with monitored cleanup. Delivery *semantics* (durability, ordering, idempotency)
are the sibling gate `adversarial-beam`'s territory, not this category's.

## 3. Async & Process Responsiveness (async)

**Description:** Work placed on the LiveView process as if it were free. A
synchronous HTTP call in `mount` or `handle_event` blocks the *entire* view —
every click, every patch, every broadcast queues behind it. Sockets captured
into task closures copy the whole socket struct per task. Raw `spawn`/`Task.async`
from callbacks either links (a task crash kills the view) or orphans (navigation
kills work the user expects to complete). And `assign_async` rendered with only
its ok branch turns every failure into a blank region. The wrong assumption:
"the LiveView process is free." It is one GenServer serving one user's entire
UI; long work moves off it via `assign_async`/`start_async` or a supervised
runner, and every async result has three states to render, not one.

## 4. Render & Wire Efficiency (render)

**Description:** HEEx treated as a template language when it is a change-tracked
diff compiler that specific constructs silently disable. Data loaded inside the
template (never re-rendered when it changes), local variables in the template
body (change tracking off for the expression), the whole `assigns` map passed to
helpers or components (everything re-renders on every change), `Map.put` on
`socket.assigns` (the update is invisible to tracking), and collections rendered
via `Enum.map` instead of a keyed `:for` comprehension (statics resent per item,
whole list resent per change). The wrong assumption: "if it renders, it works."
It renders — and then ships the whole page over the wire on every diff, or stops
updating entirely. Every one of these compiles clean and looks identical in dev.

## 5. Collections & Streams (stream)

**Description:** Collections held in socket memory because assigns are the
obvious place. A feed that appends from PubSub, a table that paginates by
concatenating — each grows per-socket server memory without bound and re-diffs
the whole collection per change; `stream/4` exists precisely so the server
holds nothing. Streams come with a DOM contract (container `id` +
`phx-update="stream"` + stream-issued item ids) that breaks patching silently
when violated, and infinite scroll via `phx-viewport-*` is only bounded when
`limit:`, an end-of-collection guard, and `_overran` reset handling travel
together. The wrong assumption: "assigns are free." Every assign is resident
memory multiplied by connected sockets.

## 6. Component & Context Boundaries (bound)

**Description:** The LiveView as the whole application. `Repo` calls and
`Ecto.Query` imports inside `*_web` modules (data access scattered past the
context boundary every other caller uses), stateful LiveComponents used as code
folders when a function component is the documented default, PubSub round-trips
between a component and the parent *in its own process* (`send/2` and
`send_update/3` exist), and component-owned events missing
`phx-target={@myself}` so they route to the parent. The wrong assumption: "the
LiveView is the app." The context owns data access, function components own
markup, LiveComponents own genuinely local state-plus-events, and messages
between them use the process they already share.

## 7. Client Trust & Event Security (trust)

**Description:** Authorization delegated to the visibility of buttons. Every
`handle_event` is a public endpoint any connected client can invoke with any
payload — hiding the button changes nothing. Client-supplied ids passed to
unscoped fetches read other tenants' rows (IDOR). Routes with different
authorization inside one `live_session` (or live routes guarded only by plugs
that live navigation never re-runs) inherit each other's weakest check. And a
revoked user's already-connected sockets keep working unless something
broadcasts a disconnect. The wrong assumption: "the UI constrains the user."
The socket is the attack surface; every event authorizes, every lookup is
scoped to the actor, and revocation reaches live connections.

## 8. Interaction Feedback & Client Commands (ui)

**Description:** UIs designed against localhost latency. A server round-trip to
toggle a dropdown that `JS.toggle` handles at zero latency, submit buttons and
destructive clicks that give no in-flight acknowledgment (`phx-disable-with`,
loading classes, and `JS.push loading:` all unused), validation inputs firing an
event per keystroke with no `phx-debounce`, hooks and third-party widgets
missing the `id`/`phx-update="ignore"` contract so the next diff wipes their
DOM, and hand-rolled overlays that trap no focus. The wrong assumption:
"localhost latency is the product." Every check in this category is the presence
or absence of a named mechanism — no aesthetic judgment; how it *looks* is out
of scope.
