---
title: Controller Concerns for Cross-Cutting Behavior
impact: HIGH
impactDescription: eliminates code duplication across controllers without inheritance
tags: ctrl, concerns, cross-cutting, authentication
---

## Controller Concerns for Cross-Cutting Behavior

Extract shared controller behavior into concerns rather than relying on deep controller inheritance hierarchies. Concerns like `Authenticatable`, `Accountable`, and `Turbo::Streamable` compose horizontally, letting each controller include only the behavior it needs. This avoids the fragile base class problem where changes to a parent controller break unrelated children.

**Incorrect (shared behavior duplicated or forced through inheritance):**

```ruby
# Deep inheritance hierarchy — fragile and hard to follow
class AuthenticatedController < ApplicationController
  before_action :require_authentication
end

class AccountScopedController < AuthenticatedController
  before_action :set_current_account
end

class AdminController < AccountScopedController
  before_action :require_admin
end

# Controllers forced into a single inheritance chain
class ProjectsController < AccountScopedController
  # Needs authentication + account scoping, but not admin
end

class ReportsController < AdminController
  # Inherits 3 layers of before_actions
  # Changing AccountScopedController breaks this too
end

# Duplicated behavior when inheritance doesn't fit
class Api::ProjectsController < ApplicationController
  before_action :require_authentication  # duplicated
  before_action :set_current_account     # duplicated

  private

  def require_authentication
    # Same logic copied from AuthenticatedController
    head :unauthorized unless Current.user
  end

  def set_current_account
    # Same logic copied from AccountScopedController
    Current.account = Current.user.accounts.find(params[:account_id])
  end
end
```

**Correct (composable concerns):**

```ruby
# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern
  included do
    before_action :require_authentication
  end
  private
  def require_authentication
    resume_session || request_authentication
  end
  def resume_session
    Current.session = Session.find_by(id: cookies.signed[:session_id])
  end
end

# app/controllers/concerns/accountable.rb
module Accountable
  extend ActiveSupport::Concern
  included do
    before_action :set_current_account
  end
  private
  def set_current_account
    Current.account = Current.user.accounts.find(params[:account_id])
  end
end

# app/controllers/concerns/admin_authorizable.rb
module AdminAuthorizable
  extend ActiveSupport::Concern
  included do
    before_action :require_admin
  end
  private
  def require_admin
    redirect_to root_path, alert: "Not authorized" unless Current.user.admin?
  end
end

# Controllers compose only what they need
class ProjectsController < ApplicationController
  include Authenticatable
  include Accountable
end
```

**When NOT to use:** If only one controller needs the behavior, inline it rather than extracting a concern prematurely. Concerns should emerge from duplication across two or more controllers.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
