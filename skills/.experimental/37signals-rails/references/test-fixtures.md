---
title: Database Fixtures Over FactoryBot
impact: MEDIUM
impactDescription: faster test setup, no runtime object construction overhead
tags: test, fixtures, factory-bot, test-data
---

## Database Fixtures Over FactoryBot

Use Rails database fixtures instead of FactoryBot factories. Fixtures are loaded once via bulk INSERT at the start of the test suite and wrapped in transactions — every test gets the same known dataset without per-test object construction. FactoryBot creates objects at runtime for each test, which compounds into significant slowdowns as the suite grows. Fixtures also force you to think about your data holistically rather than constructing narrow, isolated object graphs per test.

**Incorrect (FactoryBot with per-test object construction):**

```ruby
# spec/factories/messages.rb
FactoryBot.define do
  factory :message do
    body { "Hello world" }
    association :room
    association :creator, factory: :user

    trait :published do
      published_at { Time.current }
      status { "published" }
    end

    trait :with_attachments do
      after(:create) do |message|
        create_list(:attachment, 3, message: message)
      end
    end
  end
end

# spec/models/room_test.rb — each test creates its own object graph
class RoomTest < ActiveSupport::TestCase
  test "latest_message returns most recent published message" do
    room = create(:room)
    old_message = create(:message, :published, room: room, created_at: 1.day.ago)
    new_message = create(:message, :published, room: room, created_at: 1.hour.ago)
    draft = create(:message, room: room, status: "draft")

    assert_equal new_message, room.latest_message
  end
end
```

**Correct (fixtures loaded once, shared across all tests):**

```ruby
# test/fixtures/rooms.yml
developers:
  name: Developers
  last_activity_at: <%= 1.hour.ago.to_fs(:db) %>

design:
  name: Design
  last_activity_at: <%= 2.hours.ago.to_fs(:db) %>

# test/fixtures/messages.yml
welcome:
  body: Welcome to the room
  room: developers
  creator: david (User)
  published_at: <%= 1.day.ago.to_fs(:db) %>
  status: published

latest_update:
  body: Shipped the new deploy pipeline
  room: developers
  creator: jorge (User)
  published_at: <%= 1.hour.ago.to_fs(:db) %>
  status: published

work_in_progress:
  body: Still drafting this
  room: developers
  creator: david (User)
  published_at:
  status: draft

# test/models/room_test.rb — no object construction, just reference fixtures
class RoomTest < ActiveSupport::TestCase
  test "latest_message returns most recent published message" do
    room = rooms(:developers)
    assert_equal messages(:latest_update), room.latest_message
  end
end
```

**When NOT to use:**
- When testing with randomized or combinatorial data (e.g., property-based testing), dynamically constructed objects are appropriate since fixtures represent a fixed dataset.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
