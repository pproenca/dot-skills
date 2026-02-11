---
title: Assert JSON Response Structure
impact: MEDIUM-HIGH
impactDescription: catches 100% of API contract regressions that string matching misses
tags: request, json, api, response-body, contract, serialization
---

## Assert JSON Response Structure

API consumers depend on the shape of your JSON responses — a renamed key, a missing nested object, or a changed type breaks client applications silently. String inclusion checks like `expect(response.body).to include("user")` pass even when the structure is completely wrong (it matches inside any string value). Parse the JSON and assert on the structure with specific key expectations, ensuring your API contract is tested as precisely as your status codes.

**Incorrect (string matching on raw response body):**

```ruby
RSpec.describe "Users API", type: :request do
  describe "GET /api/users/:id" do
    it "returns user data" do
      user = create(:user, name: "Jane Doe", email: "jane@example.com")

      get api_user_path(user), headers: auth_headers

      expect(response.body).to include("Jane Doe")
      expect(response.body).to include("jane@example.com")
      # Passes even if structure is { "error": "jane@example.com not found" }
    end
  end

  describe "GET /api/users" do
    it "returns users" do
      create_list(:user, 3)

      get api_users_path, headers: auth_headers

      expect(response.body).to include("user")
      # Matches literally anything containing the substring "user"
    end
  end
end
```

**Correct (parsed JSON with structural assertions):**

```ruby
RSpec.describe "Users API", type: :request do
  describe "GET /api/users/:id" do
    it "returns the user with expected attributes" do
      user = create(:user, name: "Jane Doe", email: "jane@example.com")

      get api_user_path(user), headers: auth_headers

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json).to include(
        "id" => user.id,
        "name" => "Jane Doe",
        "email" => "jane@example.com",
        "created_at" => user.created_at.as_json
      )
    end

    it "does not expose sensitive attributes" do
      user = create(:user)

      get api_user_path(user), headers: auth_headers

      json = response.parsed_body
      expect(json.keys).not_to include("password_digest", "reset_token", "otp_secret")
    end
  end

  describe "GET /api/users" do
    it "returns a paginated collection with metadata" do
      create_list(:user, 3)

      get api_users_path, params: { page: 1, per_page: 2 }, headers: auth_headers

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json["data"].length).to eq(2)
      expect(json["data"].first).to include("id", "name", "email")
      expect(json["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 2,
        "total_count" => 3
      )
    end
  end

  describe "POST /api/users" do
    it "returns the created resource with a location header" do
      params = { user: { name: "New User", email: "new@example.com", password: "securepass123" } }

      post api_users_path, params: params, headers: auth_headers

      expect(response).to have_http_status(:created)

      json = response.parsed_body
      expect(json).to include("id", "name", "email")
      expect(json).not_to include("password", "password_digest")
      expect(response.headers["Location"]).to eq(api_user_url(json["id"]))
    end

    it "returns structured validation errors" do
      params = { user: { name: "", email: "invalid" } }

      post api_users_path, params: params, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)

      json = response.parsed_body
      expect(json["errors"]).to include(
        a_hash_including("field" => "name", "message" => "can't be blank"),
        a_hash_including("field" => "email", "message" => "is invalid")
      )
    end
  end
end
```

Reference: [RSpec Rails Request Specs — rspec.info](https://rspec.info/features/7-0/rspec-rails/request-specs/request-spec/)
