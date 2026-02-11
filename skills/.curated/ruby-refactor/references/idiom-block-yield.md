---
title: Use yield Over block.call for Simple Blocks
impact: MEDIUM-HIGH
impactDescription: avoids Proc allocation, 2-5x faster
tags: idiom, yield, blocks, performance
---

## Use yield Over block.call for Simple Blocks

Capturing a block with `&block` forces Ruby to allocate a Proc object on every call, even when you only need to invoke it once. `yield` passes control directly without allocation, making it 2-5x faster. Reserve `&block` for when you need to store, forward, or inspect the block.

**Incorrect (unnecessary Proc allocation via &block):**

```ruby
class EventProcessor
  def process(events, &block)
    events.each do |event|
      result = block.call(event)  # allocates Proc on every call to process
      log_result(event, result)
    end
  end

  def with_retry(max_attempts:, &block)
    attempts = 0
    begin
      attempts += 1
      block.call  # Proc allocated unnecessarily
    rescue TransientError => e
      retry if attempts < max_attempts
      raise
    end
  end
end
```

**Correct (yield avoids Proc allocation):**

```ruby
class EventProcessor
  def process(events)
    events.each do |event|
      result = yield event  # no Proc allocated, 2-5x faster
      log_result(event, result)
    end
  end

  def with_retry(max_attempts:)
    attempts = 0
    begin
      attempts += 1
      yield  # direct dispatch, no allocation
    rescue TransientError => e
      retry if attempts < max_attempts
      raise
    end
  end

  def on_complete(&block)  # &block is correct here — storing for later
    @on_complete = block
  end
end
```
