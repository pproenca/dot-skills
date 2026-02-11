---
title: Rule Title Here
impact: MEDIUM
impactDescription: quantified impact (e.g., "2-10× improvement", "prevents N+1 queries")
tags: prefix, technique, related-concept
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences). Focus on performance or maintainability implications.

**Incorrect (description of the problem/cost):**

```ruby
# Bad code example — production-realistic
class OrdersController < ApplicationController
  def index
    @orders = Order.all  # Loads everything into memory
  end
end
```

**Correct (description of the benefit/solution):**

```ruby
# Good code example — minimal diff from incorrect
class OrdersController < ApplicationController
  def index
    @orders = Order.page(params[:page]).per(25)
  end
end
```

Reference: [Link to documentation](https://guides.rubyonrails.org/)
