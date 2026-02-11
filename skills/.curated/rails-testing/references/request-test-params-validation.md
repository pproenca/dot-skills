---
title: Test Parameter Validation and Edge Cases
impact: MEDIUM-HIGH
impactDescription: catches 3-5× more parameter edge cases than happy-path-only testing
tags: request, params, strong-parameters, validation, edge-cases
---

## Test Parameter Validation and Edge Cases

Request specs that only send valid parameters assume your strong params are correct and your error handling works — two assumptions that fail silently when a developer adds a new field but forgets to permit it, or when invalid input produces a 500 instead of a 422. Test the full parameter spectrum: valid params, missing required params, invalid format params, and extra unpermitted params that should be silently ignored.

**Incorrect (only testing with valid params):**

```ruby
RSpec.describe "Articles", type: :request do
  describe "POST /articles" do
    it "creates an article" do
      user = create(:user)
      sign_in(user)

      post articles_path, params: {
        article: { title: "Good Title", body: "Good body content", category: "tech" }
      }

      expect(response).to redirect_to(article_path(Article.last))
    end
  end

  describe "PATCH /articles/:id" do
    it "updates the article" do
      article = create(:article)
      sign_in(article.author)

      patch article_path(article), params: { article: { title: "Updated" } }

      expect(article.reload.title).to eq("Updated")
    end
  end
end
```

**Correct (testing valid, missing, invalid, and unpermitted params):**

```ruby
RSpec.describe "Articles", type: :request do
  describe "POST /articles" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    context "with valid params" do
      it "creates the article and redirects" do
        valid_params = { article: { title: "Testing Guide", body: "Detailed content", category: "tech" } }

        expect {
          post articles_path, params: valid_params
        }.to change(Article, :count).by(1)

        expect(response).to redirect_to(article_path(Article.last))
      end
    end

    context "with missing required params" do
      it "returns 422 when title is blank" do
        post articles_path, params: { article: { title: "", body: "Some body" } }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when body is missing entirely" do
        post articles_path, params: { article: { title: "No Body" } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid param formats" do
      it "returns 422 when category is not in allowed values" do
        invalid_params = { article: { title: "Valid", body: "Valid", category: "nonexistent" } }

        post articles_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with unpermitted params" do
      it "ignores unpermitted attributes and creates the article" do
        params_with_extras = {
          article: {
            title: "Testing Guide",
            body: "Content",
            category: "tech",
            author_id: create(:user, role: :admin).id,  # Attempt to assign a different author
            featured: true                                # Unpermitted field
          }
        }

        post articles_path, params: params_with_extras

        article = Article.last
        expect(article.author).to eq(user)    # author_id was ignored
        expect(article).not_to be_featured     # featured was ignored
      end
    end

    context "with malformed request body" do
      it "returns 400 when the article key is missing" do
        post articles_path, params: { title: "Orphaned" }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
```

Reference: [Action Controller Parameters — Rails Guides](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
