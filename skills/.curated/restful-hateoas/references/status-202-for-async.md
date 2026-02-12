---
title: Return 202 Accepted for Async Operations
impact: HIGH
impactDescription: prevents client timeouts and enables progress tracking for long-running operations
tags: status, 202, async, location-header, background-jobs
---

## Return 202 Accepted for Async Operations

Long-running operations (report generation, bulk imports, video processing) must not block the HTTP request until completion. Return 202 Accepted immediately with a Location header pointing to a status endpoint the client can poll. This prevents gateway timeouts, gives clients progress visibility, and decouples request handling from job execution.

**Incorrect (blocks until the operation completes):**

```ruby
class Api::V1::ExportsController < ApplicationController
  def create
    export = current_user.exports.build(export_params)
    export.save!
    export.generate!  # blocks for 30-120 seconds — client times out, load balancer kills connection
    render json: ExportSerializer.new(export), status: :ok
  end
end
```

**Correct (returns 202 with status polling endpoint):**

```ruby
class Api::V1::ExportsController < ApplicationController
  def create
    export = current_user.exports.build(export_params)
    export.save!
    ExportJob.perform_later(export)  # background job handles the heavy work

    render json: {
      id: export.id,
      status: "processing",
      estimated_completion: 30.seconds.from_now.iso8601,
      _links: {
        self: { href: "/api/v1/exports/#{export.id}" },
        status: { href: "/api/v1/exports/#{export.id}/status" }  # poll this endpoint
      }
    }, status: :accepted,                                          # 202 — request accepted, not yet fulfilled
       location: api_v1_export_status_url(export)                  # Location header for client polling
  end
end

class Api::V1::Exports::StatusesController < ApplicationController
  def show
    export = current_user.exports.find(params[:export_id])

    response = {
      id: export.id,
      status: export.status,
      progress: export.progress_percentage,
      _links: { self: { href: "/api/v1/exports/#{export.id}/status" } }
    }

    if export.completed?
      response[:_links][:download] = { href: "/api/v1/exports/#{export.id}/download" }
    end

    render json: response, status: :ok
  end
end
```

```http
POST /api/v1/exports HTTP/1.1
Content-Type: application/json
Authorization: Bearer <token>

{ "format": "csv", "date_range": "2024-01-01..2024-12-31" }

HTTP/1.1 202 Accepted
Location: https://api.example.com/api/v1/exports/exp_abc/status
Content-Type: application/json

{
  "id": "exp_abc",
  "status": "processing",
  "estimated_completion": "2024-06-15T10:30:30Z",
  "_links": {
    "self": { "href": "/api/v1/exports/exp_abc" },
    "status": { "href": "/api/v1/exports/exp_abc/status" }
  }
}
```

```http
GET /api/v1/exports/exp_abc/status HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "exp_abc",
  "status": "completed",
  "progress": 100,
  "_links": {
    "self": { "href": "/api/v1/exports/exp_abc/status" },
    "download": { "href": "/api/v1/exports/exp_abc/download" }
  }
}
```

**Benefits:**
- No gateway timeouts -- the initial response returns in milliseconds
- Clients poll the status endpoint and show progress bars using `progress` field
- The `download` link only appears when the export completes, following HATEOAS state-driven navigation

**When NOT to use:** For operations that reliably complete under 1-2 seconds, synchronous responses are simpler and more predictable. Use 202 when operations routinely exceed 5 seconds.

**Reference:** RFC 9110 Section 15.3.3 (202 Accepted). See also `restful-hateoas:link-action-affordances` for conditional link exposure.
