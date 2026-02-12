---
title: Make Only Additive Changes to API Responses
impact: LOW-MEDIUM
impactDescription: prevents breaking existing clients, enables smooth API evolution without version bumps
tags: evolve, backward-compatibility, additive, non-breaking
---

## Make Only Additive Changes to API Responses

Removing or renaming a field in an API response is a breaking change -- every client that reads that field will fail. Additive changes (new fields, new links, new embedded resources) are always safe because well-behaved clients ignore fields they do not recognize. When a field must be replaced, add the new field alongside the old one and deprecate the old field using headers and documentation, giving clients a migration window.

**Incorrect (renaming and removing fields -- breaks existing clients):**

```ruby
# app/serializers/order_serializer.rb -- V2 "cleanup"
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      order_total: @resource.total.to_f,  # renamed from "total" -- breaks clients reading "total"
      status: @resource.status
      # customer_id removed -- breaks clients that use it for lookups
    }
  end
end
```

**Correct (add new fields alongside old ones, deprecate with Sunset header):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      total: @resource.total.to_f,        # keep original field
      order_total: @resource.total.to_f,  # add new field alongside
      customer_id: @resource.customer_id, # keep -- never remove without Sunset period
      status: @resource.status
    }
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find(params[:id])

    response.headers["Sunset"] = "Sat, 01 Mar 2026 00:00:00 GMT"
    response.headers["Deprecation"] = "true"
    response.headers["Link"] = '</docs/migration/order-total>; rel="deprecation"'

    render json: OrderSerializer.new(order).as_json
  end
end
```

**Benefits:**
- Existing clients continue working without code changes
- New clients can adopt improved field names immediately
- The Sunset header gives clients a machine-readable deadline for migration

**When NOT to use:** Security-critical removals (e.g., accidentally exposing internal IDs or PII) should be removed immediately regardless of backward compatibility, with a clear incident notification to consumers.

**Reference:** See also `restful-hateoas:evolve-deprecation-headers` for the full Deprecation/Sunset header protocol.
