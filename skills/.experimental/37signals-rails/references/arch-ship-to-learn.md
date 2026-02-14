---
title: Ship to Learn — Prototype Quality is Valid
impact: HIGH
impactDescription: validates ideas 3-5x faster than polishing first
tags: arch, prototyping, ship-to-learn, iteration
---

## Ship to Learn — Prototype Quality is Valid

Merge prototype-quality implementations to production for real-world validation. Follow the three-phase cycle: Ship, Validate, Refine. Don't polish what hasn't been validated with real users. A working prototype in production teaches more in one week than a perfectly architected feature that never ships.

**Incorrect (over-engineering before validation):**

```ruby
# Weeks spent on a podcast feature nobody has used yet
# app/models/podcast.rb
class Podcast < ApplicationRecord
  include Transcribable
  include Searchable
  include Analytics::Trackable

  has_many :episodes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :recommendations, as: :recommendable

  scope :trending, -> { joins(:subscriptions)
    .where(subscriptions: { created_at: 30.days.ago.. })
    .group(:id)
    .order("COUNT(subscriptions.id) DESC") }

  # Full recommendation engine before anyone has even tried the feature
  def recommended_for(user)
    RecommendationEngine.new(user)
      .with_collaborative_filtering
      .with_content_similarity(self)
      .limit(10)
      .results
  end
end
```

**Correct (ship the core, validate, then refine):**

```ruby
# Phase 1: Ship — minimal working feature, merged to production
# app/models/podcast.rb
class Podcast < ApplicationRecord
  has_many :episodes

  def latest_episode
    episodes.order(published_at: :desc).first
  end
end

# app/controllers/podcasts_controller.rb
class PodcastsController < ApplicationController
  def index
    @podcasts = Podcast.order(created_at: :desc).limit(20)
  end

  def show
    @podcast = Podcast.find(params[:id])
    # TODO: After validating people use this, add subscriptions
    # TODO: Track analytics once we know which metrics matter
  end
end
```

Reference: [Shape Up — 37signals](https://basecamp.com/shapeup)
