---
title: Assert HTTP Status Codes Explicitly
impact: HIGH
impactDescription: catches 100% of silent 200-OK responses masking authorization failures
tags: request, http-status, assertions, response, have-http-status
---

## Assert HTTP Status Codes Explicitly

Checking only the response body hides entire categories of bugs. An endpoint that returns a 200 with an error message in the body looks successful to monitoring tools and load balancers. An endpoint that silently returns 302 instead of 401 masks a broken authentication check. Always assert the status code first, then the body. Use symbolic names (`:ok`, `:created`, `:not_found`) for readability — they make the test read like a specification.

**Incorrect (only checking body content, missing status assertions):**

```ruby
RSpec.describe "Articles API", type: :request do
  describe "GET /api/articles/:id" do
    it "returns the article" do
      article = create(:article, title: "Testing Rails")

      get api_article_path(article)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Testing Rails")
      # No status assertion — a 500 with the right body passes this test
    end
  end

  describe "DELETE /api/articles/:id" do
    it "deletes the article" do
      article = create(:article)

      delete api_article_path(article)

      expect(Article.find_by(id: article.id)).to be_nil
      # No status assertion — could be 200, 204, 302, or 500
    end
  end
end
```

**Correct (explicit status codes with symbolic names):**

```ruby
RSpec.describe "Articles API", type: :request do
  describe "GET /api/articles/:id" do
    it "returns the article with 200 OK" do
      article = create(:article, title: "Testing Rails")

      get api_article_path(article), headers: auth_headers_for(create(:user))

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("title" => "Testing Rails")
    end

    it "returns 404 when the article does not exist" do
      get api_article_path(id: "nonexistent"), headers: auth_headers_for(create(:user))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/articles" do
    it "returns 201 Created with the new article" do
      user = create(:user)
      params = { article: { title: "New Post", body: "Content here" } }

      post api_articles_path, params: params, headers: auth_headers_for(user)

      expect(response).to have_http_status(:created)
    end

    it "returns 422 Unprocessable Entity with validation errors" do
      user = create(:user)
      params = { article: { title: "", body: "" } }

      post api_articles_path, params: params, headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("errors")
    end
  end

  describe "DELETE /api/articles/:id" do
    it "returns 204 No Content after deletion" do
      article = create(:article)

      delete api_article_path(article), headers: auth_headers_for(article.author)

      expect(response).to have_http_status(:no_content)
    end
  end
end
```

Reference: [HTTP Status Codes — MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
