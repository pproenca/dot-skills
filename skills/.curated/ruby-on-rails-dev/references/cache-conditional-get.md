---
title: Use Conditional GET with stale? for HTTP Caching
impact: MEDIUM-HIGH
impactDescription: eliminates rendering on 304, 50-90% bandwidth reduction
tags: cache, etag, conditional-get, stale, http-caching
---

## Use Conditional GET with stale? for HTTP Caching

Rendering a response the client already has wastes server resources. `stale?` sends a 304 Not Modified when the resource hasn't changed, skipping view rendering entirely.

**Incorrect (always renders full response):**

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end
end
```

**Correct (conditional GET):**

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])

    if stale?(@article)
      respond_to do |format|
        format.html
        format.json { render json: @article }
      end
    end
  end
end
```

**Alternative (for collection endpoints):**

```ruby
def index
  @articles = Article.published.order(updated_at: :desc)

  if stale?(etag: @articles, last_modified: @articles.maximum(:updated_at))
    respond_to do |format|
      format.html
      format.json { render json: @articles }
    end
  end
end
```

Reference: [Caching with Rails — Rails Guides](https://guides.rubyonrails.org/caching_with_rails.html#conditional-get-support)
