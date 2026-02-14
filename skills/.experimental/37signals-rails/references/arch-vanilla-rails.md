---
title: Vanilla Rails is Plenty
impact: CRITICAL
impactDescription: reduces gem dependencies and eliminates maintenance burden
tags: arch, vanilla-rails, dependencies, conventions
---

## Vanilla Rails is Plenty

Maximize Rails built-ins before adding gems. Rails ships with comprehensive primitives — `delegated_type`, `store_accessor`, `normalizes`, `params.expect`, `generates_token_for` — that replace entire categories of gems. Every gem added is a maintenance liability: version conflicts, security patches, abandoned projects, and API churn.

**Incorrect (gem for every feature):**

```ruby
# Gemfile
gem "friendly_id"         # slugs
gem "strip_attributes"    # normalization
gem "store_model"         # JSON attributes
gem "strong_migrations"   # migration safety
gem "pundit"              # authorization

# app/models/article.rb
class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  strip_attributes only: [:title, :summary]
end
```

**Correct (vanilla Rails primitives):**

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  # Built-in slug generation
  before_validation :generate_slug, on: :create

  # Rails 7.1 normalizes replaces strip_attributes
  normalizes :title, with: -> { _1.strip }
  normalizes :summary, with: -> { _1.strip.gsub(/\s+/, " ") }

  # Rails store_accessor replaces store_model
  store_accessor :metadata, :reading_time, :featured_image_url

  private

  def generate_slug
    self.slug = title.parameterize
  end
end

# Controller uses params.expect (Rails 8) instead of strong_parameters ceremony
def article_params
  params.expect(article: [:title, :summary, :body, metadata: [:reading_time]])
end
```

**Benefits:**
- Fewer dependencies to audit, update, and debug
- No version lock-in or abandonment risk
- Team reads one codebase (Rails), not dozens of gem APIs
- Upgrades are simpler with fewer moving parts

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
