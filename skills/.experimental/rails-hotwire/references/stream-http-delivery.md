---
title: Deliver Streams via HTTP for Form Responses
impact: MEDIUM-HIGH
impactDescription: "reduces complexity vs WebSocket for single-user updates"
tags: stream, http, forms, delivery-mechanism
---

## Deliver Streams via HTTP for Form Responses

Turbo Streams can be delivered over HTTP as the response to a form submission or over WebSocket via Action Cable. For the user who submitted the form, an HTTP stream response is simpler, faster, and does not require a persistent WebSocket connection. Reserve WebSocket broadcasts for pushing updates to other users who are viewing the same resource. Mixing these concerns leads to duplicate updates or unnecessary infrastructure.

**Incorrect (broadcasting over WebSocket for the submitting user's own update):**

```ruby
class MessagesController < ApplicationController
  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      # BAD: the submitting user will see their own message twice
      # (once from broadcast, once from page reload/redirect)
      Turbo::StreamsChannel.broadcast_append_to(
        @conversation,
        target: "messages",
        partial: "messages/message",
        locals: { message: @message }
      )
      redirect_to @conversation
    end
  end
end
```

**Correct (HTTP stream for the actor, broadcast for other users):**

```ruby
class MessagesController < ApplicationController
  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        # Actor gets the stream response directly via HTTP
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
      # Other users get the update via WebSocket broadcast
      @message.broadcast_append_later_to(
        @conversation,
        target: "messages",
        partial: "messages/message"
      )
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```
