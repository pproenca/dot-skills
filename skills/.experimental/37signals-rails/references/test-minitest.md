---
title: Minitest Over RSpec
impact: MEDIUM
impactDescription: faster test suite, simpler DSL, standard Ruby
tags: test, minitest, rspec, testing
---

## Minitest Over RSpec

37signals uses Minitest exclusively across all projects. Minitest is plain Ruby — no domain-specific language to learn, no implicit matchers, and significantly faster boot times than RSpec. DHH has long advocated for Minitest's simplicity: tests are just Ruby classes with methods, assertions are just method calls. This eliminates the cognitive overhead of RSpec's `describe`/`context`/`it`/`let`/`subject` DSL and keeps the entire test suite understandable by anyone who knows Ruby.

**Incorrect (RSpec DSL with matcher overhead):**

```ruby
# spec/models/message_spec.rb
RSpec.describe Message, type: :model do
  subject(:message) { build(:message, room: room, creator: creator) }

  let(:room) { create(:room) }
  let(:creator) { create(:user) }

  describe "#publish" do
    it "sets the published_at timestamp" do
      freeze_time do
        message.publish
        expect(message.published_at).to eq(Time.current)
      end
    end

    it "marks the message as published" do
      message.publish
      expect(message).to be_published
    end

    it "touches the room's last activity" do
      expect { message.publish }.to change { room.reload.last_activity_at }
    end
  end

  describe "#unpublish" do
    before { message.publish }

    it "clears the published_at timestamp" do
      message.unpublish
      expect(message.published_at).to be_nil
    end
  end
end
```

**Correct (Minitest with plain Ruby assertions):**

```ruby
# test/models/message_test.rb
class MessageTest < ActiveSupport::TestCase
  setup do
    @message = messages(:draft)
    @room = @message.room
  end

  test "publish sets published_at to current time" do
    freeze_time do
      @message.publish
      assert_equal Time.current, @message.published_at
    end
  end

  test "publish marks message as published" do
    @message.publish
    assert @message.published?
  end

  test "publish touches room last activity" do
    assert_changes -> { @room.reload.last_activity_at } do
      @message.publish
    end
  end

  test "unpublish clears published_at" do
    @message.publish
    @message.unpublish
    assert_nil @message.published_at
  end
end
```

**Benefits:**
- Minitest boots faster — no heavyweight DSL to parse and load
- Tests read as plain Ruby, lowering the barrier for new team members
- Standard assertions (`assert_equal`, `assert_nil`, `assert_changes`) are explicit about what they check
- No implicit `subject`, no `let` lazy evaluation surprises, no matcher gems to manage

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
