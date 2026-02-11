---
title: Reserve System Tests for Critical User Journeys
impact: MEDIUM
impactDescription: system tests are 10-100x slower than unit tests — overuse destroys CI speed
tags: system, test-pyramid, coverage, performance, critical-path
---

## Reserve System Tests for Critical User Journeys

System tests launch a real browser, render JavaScript, and round-trip through the full stack — they are the most expensive tests to run. Following the test pyramid, use system tests only for complete user journeys that cross multiple components (signup, checkout, onboarding). Cover individual endpoints, validations, and edge cases with request specs and model specs where feedback is 10-100x faster.

**Incorrect (system tests for every CRUD action and edge case):**

```ruby
# Dozens of system tests covering what request/model specs handle better
RSpec.describe "Articles management", type: :system do
  it "shows validation error when title is blank" do
    sign_in create(:admin)
    visit new_admin_article_path
    fill_in "Body", with: "Some content"
    click_on "Publish"

    expect(page).to have_content("Title can't be blank")
  end

  it "shows validation error when body is too short" do
    sign_in create(:admin)
    visit new_admin_article_path
    fill_in "Title", with: "Test"
    fill_in "Body", with: "Hi"
    click_on "Publish"

    expect(page).to have_content("Body is too short")
  end

  it "paginates articles on the index page" do
    create_list(:article, 30, :published)
    visit articles_path

    expect(page).to have_css("article", count: 20)
    click_on "Next"
    expect(page).to have_css("article", count: 10)
  end
end
```

**Correct (system tests for critical journeys, request/model specs for the rest):**

```ruby
# spec/system/article_publishing_spec.rb — critical end-to-end journey
RSpec.describe "Article publishing workflow", type: :system do
  it "allows an admin to write, preview, and publish an article" do
    admin = create(:admin)
    sign_in admin

    visit new_admin_article_path
    fill_in "Title", with: "Deploying Rails 8 with Kamal"
    fill_in "Body", with: "A comprehensive guide to modern Rails deployment..."
    click_on "Preview"

    expect(page).to have_content("Deploying Rails 8 with Kamal")
    click_on "Publish"

    expect(page).to have_content("Article published successfully")
    expect(page).to have_current_path(article_path(Article.last))
  end
end

# spec/models/article_spec.rb — validations at unit level
RSpec.describe Article, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:body).is_at_least(50) }
end

# spec/requests/articles_spec.rb — pagination at request level
RSpec.describe "GET /articles", type: :request do
  it "paginates results with 20 per page" do
    create_list(:article, 25, :published)

    get articles_path

    expect(response.parsed_body["articles"].size).to eq(20)
  end
end
```

Reference: [The Practical Test Pyramid — Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html) | [Evil Martians — System of a Test](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-tests)
