---
title: Test Callback Side Effects, Not Callback Existence
impact: HIGH
impactDescription: prevents overtesting implementation details
tags: model, callbacks, side-effects, behavior, before-save
---

## Test Callback Side Effects, Not Callback Existence

Asserting that a callback is registered on a model couples your test to an implementation detail that can change freely during refactoring. The callback might be renamed, moved to a concern, or replaced by a service object — all without affecting observable behavior. Instead, test the outcome: what state or side effect does the callback produce? This keeps tests resilient to structural changes while still catching regressions.

**Incorrect (testing callback registration):**

```ruby
RSpec.describe User, type: :model do
  describe "callbacks" do
    it "has a before_save callback to set defaults" do
      callbacks = described_class._save_callbacks.select { |cb| cb.kind == :before }

      expect(callbacks.map(&:filter)).to include(:set_defaults)
    end

    it "has an after_create callback to send welcome email" do
      callbacks = described_class._create_callbacks.select { |cb| cb.kind == :after }

      expect(callbacks.map(&:filter)).to include(:send_welcome_email)
    end
  end
end
```

**Correct (testing observable side effects of callbacks):**

```ruby
RSpec.describe User, type: :model do
  describe "default role assignment" do
    it "assigns the member role when no role is specified" do
      user = create(:user, role: nil)

      expect(user.role).to eq("member")
    end

    it "preserves an explicitly set role" do
      user = create(:user, role: "admin")

      expect(user.role).to eq("admin")
    end
  end

  describe "slug generation" do
    it "generates a URL-safe slug from the username on save" do
      user = create(:user, username: "Jane Doe")

      expect(user.slug).to eq("jane-doe")
    end

    it "regenerates the slug when the username changes" do
      user = create(:user, username: "Jane Doe")

      user.update!(username: "Jane Smith")

      expect(user.slug).to eq("jane-smith")
    end
  end

  describe "welcome email on creation" do
    it "enqueues a welcome email after the user is created" do
      expect {
        create(:user, email: "new@example.com")
      }.to have_enqueued_mail(UserMailer, :welcome).with(a_hash_including(
        params: { user: an_instance_of(User) }
      ))
    end

    it "does not re-send welcome email on subsequent saves" do
      user = create(:user)

      expect {
        user.update!(name: "Updated Name")
      }.not_to have_enqueued_mail(UserMailer, :welcome)
    end
  end
end
```

Reference: [Active Record Callbacks — Rails Guides](https://guides.rubyonrails.org/active_record_callbacks.html)
