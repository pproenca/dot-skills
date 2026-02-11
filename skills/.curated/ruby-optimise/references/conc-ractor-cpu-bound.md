---
title: Use Ractors for CPU-Bound Parallelism
impact: MEDIUM
impactDescription: 2-8x throughput improvement on multi-core for CPU-bound work
tags: conc, ractor, parallel, cpu
---

## Use Ractors for CPU-Bound Parallelism

Ruby threads share the GVL, so CPU-bound work runs sequentially regardless of core count. Ractors provide isolated execution contexts that bypass the GVL, enabling true parallel computation across all available cores. Because Ractors are fully isolated, all computation logic must be self-contained inside the Ractor block.

**Incorrect (threads serialize CPU work due to GVL):**

```ruby
class ProductRecommendationEngine
  def compute_scores(user_profiles)
    threads = user_profiles.map do |profile|
      Thread.new do
        # GVL forces sequential execution despite multiple threads
        profile.preferences.combination(2).sum do |a, b|
          cosine_similarity(a, b)
        end
      end
    end

    threads.map(&:value)  # Runs at ~1 core speed regardless of thread count
  end
end
```

**Correct (Ractors achieve true parallelism across cores):**

```ruby
class ProductRecommendationEngine
  def compute_scores(user_profiles)
    ractors = user_profiles.map do |profile|
      prefs = Ractor.make_shareable(profile.preferences.dup)
      Ractor.new(prefs) do |preferences|
        # Self-contained computation — Ractor blocks cannot access outer scope
        preferences.combination(2).sum do |a, b|
          a.zip(b).sum { |x, y| x * y } /
            (Math.sqrt(a.sum { |v| v**2 }) * Math.sqrt(b.sum { |v| v**2 }))
        end
      end
    end

    ractors.map(&:take)  # Scales linearly with core count
  end
end
```

**When NOT to use this pattern:**
- Most gems and C extensions are not Ractor-safe — test thoroughly before adopting
- Ractors cannot share mutable state; all data passed in must be deeply frozen or copied via `Ractor.make_shareable`
- For I/O-bound concurrency, use Fibers or Threads instead — Ractors add unnecessary isolation overhead
- Ractors remain experimental in Ruby 3.x and are stabilizing in Ruby 4.0; verify compatibility with your Ruby version and gem dependencies before production use
