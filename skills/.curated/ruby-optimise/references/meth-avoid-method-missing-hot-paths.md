---
title: Avoid method_missing in Hot Paths
impact: MEDIUM-HIGH
impactDescription: method_missing is 2-10x slower than direct dispatch
tags: meth, method-missing, dispatch, performance
---

## Avoid method_missing in Hot Paths

Ruby's `method_missing` bypasses the method lookup cache and triggers a full method resolution on every call. In hot paths this overhead compounds quickly, making it 2-10x slower than a direct method call. Generating real methods with `define_method` gives the VM a concrete dispatch target it can cache and optimize.

**Incorrect (full method resolution on every access):**

```ruby
class UserProfile
  def initialize(attrs)
    @attrs = attrs
  end

  def method_missing(name, *args)
    if @attrs.key?(name)
      @attrs[name]  # Triggers full method lookup chain every time
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    @attrs.key?(name) || super  # Must also be overridden for consistency
  end
end

# In a request loop — method_missing fires on each iteration
users.each do |user|
  profile = UserProfile.new(user)
  profile.email  # No cached dispatch, 2-10x slower per call
end
```

**Correct (generates real methods the VM can cache):**

```ruby
class UserProfile
  ATTRIBUTES = %i[email name role department].freeze

  def initialize(attrs)
    @attrs = attrs
  end

  ATTRIBUTES.each do |attr|
    define_method(attr) do
      @attrs[attr]
    end
  end
end

# In a request loop — direct dispatch, fully cacheable
users.each do |user|
  profile = UserProfile.new(user)
  profile.email  # Real method, normal dispatch speed
end
```
