---
title: Whitelist Permitted Params, Never Blacklist
impact: HIGH
impactDescription: prevents mass assignment of sensitive attributes
tags: sec, strong-params, whitelist, mass-assignment
---

## Whitelist Permitted Params, Never Blacklist

Blacklisting attributes misses new columns added later. Whitelisting ensures only intended attributes are assignable.

**Incorrect (blacklist approach):**

```ruby
def user_params
  params.require(:user).permit!.except(:admin, :role)  # New sensitive columns are exposed
end
```

**Correct (whitelist approach):**

```ruby
def user_params
  params.require(:user).permit(:name, :email, :avatar, :bio)
end
```

**Alternative (context-dependent params):**

```ruby
def user_params
  if current_user.admin?
    params.require(:user).permit(:name, :email, :avatar, :bio, :role)
  else
    params.require(:user).permit(:name, :email, :avatar, :bio)
  end
end
```

Reference: [Action Controller Overview — Rails Guides](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
