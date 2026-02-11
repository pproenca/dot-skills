---
title: Avoid Class Methods in Domain Logic
impact: MEDIUM-HIGH
impactDescription: class methods resist stubbing and polymorphism
tags: couple, class-methods, testability, instance-methods
---

## Avoid Class Methods in Domain Logic

Class methods are global entry points that cannot be injected, subclassed cleanly, or mocked without stubbing the class itself. This makes tests brittle and prevents polymorphic dispatch. Converting to an instance method behind a conventional `#call` interface lets callers inject, decorate, and substitute the object freely.

**Incorrect (class method locks callers to a single global implementation):**

```ruby
class UserImporter
  def self.import(csv_data)
    # Cannot inject a different parser or notifier — stubbing requires global patch
    rows = CSV.parse(csv_data, headers: true)
    rows.each do |row|
      user = User.create!(name: row["name"], email: row["email"])
      AdminMailer.notify_new_user(user)
    end
  end
end

# Caller
UserImporter.import(csv_data)
```

**Correct (instance-based with injectable collaborators):**

```ruby
class UserImporter
  def initialize(csv_data, parser: CSV, notifier: AdminMailer)
    @csv_data = csv_data
    @parser = parser
    @notifier = notifier
  end

  # Instance method — injectable, decoratable, polymorphic
  def call
    rows = @parser.parse(@csv_data, headers: true)
    rows.each do |row|
      user = User.create!(name: row["name"], email: row["email"])
      @notifier.notify_new_user(user)
    end
  end
end

# Caller — same brevity, full flexibility
UserImporter.new(csv_data).call

# Test — no global stubs
fake_notifier = instance_double(AdminMailer)
allow(fake_notifier).to receive(:notify_new_user)
UserImporter.new(csv_data, notifier: fake_notifier).call
```
