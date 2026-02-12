---
title: Use Deprecation and Sunset Headers to Signal API Changes
impact: LOW-MEDIUM
impactDescription: gives clients machine-readable advance warning, enables automated migration tooling
tags: evolve, deprecation, sunset, rfc-9745, rfc-8594
---

## Use Deprecation and Sunset Headers to Signal API Changes

Documenting API deprecations only in changelogs or developer portals requires humans to read and act on them. The `Deprecation` header (RFC 9745) and `Sunset` header (RFC 8594) provide machine-readable signals that automated tools and client SDKs can detect. Including a `Link` header with `rel="deprecation"` pointing to migration documentation closes the loop -- clients know something is deprecated, when it will be removed, and how to migrate.

**Incorrect (removing endpoint without warning -- clients discover the break in production):**

```ruby
# config/routes.rb
# Removed: get "/api/v1/orders/:id/receipt", to: "orders#receipt"
# No headers, no warning, no migration guide -- clients get 404
```

**Correct (Deprecation + Sunset + Link headers during migration window):**

```ruby
# app/controllers/concerns/deprecatable.rb
module Deprecatable
  extend ActiveSupport::Concern

  private

  def deprecate!(sunset:, migration_url:)
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = sunset.httpdate
    response.headers["Link"] = "<#{migration_url}>; rel=\"deprecation\""
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  include Deprecatable

  # Old endpoint -- deprecated in favor of /orders/:id/documents/receipt
  def receipt
    order = current_user.orders.find(params[:id])

    deprecate!(
      sunset: Time.utc(2026, 6, 1),
      migration_url: "https://api.example.com/docs/migration/receipt-endpoint"
    )

    render json: ReceiptSerializer.new(order.receipt).as_json
  end
end
```

```http
GET /api/v1/orders/42/receipt HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 200 OK
Deprecation: true
Sunset: Mon, 01 Jun 2026 00:00:00 GMT
Link: <https://api.example.com/docs/migration/receipt-endpoint>; rel="deprecation"
Content-Type: application/json

{ ... receipt data ... }
```

**Benefits:**
- Client SDKs can log warnings or raise alerts when they receive `Deprecation: true`
- The `Sunset` date enables automated tracking of migration deadlines
- The `Link` header with `rel="deprecation"` provides a direct path to migration instructions

**When NOT to use:** Do not add deprecation headers to endpoints that are merely evolving additively (new fields). Deprecation signals indicate the endpoint or field will be removed entirely.

**Reference:** RFC 9745 (The Deprecation HTTP Response Header Field), RFC 8594 (The Sunset HTTP Header Field). See also `restful-hateoas:evolve-additive-changes-only` for non-breaking evolution strategies.
