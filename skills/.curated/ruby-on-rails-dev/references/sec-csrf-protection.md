---
title: Enable CSRF Protection for All Form Submissions
impact: HIGH
impactDescription: prevents cross-site request forgery attacks
tags: sec, csrf, forgery-protection, forms
---

## Enable CSRF Protection for All Form Submissions

Without CSRF protection, attackers can trick authenticated users into performing actions. Rails includes CSRF tokens by default — never disable it.

**Incorrect (CSRF protection disabled):**

```ruby
class ApplicationController < ActionController::Base
  skip_forgery_protection  # Disables CSRF for ALL controllers
end
```

**Correct (CSRF enabled, API excluded):**

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

class Api::BaseController < ActionController::API
  # API controllers use token auth instead of CSRF
end
```

**Note:** For Turbo/Hotwire, CSRF tokens are handled automatically. Ensure `<%= csrf_meta_tags %>` is in your layout.

Reference: [Securing Rails Applications — Rails Guides](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
