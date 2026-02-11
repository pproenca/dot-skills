---
title: Always Pair method_missing with respond_to_missing?
impact: MEDIUM-HIGH
impactDescription: prevents broken respond_to? and method introspection
tags: idiom, method-missing, respond-to-missing, metaprogramming
---

## Always Pair method_missing with respond_to_missing?

Defining `method_missing` without `respond_to_missing?` creates objects that handle messages they claim not to understand. This breaks `respond_to?`, `method(:name)`, and any library that checks capabilities before calling. The pair ensures Ruby's introspection protocol stays consistent.

**Incorrect (method_missing without respond_to_missing?):**

```ruby
class DynamicConfig
  def initialize(settings)
    @settings = settings
  end

  def method_missing(name, *args)
    if @settings.key?(name)
      @settings[name]
    else
      super
    end
  end
end

config = DynamicConfig.new(database_url: "postgres://localhost/app")
config.database_url          # => "postgres://localhost/app"
config.respond_to?(:database_url)  # => false — introspection is broken
config.method(:database_url)       # => raises NameError
```

**Correct (method_missing paired with respond_to_missing?):**

```ruby
class DynamicConfig
  def initialize(settings)
    @settings = settings
  end

  def method_missing(name, *args)
    if @settings.key?(name)
      @settings[name]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)  # must mirror method_missing logic
    @settings.key?(name) || super
  end
end

config = DynamicConfig.new(database_url: "postgres://localhost/app")
config.database_url          # => "postgres://localhost/app"
config.respond_to?(:database_url)  # => true — introspection works correctly
config.method(:database_url)       # => #<Method: DynamicConfig#database_url>
```
