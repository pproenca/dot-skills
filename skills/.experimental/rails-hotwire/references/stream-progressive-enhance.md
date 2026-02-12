---
title: Always Provide HTML Fallback for Streams
impact: HIGH
impactDescription: "prevents broken forms for non-JS clients and Turbo failures"
tags: stream, progressive-enhancement, forms, resilience
---

## Always Provide HTML Fallback for Streams

Turbo Stream responses only work when Turbo is loaded and the request includes the `text/vnd.turbo-stream.html` Accept header. If JavaScript fails to load, the user is on a degraded connection, or Turbo encounters an error, the form submission will receive no usable response. A `respond_to` block with both `turbo_stream` and `html` formats ensures every user gets a working experience regardless of client capabilities.

**Incorrect (only turbo_stream format, no fallback):**

```ruby
class CommentsController < ApplicationController
  def create
    @comment = @project.comments.build(comment_params)
    @comment.save

    respond_to do |format|
      format.turbo_stream
    end
  end
end
```

**Correct (turbo_stream with HTML redirect fallback):**

```ruby
class CommentsController < ApplicationController
  def create
    @comment = @project.comments.build(comment_params)

    if @comment.save
      respond_to do |format|
        format.turbo_stream # renders create.turbo_stream.erb
        format.html { redirect_to @project, notice: "Comment added." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_comment",
            partial: "comments/form",
            locals: { comment: @comment }
          )
        end
        format.html { render "projects/show", status: :unprocessable_entity }
      end
    end
  end
end
```
