---
title: Distinguish 401 Unauthorized from 403 Forbidden
impact: MEDIUM
impactDescription: enables correct client behavior — re-authenticate vs stop trying
tags: err, 401, 403, authentication, authorization
---

## Distinguish 401 Unauthorized from 403 Forbidden

401 and 403 communicate fundamentally different problems. 401 means "I don't know who you are" -- the client should re-authenticate (refresh token, re-login). 403 means "I know who you are, and you're not allowed" -- re-authenticating won't help, the client needs different permissions. Returning 403 for missing tokens forces clients to guess whether re-authentication would fix the problem. Returning 401 for insufficient permissions causes infinite re-authentication loops.

**Incorrect (403 for both missing auth and insufficient permissions):**

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    unless current_user
      render json: { error: "Forbidden" }, status: :forbidden  # 403 — client thinks permissions are the problem
    end
  end

  def authorize!(permission)
    unless current_user.can?(permission)
      render json: { error: "Forbidden" }, status: :forbidden  # same 403 — client cannot distinguish
    end
  end
end
```

**Correct (401 for authentication, 403 for authorization, with recovery links):**

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    return if current_user

    response.headers["WWW-Authenticate"] = 'Bearer realm="api"'  # required by RFC 9110 on 401
    render json: {
      type: "https://api.example.com/problems/unauthenticated",
      title: "Unauthorized",
      status: 401,
      detail: "Bearer token is missing or expired",
      _links: { oauth_token: { href: "/oauth/token", title: "Obtain a new token" } }
    }, status: :unauthorized, content_type: "application/problem+json"
  end

  def authorize!(permission)
    return if current_user.can?(permission)

    render json: {
      type: "https://api.example.com/problems/forbidden",
      title: "Forbidden",
      status: 403,
      detail: "Your account does not have the '#{permission}' permission",
      _links: { self: { href: request.path } }
    }, status: :forbidden, content_type: "application/problem+json"
  end
end
```

```http
# Missing or expired token
GET /api/orders HTTP/1.1

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="api"
Content-Type: application/problem+json

{
  "type": "https://api.example.com/problems/unauthenticated",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Bearer token is missing or expired",
  "_links": { "oauth_token": { "href": "/oauth/token" } }
}
```

```http
# Valid token but insufficient permissions
DELETE /api/orders/ord_abc HTTP/1.1
Authorization: Bearer valid_but_read_only_token

HTTP/1.1 403 Forbidden
Content-Type: application/problem+json

{
  "type": "https://api.example.com/problems/forbidden",
  "title": "Forbidden",
  "status": 403,
  "detail": "Your account does not have the 'orders:delete' permission"
}
```

**Benefits:**
- Client SDKs implement correct retry logic: refresh token on 401, show permissions error on 403
- The `WWW-Authenticate` header on 401 is required by RFC 9110 and enables automated token refresh
- Recovery links in 401 guide the client to the token endpoint
- No infinite re-authentication loops from misinterpreted 403s

**When NOT to use:** If your API must not reveal whether a resource exists to unauthorized users, return 404 instead of 403 to avoid information leakage (e.g., for private user profiles).

**Reference:** RFC 9110 Section 15.5.2 (401 Unauthorized), Section 15.5.4 (403 Forbidden). See also `restful-hateoas:err-problem-details` for error response format.
