---
title: Extract Complex Logic into Service Objects
impact: HIGH
impactDescription: reduces model size by 40-60%, improves testability
tags: model, service-objects, poro, single-responsibility
---

## Extract Complex Logic into Service Objects

When business logic spans multiple models or external services, it doesn't belong in any single model. Service objects encapsulate multi-step operations in testable POROs.

**Incorrect (multi-model logic in fat model):**

```ruby
class User < ApplicationRecord
  def register_with_team(team_name)
    transaction do
      save!
      team = Team.create!(name: team_name, owner: self)
      Membership.create!(user: self, team: team, role: "admin")
      TeamMailer.welcome(team).deliver_later
      AuditLog.record("user_registered", user: self, team: team)
    end
  end
end
```

**Correct (service object):**

```ruby
# app/services/users/register.rb
class Users::Register
  def initialize(user:, team_name:)
    @user = user
    @team_name = team_name
  end

  def call
    ActiveRecord::Base.transaction do
      @user.save!
      team = Team.create!(name: @team_name, owner: @user)
      Membership.create!(user: @user, team: team, role: "admin")
      TeamMailer.welcome(team).deliver_later
      AuditLog.record("user_registered", user: @user, team: team)
    end
  end
end
```

**Benefits:**
- Testable without creating a User first
- Reusable from controllers, jobs, and rake tasks
- Single responsibility per service

Reference: [Rails Service Objects — Toptal](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
