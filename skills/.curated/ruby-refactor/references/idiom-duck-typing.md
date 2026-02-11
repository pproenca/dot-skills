---
title: Use respond_to? Over is_a? for Type Checking
impact: HIGH
impactDescription: enables polymorphism without inheritance hierarchy
tags: idiom, duck-typing, respond-to, polymorphism
---

## Use respond_to? Over is_a? for Type Checking

Checking `is_a?` couples code to a specific class hierarchy, breaking when you introduce adapters, decorators, or any object that quacks like the expected type but doesn't inherit from it. Duck typing is the Ruby way -- check behavior, not ancestry. This lets any object participate as long as it implements the expected protocol.

**Incorrect (type checking couples to class hierarchy):**

```ruby
class NotificationDispatcher
  def dispatch(destination, message)
    if destination.is_a?(String)  # breaks for StringIO, Pathname, or any string-like object
      send_to_email(destination, message)
    elsif destination.is_a?(Array)
      destination.each { |dest| dispatch(dest, message) }
    elsif destination.is_a?(User)  # breaks for AdminUser, GuestUser, or decorated users
      send_to_user(destination, message)
    else
      raise ArgumentError, "unsupported destination type: #{destination.class}"
    end
  end
end
```

**Correct (check behavior, not ancestry):**

```ruby
class NotificationDispatcher
  def dispatch(destination, message)
    if destination.respond_to?(:to_str)  # any string-like object works
      send_to_email(destination.to_str, message)
    elsif destination.respond_to?(:each)  # any enumerable works
      destination.each { |dest| dispatch(dest, message) }
    elsif destination.respond_to?(:email)  # any object with an email works
      send_to_user(destination, message)
    else
      raise ArgumentError, "destination must respond to :to_str, :each, or :email"
    end
  end
end
```
