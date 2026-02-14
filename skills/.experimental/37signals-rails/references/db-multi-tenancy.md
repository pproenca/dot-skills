---
title: Path-Based Multi-Tenancy with Current.account
impact: HIGH
impactDescription: automatic tenant isolation across queries, broadcasts, and jobs
tags: db, multi-tenancy, current, tenant
---

## Path-Based Multi-Tenancy with Current.account

Use path-based tenancy (`/{account_id}/...`) with middleware that sets `Current.account` on every request. Access data through `Current.account` associations (`Current.account.recordings`) rather than manual `where(account_id:)` calls. Background jobs automatically preserve tenant context through `CurrentAttributes` serialization. No external tenant management gems needed.

**Incorrect (manual tenant scoping scattered across the codebase):**

```ruby
# app/controllers/recordings_controller.rb — manual scoping in every action
class RecordingsController < ApplicationController
  before_action :set_account

  def index
    # Must remember to scope every query — a single miss leaks data
    @recordings = Recording.where(account_id: @account.id)
  end

  def create
    @recording = Recording.new(recording_params)
    @recording.account_id = @account.id  # easy to forget
    @recording.save!
    redirect_to @recording
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
```

**Correct (Current.account with association-based scoping):**

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user, :session
end

# app/controllers/concerns/account_scoped.rb
module AccountScoped
  extend ActiveSupport::Concern
  included do
    prepend_before_action :set_current_account
  end
  private
  def set_current_account
    Current.account = Account.find(params[:account_id])
  end
end

# app/controllers/recordings_controller.rb
class RecordingsController < ApplicationController
  include AccountScoped

  def index
    @recordings = Current.account.recordings
  end

  def create
    @recording = Current.account.recordings.create!(recording_params)
    redirect_to @recording
  end
end

# config/routes.rb
scope "/:account_id" do
  resources :recordings
end
```

**When NOT to use:**
- Single-tenant applications (personal tools, internal dashboards) do not need Current.account scoping. Only introduce multi-tenancy when multiple organizations share the same application instance.

Reference: [Basecamp Fizzy AGENTS.md](https://github.com/basecamp/fizzy/blob/main/AGENTS.md)
