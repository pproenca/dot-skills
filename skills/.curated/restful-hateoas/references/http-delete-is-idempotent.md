---
title: Ensure DELETE Is Idempotent
impact: CRITICAL
impactDescription: enables safe retries and prevents cascade failures on duplicate deletes
tags: http, delete, idempotent, error-handling, status-codes
---

## Ensure DELETE Is Idempotent

DELETE removes a resource and must be idempotent -- deleting the same resource twice must not produce an error or unexpected side effect. If the first DELETE succeeds but the client does not receive the response (network timeout), the client will retry. A server that raises 500 on the second attempt forces the client into an unrecoverable error state for an operation that already succeeded.

**Incorrect (raises exception on retry, returns HTML error page instead of JSON):**

```ruby
class OrdersController < ApplicationController
  def destroy
    order = Order.find(params[:id])  # raises ActiveRecord::RecordNotFound — 404 HTML page on retry
    order.destroy!
    head :no_content
  end
end
```

**Correct (idempotent DELETE, safe to retry):**

```ruby
class OrdersController < ApplicationController
  def destroy
    order = current_user.orders.find_by(id: params[:id])

    if order
      order.destroy!
      head :no_content  # 204 — resource successfully removed
    else
      head :not_found   # 404 — already gone, safe idempotent response
    end
  end
end
```

```http
DELETE /api/v1/orders/42 HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 204 No Content
```

```http
DELETE /api/v1/orders/42 HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 404 Not Found
```

**Benefits:**
- Network retries never cause 500 errors or cascade failures
- Clients can fire-and-forget DELETE without tracking whether a previous attempt succeeded
- Load balancers and queues can safely replay failed DELETE requests
- HEAD can check existence before DELETE when the client needs to distinguish "never existed" from "already deleted"

**Note:** Some APIs prefer returning 204 on repeated deletes (making the *response* idempotent too) rather than 404. Both are valid -- the key requirement is that the second DELETE must never produce a 500 error or unwanted side effect.

**When NOT to use:** If your domain requires audit trails, use soft-delete (`discarded_at` column) behind the same DELETE endpoint rather than changing HTTP semantics.

**Reference:** RFC 9110 Section 9.3.5 (DELETE), Section 9.2.2 (Idempotent Methods)
