---
title: Always Use Strong Parameters for Mass Assignment
impact: CRITICAL
impactDescription: prevents mass assignment vulnerabilities
tags: ctrl, strong-params, security, mass-assignment
---

## Always Use Strong Parameters for Mass Assignment

Passing raw params to model methods allows attackers to set any attribute, including `admin`, `role`, or `password`. Always whitelist permitted attributes.

**Incorrect (permits all params):**

```ruby
class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    @user.update(params[:user].permit!)  # Permits EVERYTHING including role, admin
  end
end
```

**Correct (explicit whitelist):**

```ruby
class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    @user.update(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
```

**Alternative (nested attributes):**

```ruby
def order_params
  params.require(:order).permit(
    :shipping_address,
    items_attributes: [:product_id, :quantity]
  )
end
```

Reference: [Action Controller Overview — Rails Guides](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
