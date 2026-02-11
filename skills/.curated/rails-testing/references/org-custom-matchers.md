---
title: Extract Custom Matchers for Domain Assertions
impact: LOW-MEDIUM
impactDescription: improves readability for repeated domain-specific multi-line checks
tags: org, custom-matchers, readability, domain, rspec-matchers
---

## Extract Custom Matchers for Domain Assertions

When the same multi-line assertion appears across three or more specs, the duplication is a signal that the concept deserves a name. Custom RSpec matchers encapsulate domain-specific checks behind expressive predicates like `be_publishable` or `have_valid_address`, making the test's intent immediately clear. The matcher also centralizes the failure message, so when the assertion fails it explains what went wrong in domain terms rather than showing a raw attribute comparison.

**Incorrect (multi-line assertion repeated across specs — intent is buried in details):**

```ruby
# spec/models/article_spec.rb
RSpec.describe Article do
  describe "#ready_for_review?" do
    it "returns true when article meets all criteria" do
      article = create(:article, :with_body, author: create(:author))

      expect(article.title).to be_present
      expect(article.body.length).to be >= 300
      expect(article.author).to be_present
      expect(article.categories.count).to be >= 1
      expect(article.cover_image).to be_attached
    end
  end
end

# spec/services/editorial_workflow_spec.rb — same checks duplicated
RSpec.describe EditorialWorkflow do
  describe "#submit" do
    it "accepts articles that are ready for review" do
      article = create(:article, :complete)

      # Same five assertions copied from another spec
      expect(article.title).to be_present
      expect(article.body.length).to be >= 300
      expect(article.author).to be_present
      expect(article.categories.count).to be >= 1
      expect(article.cover_image).to be_attached
    end
  end
end
```

**Correct (custom matcher encapsulates domain concept with clear failure message):**

```ruby
# spec/support/matchers/be_ready_for_review.rb
RSpec::Matchers.define :be_ready_for_review do
  match do |article|
    article.title.present? &&
      article.body.to_s.length >= 300 &&
      article.author.present? &&
      article.categories.any? &&
      article.cover_image.attached?
  end

  failure_message do |article|
    missing = []
    missing << "title is blank" if article.title.blank?
    missing << "body is too short (#{article.body.to_s.length}/300 chars)" if article.body.to_s.length < 300
    missing << "author is missing" if article.author.blank?
    missing << "no categories assigned" if article.categories.empty?
    missing << "cover image not attached" unless article.cover_image.attached?

    "expected article to be ready for review, but: #{missing.join(', ')}"
  end
end

# spec/models/article_spec.rb
RSpec.describe Article do
  describe "#ready_for_review?" do
    it "returns true when article meets all editorial criteria" do
      article = create(:article, :complete)

      expect(article).to be_ready_for_review
    end

    it "fails when the body is too short" do
      article = create(:article, :complete, body: "Too short.")

      expect(article).not_to be_ready_for_review
    end
  end
end

# spec/services/editorial_workflow_spec.rb — same matcher, single line
RSpec.describe EditorialWorkflow do
  describe "#submit" do
    it "accepts articles that are ready for review" do
      article = create(:article, :complete)

      expect(article).to be_ready_for_review
      expect(described_class.new.submit(article)).to be_success
    end
  end
end
```

Reference: [RSpec Custom Matchers](https://rspec.info/features/3-12/rspec-expectations/custom-matchers/define-matcher/) | [thoughtbot — Writing Custom RSpec Matchers](https://thoughtbot.com/blog/testing-your-factories-first)
