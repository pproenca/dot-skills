---
title: Broadcast a disconnect when access is revoked
tags: trust, revocation, live-socket-id, sessions
---

## Broadcast a disconnect when access is revoked

Banning a seller deletes their session cookie's validity — for the *next* HTTP request. Their already-connected LiveViews never make another HTTP request: the socket stays up, `mount` never re-runs, and the banned user keeps bidding until they close the tab. Revocation only reaches live connections if something pushes it there. The mechanism is two-sided: the auth plug stores a `live_socket_id` in the session so every socket the user opens is addressable, and the revocation flow broadcasts `"disconnect"` on that id — the client then reconnects, re-runs `mount`, and the dead session fails authentication. Skip either side and revocation is a fiction for anyone currently connected.

**Evidence of violation:** the target contains a revocation flow — banning a user, a password change or logout-everywhere action, a role downgrade — and either no `live_socket_id` is placed in the session at login, or the revocation path contains no `Endpoint.broadcast(live_socket_id, "disconnect", %{})` (or equivalent broadcast on the `"users_socket:..."` topic). The mechanism being absent while the revocation shape is present is FAIL, not N/A. PASS: the login path sets `live_socket_id` and every revocation path broadcasts the disconnect — cite both sites. N/A: the target contains no revocation flow and none is reachable from the changed code (no ban, no credential change, no role mutation). Carve-out (citable): sessions are re-validated on an interval inside the LiveView itself (a periodic `handle_info` re-checking the token against the store) — cite the timer and the check; a short token TTL alone does not qualify unless the socket demonstrably re-authenticates on expiry.

```elixir
# In the auth plug at login:
conn
|> put_session(:live_socket_id, "users_socket:#{user.id}")

# In the revocation flow (Paddle.Accounts.ban_seller/2):
PaddleWeb.Endpoint.broadcast("users_socket:#{seller.id}", "disconnect", %{})
# Every LiveView socket for that user drops; reconnect re-runs mount,
# which fails against the revoked session.
```

Reference: [Phoenix.LiveView — Security considerations (disconnecting all instances of a user)](https://hexdocs.pm/phoenix_live_view/security-model.html)
