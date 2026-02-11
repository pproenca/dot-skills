---
title: Use Shared Examples Sparingly
impact: LOW-MEDIUM
impactDescription: shared examples sacrifice readability for DRY purity in test code
tags: org, shared-examples, dry, readability, duplication
---

## Use Shared Examples Sparingly

Shared examples move test logic into a separate file, forcing readers to jump between locations to understand what a test actually does. This is the wrong trade-off in test code, where clarity matters more than DRY. Reserve shared examples for true behavioral contracts — interface compliance across multiple implementations, standardized API response formats, or authorization patterns that genuinely share identical behavior. For slight variations, prefer inline duplication where each spec reads top-to-bottom without context-switching.

**Incorrect (shared examples for slight variations — test reads like a treasure hunt):**

```ruby
# spec/support/shared_examples/publishable.rb
RSpec.shared_examples "a publishable resource" do |factory_name|
  describe "#publish!" do
    it "sets published_at" do
      resource = create(factory_name)
      resource.publish!

      expect(resource.published_at).to be_present
    end

    it "sends a notification" do
      resource = create(factory_name)

      expect { resource.publish! }.to have_enqueued_job(NotificationJob)
    end
  end
end

# spec/models/article_spec.rb — reader must find the shared example file to understand the test
RSpec.describe Article, type: :model do
  it_behaves_like "a publishable resource", :article
end

# spec/models/podcast_spec.rb
RSpec.describe Podcast, type: :model do
  it_behaves_like "a publishable resource", :podcast
  # But podcasts also require audio processing before publish...
  # Now the shared example needs conditionals or parameters, adding complexity
end
```

**Correct (inline tests with minor duplication — each spec reads independently):**

```ruby
# spec/models/article_spec.rb
RSpec.describe Article, type: :model do
  describe "#publish!" do
    it "sets the published_at timestamp" do
      article = create(:article, published_at: nil)

      article.publish!

      expect(article.published_at).to be_within(1.second).of(Time.current)
    end

    it "enqueues a notification to subscribers" do
      article = create(:article, author: create(:author, :with_subscribers))

      expect { article.publish! }.to have_enqueued_job(NotificationJob)
        .with(article.id, "article_published")
    end
  end
end

# spec/models/podcast_spec.rb — similar but with domain-specific differences inline
RSpec.describe Podcast, type: :model do
  describe "#publish!" do
    it "sets the published_at timestamp after audio processing completes" do
      podcast = create(:podcast, :audio_processed, published_at: nil)

      podcast.publish!

      expect(podcast.published_at).to be_within(1.second).of(Time.current)
    end

    it "enqueues a notification and an RSS feed update" do
      podcast = create(:podcast, :audio_processed)

      expect { podcast.publish! }.to have_enqueued_job(NotificationJob)
        .and have_enqueued_job(RssFeedUpdateJob)
    end
  end
end

# Reserve shared examples for true contracts, e.g., API response format:
# RSpec.shared_examples "a paginated JSON response" do
#   it { expect(response.parsed_body).to have_key("data") }
#   it { expect(response.parsed_body).to have_key("meta") }
#   it { expect(response.parsed_body["meta"]).to have_key("total_count") }
# end
```

Reference: [Better Specs — Shared Examples](https://www.betterspecs.org/) | [RSpec Shared Examples](https://rspec.info/features/3-12/rspec-core/example-groups/shared-examples/)
