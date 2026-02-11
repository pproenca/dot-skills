---
title: Validate Data at the Model Level
impact: HIGH
impactDescription: prevents invalid data from reaching the database
tags: model, validations, data-integrity, activerecord
---

## Validate Data at the Model Level

Controller-level validation scatters checks across actions and misses data written by jobs or console. Model validations enforce rules at every entry point.

**Incorrect (validation in controller):**

```ruby
class UsersController < ApplicationController
  def create
    if params[:user][:email].blank? || !params[:user][:email].include?("@")
      flash[:alert] = "Invalid email"
      return render :new, status: :unprocessable_entity
    end

    @user = User.create!(user_params)  # No model validation — jobs bypass this
    redirect_to @user
  end
end
```

**Correct (validation in model):**

```ruby
# app/models/user.rb
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

Reference: [Active Record Validations — Rails Guides](https://guides.rubyonrails.org/active_record_validations.html)
