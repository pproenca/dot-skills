---
title: Group routes by auth level into separate live_sessions
tags: trust, live-session, on-mount, navigation
---

## Group routes by auth level into separate live_sessions

Live navigation between LiveViews in the same `live_session` reuses the existing socket — the docs are verbatim that these redirects "do not go through the plug pipeline." So a plug that guards `/admin` protects only the first full-page load; once a user holds a connected socket from any route in that session, `<.link navigate>` walks into the admin LiveView without the plug ever running again. The boundary that actually holds is the `live_session` itself: an `on_mount` hook declared there runs on every mount inside it, and crossing between two `live_session`s forces a full page reload — back through the plugs, onto a fresh socket. Mixing an admin console and public auction pages in one `live_session`, or relying on plugs alone for live routes, dissolves that boundary.

**Evidence of violation:** in the router, live routes with different authorization requirements grouped inside one `live_session` (an admin LiveView and a public or merely-authenticated LiveView in the same block), or a `live_session` (or bare `live` routes) whose only access control is a plug in the enclosing pipeline, with no `on_mount` hook carrying the same check. PASS: each `live_session` declares an `on_mount` hook matching its auth level, and routes of different privilege live in different `live_session`s — cite the router blocks and hook modules. N/A: the target touches no router `live` routes and no `on_mount` hooks. Carve-out (citable): every LiveView inside the shared `live_session` performs the stricter check itself in `mount` — cite each mount's check; one unguarded LiveView in the block voids the carve-out.

```elixir
scope "/", PaddleWeb do
  live_session :current_user,
    on_mount: [{PaddleWeb.UserAuth, :mount_current_scope}] do
    live "/auctions", AuctionLive.Index, :index
    live "/auctions/:id", AuctionLive.Show, :show
  end

  live_session :admin,
    on_mount: [{PaddleWeb.UserAuth, :ensure_admin}] do
    live "/admin/sellers", AdminLive.Sellers, :index
  end
end
```

Reference: [Phoenix.LiveView.Router.live_session/3 — Security considerations](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live_session/3)
