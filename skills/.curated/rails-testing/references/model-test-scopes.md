---
title: Test Scopes with Real Records
impact: HIGH
impactDescription: scopes generate SQL — test the query, not the definition
tags: model, scopes, query, activerecord, sql
---

## Test Scopes with Real Records

Scopes are query builders that generate SQL, and SQL behaves differently from Ruby. Testing the `.to_sql` string output only verifies syntax — it misses type coercion bugs, timezone mismatches, and NULL handling issues that only surface when the query actually executes against the database. Always create records that should match AND records that should not, then assert the scope returns exactly the right set.

**Incorrect (testing the SQL string instead of actual query behavior):**

```ruby
RSpec.describe Article, type: :model do
  describe ".published" do
    it "scopes to published articles" do
      expect(Article.published.to_sql).to include("published_at IS NOT NULL")
    end
  end

  describe ".recent" do
    it "orders by created_at" do
      expect(Article.recent.to_sql).to include("ORDER BY")
    end
  end
end
```

**Correct (real records with matching and non-matching data):**

```ruby
RSpec.describe Article, type: :model do
  describe ".published" do
    it "returns only articles with a published_at timestamp" do
      published = create(:article, published_at: 1.day.ago)
      draft = create(:article, published_at: nil)
      scheduled = create(:article, published_at: 1.day.from_now)

      expect(Article.published).to contain_exactly(published, scheduled)
    end
  end

  describe ".visible" do
    it "returns published articles that are not archived" do
      visible = create(:article, published_at: 1.day.ago, archived_at: nil)
      archived = create(:article, published_at: 1.day.ago, archived_at: 1.hour.ago)
      draft = create(:article, published_at: nil, archived_at: nil)

      expect(Article.visible).to contain_exactly(visible)
    end
  end

  describe ".recent" do
    it "returns articles from the last 30 days ordered newest first" do
      old = create(:article, created_at: 31.days.ago)
      newer = create(:article, created_at: 2.days.ago)
      newest = create(:article, created_at: 1.hour.ago)

      result = Article.recent

      expect(result).to eq([newest, newer])
      expect(result).not_to include(old)
    end
  end

  describe ".by_author" do
    it "returns only articles belonging to the specified author" do
      author = create(:user)
      their_article = create(:article, author: author)
      other_article = create(:article)

      expect(Article.by_author(author)).to contain_exactly(their_article)
    end
  end
end
```

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#scopes)
