---
title: Scope before_action Callbacks with only/except
impact: HIGH
impactDescription: prevents unintended side effects on unrelated actions
tags: ctrl, callbacks, before-action, scoping
---

## Scope before_action Callbacks with only/except

Unscoped `before_action` runs on every action in the controller, including actions that don't need it. This causes unnecessary database queries and unexpected authorization failures.

**Incorrect (runs on every action):**

```ruby
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :authorize_admin

  def index; end
  def show; end
  def edit; end
  def update; end
end
```

**Correct (scoped to relevant actions):**

```ruby
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update]
  before_action :authorize_admin, only: [:edit, :update]

  def index; end
  def show; end
  def edit; end
  def update; end

  private

  def set_project
    @project = Project.find(params[:id])
  end
end
```

Reference: [Action Controller Overview — Rails Guides](https://guides.rubyonrails.org/action_controller_overview.html#filters)
