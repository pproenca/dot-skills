---
title: Method Names Reflect Return Values
impact: MEDIUM
impactDescription: eliminates need for return-type comments
tags: style, naming, methods, self-documenting
---

## Method Names Reflect Return Values

Method names should tell the reader what they return and whether they produce side effects. As DHH notes, "collect implies returning an array; use create_mentions when ignoring the return value." Verbs like `create`, `update`, `send` imply side effects. Nouns and adjectives like `recipients`, `visible`, `total` imply a returned value. Use consistent domain language throughout — don't alternate between "container", "source", and "resource" for the same concept.

**Incorrect (names don't reflect return values or intent):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  # "process" — does it return something? cause side effects? both?
  def process_mentions
    body.scan(/@(\w+)/).flatten.map do |username|
      Person.find_by(username: username)
    end.compact
  end

  # "get" prefix is noise and doesn't clarify the return shape
  def get_data
    { subject: subject, body: body, author: creator.name }
  end

  # Inconsistent domain language — "recipients" here, "targets" elsewhere
  def compute_targets
    room.members.where.not(id: creator_id)
  end
end

# Calling code is confusing
mentions = message.process_mentions    # are mentions processed or returned?
message.get_data                       # "get" adds nothing
message.compute_targets                # "compute" implies heavy calculation
```

**Correct (names reveal return values and intent):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  # Noun — returns an array of mentioned people
  def mentioned_people
    body.scan(/@(\w+)/).flatten.filter_map do |username|
      Person.find_by(username: username)
    end
  end

  # "create" verb — side effect is clear, return value is secondary
  def create_mentions
    mentioned_people.each do |person|
      mentions.create!(person: person)
    end
  end

  # Noun — consistent with domain language used everywhere
  def recipients
    room.members.where.not(id: creator_id)
  end

  # Adjective — clearly returns a hash/summary representation
  def serialized
    { subject: subject, body: body, author: creator.name }
  end
end

# Calling code reads clearly
message.mentioned_people               # returns people
message.create_mentions                # creates records (side effect)
message.recipients                     # returns who receives this
```

**When NOT to use:**
- Standard Rails conventions override this rule. Methods like `save`, `valid?`, and `destroy` have well-established meanings in the framework. Don't rename them for consistency with this pattern.

Reference: DHH's code review patterns
