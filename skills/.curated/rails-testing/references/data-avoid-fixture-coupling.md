---
title: Avoid Fixture Coupling Between Tests
impact: HIGH
impactDescription: prevents cascading test failures from shared mutable state across the suite
tags: data, fixtures, coupling, factories, isolation
---

## Avoid Fixture Coupling Between Tests

Fixtures are shared global state loaded once for the entire suite. When Test A depends on `users(:admin)` and someone modifies `fixtures/users.yml` for Test B, Test A breaks silently. Factories create isolated data per test — each test owns its setup and cannot be broken by changes to other tests. Fixtures also make it impossible to tell from reading a test what data it depends on.

**Incorrect (fixtures create invisible coupling between tests):**

```ruby
# test/fixtures/users.yml
admin:
  name: Admin User
  email: admin@example.com
  role: admin
  confirmed_at: <%= Time.current %>

member:
  name: Regular Member
  email: member@example.com
  role: member
  confirmed_at: <%= Time.current %>

# spec/models/authorization_spec.rb
RSpec.describe Authorization do
  fixtures :users, :projects

  describe "#can_delete?" do
    it "allows admins to delete projects" do
      # Reader must open fixtures/users.yml to understand what "admin" looks like
      # Changing the fixture for another test breaks this one
      auth = described_class.new(users(:admin))

      expect(auth.can_delete?(projects(:active_project))).to be true
    end
  end
end
```

**Correct (factories isolate each test's data):**

```ruby
RSpec.describe Authorization do
  describe "#can_delete?" do
    it "allows admins to delete projects" do
      admin = create(:user, :admin)
      project = create(:project)
      auth = described_class.new(admin)

      expect(auth.can_delete?(project)).to be true
    end

    it "denies members from deleting projects they do not own" do
      member = create(:user, role: :member)
      project = create(:project)  # owned by someone else
      auth = described_class.new(member)

      expect(auth.can_delete?(project)).to be false
    end

    it "allows members to delete their own projects" do
      member = create(:user, role: :member)
      project = create(:project, owner: member)
      auth = described_class.new(member)

      expect(auth.can_delete?(project)).to be true
    end
  end
end
```

**When fixtures are acceptable:**
- Reference/seed data that never changes (countries, currencies, permission definitions)
- Performance-critical CI suites where factory overhead is measured and significant

Reference: [Thoughtbot — Why Factories?](https://thoughtbot.com/blog/factory-bot)
