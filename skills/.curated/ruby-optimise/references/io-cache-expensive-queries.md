---
title: Cache Expensive Database Results
impact: MEDIUM
impactDescription: eliminates repeated identical queries across requests
tags: io, caching, rails-cache, queries
---

## Cache Expensive Database Results

Expensive aggregate queries or complex joins that produce the same result across multiple requests waste database resources when executed repeatedly. Use `Rails.cache.fetch` with a time-based expiry to serve cached results and only hit the database when the cache expires.

**Incorrect (runs expensive query on every request):**

```ruby
class ProductCatalogController < ApplicationController
  def index
    @categories = Category.all
      .joins(:products)
      .select("categories.*, COUNT(products.id) AS product_count")
      .group("categories.id")
      .order("product_count DESC")  # complex join + aggregation on every page load

    @featured = Product.where(featured: true)
      .includes(:reviews)
      .order(average_rating: :desc)
      .limit(12)  # repeated on every request despite rarely changing
  end
end
```

**Correct (caches results with appropriate expiry):**

```ruby
class ProductCatalogController < ApplicationController
  def index
    @categories = Rails.cache.fetch("catalog:categories_with_counts", expires_in: 15.minutes) do
      Category.all
        .joins(:products)
        .select("categories.*, COUNT(products.id) AS product_count")
        .group("categories.id")
        .order("product_count DESC")
        .to_a  # materialize to Array so it is serializable
    end

    @featured = Rails.cache.fetch("catalog:featured_products", expires_in: 1.hour) do
      Product.where(featured: true)
        .includes(:reviews)
        .order(average_rating: :desc)
        .limit(12)
        .to_a
    end
  end
end
```
