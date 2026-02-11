---
title: Never Interpolate User Input in SQL
impact: CRITICAL
impactDescription: "prevents SQL injection (CVSS 10.0, OWASP A03)"
tags: sec, sql-injection, parameterized-queries, sanitization
---

## Never Interpolate User Input in SQL

String interpolation in SQL allows attackers to execute arbitrary queries. Always use parameterized queries or ActiveRecord's safe query methods.

**Incorrect (SQL injection vulnerability):**

```ruby
class SearchController < ApplicationController
  def index
    @users = User.where("name LIKE '%#{params[:query]}%'")  # SQL injection
  end
end
```

**Correct (parameterized query):**

```ruby
class SearchController < ApplicationController
  def index
    @users = User.where("name LIKE ?", "%#{params[:query]}%")
  end
end
```

**Alternative (sanitize for LIKE):**

```ruby
@users = User.where("name LIKE ?", "%#{User.sanitize_sql_like(params[:query])}%")
```

Reference: [Securing Rails Applications — Rails Guides](https://guides.rubyonrails.org/security.html#sql-injection)
