---
title: PATCH for Partial Updates with Merge Semantics
impact: CRITICAL
impactDescription: reduces bandwidth and prevents accidental field overwrites
tags: http, patch, partial-update, json-merge-patch, rfc-7396
---

## PATCH for Partial Updates with Merge Semantics

PATCH applies a partial modification to a resource. Using PUT to change a single field forces the client to send the entire representation, wasting bandwidth and risking accidental overwrites of fields modified by other clients between read and write. JSON Merge Patch (RFC 7396) provides simple, intuitive semantics: send only the fields you want to change, omitted fields remain untouched.

**Incorrect (using PUT to update a single field):**

```ruby
# Client must GET the full resource, modify one field, and PUT everything back
# Another client may have changed `phone` between the GET and PUT — overwritten silently

class ShipmentsController < ApplicationController
  def update
    shipment = Shipment.find(params[:id])
    shipment.update!(shipment_params)  # PUT semantics on a partial payload — undefined behavior
    render json: ShipmentSerializer.new(shipment)
  end

  private

  def shipment_params
    params.require(:shipment).permit(:tracking_number, :carrier, :status, :estimated_delivery,
                                     :weight, :dimensions, :signature_required)
  end
end
```

**Correct (PATCH with only changed fields):**

```ruby
# config/initializers/mime_types.rb
Mime::Type.register "application/merge-patch+json", :merge_patch

# app/controllers/shipments_controller.rb
class ShipmentsController < ApplicationController
  # PATCH /api/v1/shipments/:id
  # Content-Type: application/merge-patch+json
  def update
    shipment = Shipment.find(params[:id])

    unless request.content_type.in?(["application/merge-patch+json", "application/json"])
      return render json: { error: "PATCH requires Content-Type: application/merge-patch+json or application/json" },
                    status: :unsupported_media_type
    end

    shipment.update!(shipment_params)  # only supplied fields are changed
    render json: ShipmentSerializer.new(shipment)
  end

  private

  def shipment_params
    params.require(:shipment).permit(:tracking_number, :carrier, :status, :estimated_delivery)
  end
end
```

```http
PATCH /api/v1/shipments/19 HTTP/1.1
Content-Type: application/merge-patch+json

{
  "shipment": {
    "status": "in_transit",
    "tracking_number": "1Z999AA10123456784"
  }
}
```

**Benefits:**
- Clients send only what changed -- less bandwidth, smaller payloads
- No risk of overwriting fields modified by concurrent requests
- Clear intent: PATCH signals partial modification, PUT signals full replacement
- Content-Type header (`application/merge-patch+json`) makes merge semantics explicit

**When NOT to use:** Use PUT when the client has the full resource and wants to guarantee the entire state is set. Use JSON Patch (RFC 6902) when you need operations like `add`, `remove`, `move` on arrays or nested structures.

**Reference:** RFC 7396 (JSON Merge Patch), RFC 5789 (PATCH Method)
