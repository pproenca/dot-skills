---
title: Use PUT Only for Full Resource Replacement
impact: CRITICAL
impactDescription: prevents duplicate creation on network retry
tags: http, put, idempotent, full-replacement, update
---

## Use PUT Only for Full Resource Replacement

PUT sends a complete replacement representation and must be idempotent -- sending the same PUT request twice produces the same resource state. This is what makes PUT safe to retry on network failures. Using PUT for partial updates violates the HTTP contract and breaks retry safety, because omitted fields might be nullified on retry but not on the original request.

**Incorrect (PUT partially updates like PATCH):**

```ruby
class CustomersController < ApplicationController
  def update
    customer = Customer.find(params[:id])

    # Partial update via PUT — omitted fields keep old values on first call
    # but client expects full replacement semantics for retry safety
    customer.update!(customer_params)
    render json: CustomerSerializer.new(customer)
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :email, :phone)  # permits subset — not full replacement
  end
end
```

**Correct (PUT replaces all fields with complete representation):**

```ruby
class CustomersController < ApplicationController
  REQUIRED_FIELDS = %i[name email phone address_line_1 address_city address_postcode].freeze

  def update
    customer = Customer.find(params[:id])
    payload = customer_params

    missing = REQUIRED_FIELDS - payload.keys.map(&:to_sym)
    if missing.any?
      return render json: { error: "PUT requires complete representation, missing: #{missing.join(', ')}" },
                    status: :unprocessable_entity
    end

    customer.update!(payload)  # idempotent — same payload always produces same state
    render json: CustomerSerializer.new(customer)
  end

  private

  def customer_params
    params.require(:customer).permit(*REQUIRED_FIELDS)
  end
end
```

```http
PUT /api/v1/customers/cust_7f3a HTTP/1.1
Content-Type: application/json

{
  "customer": {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+44 7700 900000",
    "address_line_1": "10 Downing Street",
    "address_city": "London",
    "address_postcode": "SW1A 2AA"
  }
}
```

**Benefits:**
- Safe to retry on timeout -- sending the same PUT twice cannot produce a different state
- Clients always know the full resource state after PUT, no hidden defaults
- Clear separation from PATCH avoids ambiguity about which fields are affected

**When NOT to use:** Use PATCH when clients only know a subset of fields, or when bandwidth is a concern for large resources.

**Reference:** RFC 7231 Section 4.3.4 (PUT)
