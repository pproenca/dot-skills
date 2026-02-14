---
title: Single Layer for Business Logic
impact: HIGH
impactDescription: eliminates unnecessary application/domain layer separation
tags: arch, architecture, layers, simplicity
---

## Single Layer for Business Logic

Don't separate application and domain layers. Controllers call model methods directly — no interactors, use cases, or command patterns between them. Rails already provides the layering you need: controllers handle HTTP, models handle business logic. Adding an "application layer" between them creates ceremony without value.

**Incorrect (unnecessary layering between controller and model):**

```ruby
# app/use_cases/create_project.rb
class CreateProject
  def initialize(params:, user:)
    @params = params
    @user = user
  end

  def call
    project = Project.new(@params)
    project.creator = @user

    if project.save
      ProjectCreatedNotifier.new(project).notify
      Result.success(project)
    else
      Result.failure(project.errors)
    end
  end
end

# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  def create
    result = CreateProject.new(
      params: project_params,
      user: Current.user
    ).call

    if result.success?
      redirect_to result.value
    else
      @project = Project.new(project_params)
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Correct (controller calls model directly):**

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :memberships, dependent: :destroy

  after_create_commit :notify_team

  private

  def notify_team
    ProjectMailer.created(self).deliver_later
  end
end

# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  def create
    @project = Current.user.projects.build(project_params)

    if @project.save
      redirect_to @project
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @project = Current.user.projects.find(params[:id])

    if @project.update(project_params)
      redirect_to @project
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.expect(project: [:name, :description])
  end
end
```

**When NOT to use:**
- Simple CRUD is fine directly in controllers — don't create a model method just to wrap `update(params)`.
- Multi-model coordination that doesn't belong to any single model (e.g., onboarding flow creating User, Organization, and Subscription) may warrant a form object, but not an "application layer."

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
