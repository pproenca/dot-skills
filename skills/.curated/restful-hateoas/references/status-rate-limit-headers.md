---
title: Include Rate Limit Headers in API Responses
impact: HIGH
impactDescription: prevents client-side guesswork on throttling, enables automated backoff and quota management
tags: status, rate-limit, throttling, 429, retry-after
---

## Include Rate Limit Headers in API Responses

Without rate limit headers, clients discover throttling through 429 errors and resort to trial-and-error backoff strategies. Including `RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset` in every response lets clients proactively manage their request rate. When the limit is hit, the `Retry-After` header tells the client exactly when to resume.

**Incorrect (returns 429 with no rate limit context -- client guesses backoff time):**

```ruby
class ApplicationController < ActionController::API
  before_action :check_rate_limit

  private

  def check_rate_limit
    if rate_limiter.exceeded?(current_user)
      render json: { error: "Too many requests" }, status: :too_many_requests  # no headers, no guidance
    end
  end
end
```

**Correct (rate limit headers on every response, Retry-After on 429):**

```ruby
# app/controllers/concerns/rate_limited.rb
module RateLimited
  extend ActiveSupport::Concern

  included do
    before_action :check_rate_limit
    after_action :set_rate_limit_headers
  end

  private

  def check_rate_limit
    @rate_info = RateLimiter.check(current_user)

    return unless @rate_info.exceeded?

    response.headers["Retry-After"] = @rate_info.reset_in.to_s
    set_rate_limit_headers

    render json: {
      type: "https://api.example.com/problems/rate-limited",
      title: "Too Many Requests",
      status: 429,
      detail: "Rate limit of #{@rate_info.limit} requests per minute exceeded",
      retryAfter: @rate_info.reset_in
    }, status: :too_many_requests, content_type: "application/problem+json"
  end

  def set_rate_limit_headers
    return unless @rate_info

    response.headers["RateLimit-Limit"] = @rate_info.limit.to_s
    response.headers["RateLimit-Remaining"] = @rate_info.remaining.to_s
    response.headers["RateLimit-Reset"] = @rate_info.reset_at.to_i.to_s
  end
end

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  include RateLimited

  def index
    orders = current_user.orders.order(created_at: :desc).limit(25)
    render json: orders.map { |o| OrderSerializer.new(o).as_json }
  end
end
```

```http
GET /api/orders HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 200 OK
RateLimit-Limit: 100
RateLimit-Remaining: 87
RateLimit-Reset: 1707753600
Content-Type: application/json
```

```http
# After exceeding the limit
GET /api/orders HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 429 Too Many Requests
Retry-After: 42
RateLimit-Limit: 100
RateLimit-Remaining: 0
RateLimit-Reset: 1707753600
Content-Type: application/problem+json

{
  "type": "https://api.example.com/problems/rate-limited",
  "title": "Too Many Requests",
  "status": 429,
  "detail": "Rate limit of 100 requests per minute exceeded",
  "retryAfter": 42
}
```

**Benefits:**
- Clients monitor `RateLimit-Remaining` to self-throttle before hitting 429
- `Retry-After` eliminates guesswork -- clients wait exactly the right amount of time
- Consistent headers across all endpoints let client SDKs implement generic rate management
- 429 error uses Problem Details (RFC 9457) for consistent error handling

**When NOT to use:** Internal microservices behind a service mesh where rate limiting is handled at the infrastructure layer (e.g., Envoy, Istio) rather than the application.

**Reference:** IETF draft-ietf-httpapi-ratelimit-headers (RateLimit Header Fields for HTTP). See also `restful-hateoas:err-problem-details` for error response format.
