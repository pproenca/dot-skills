---
title: Use Request Specs over Controller Specs
impact: HIGH
impactDescription: exercises full HTTP stack including routing and middleware
tags: request, controller-specs, request-specs, http, middleware, routing
---

## Use Request Specs over Controller Specs

Controller specs bypass routing, middleware, and Rack processing — they call controller actions directly as methods, which means your tests never exercise the code path that production traffic actually hits. Since Rails 5.1, the Rails team officially recommends request specs, and `assigns` and `assert_template` are no longer available without an extra gem. Request specs catch routing typos, middleware misconfiguration, and parameter parsing bugs that controller specs silently miss.

**Incorrect (deprecated controller spec style):**

```ruby
RSpec.describe UsersController, type: :controller do
  describe "GET #index" do
    it "returns a successful response" do
      get :index

      expect(response).to be_successful
      expect(assigns(:users)).to eq(User.all)  # assigns is deprecated
    end
  end

  describe "POST #create" do
    it "creates a user" do
      post :create, params: { user: { name: "Jane", email: "jane@example.com" } }

      expect(assigns(:user)).to be_persisted
      expect(response).to redirect_to(user_path(assigns(:user)))
    end
  end
end
```

**Correct (request spec exercising the full HTTP stack):**

```ruby
RSpec.describe "Users", type: :request do
  describe "GET /users" do
    it "returns a successful response" do
      create_list(:user, 3)

      get users_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "creates a user and redirects to the user page" do
      valid_params = { user: { name: "Jane", email: "jane@example.com" } }

      expect {
        post users_path, params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(user_path(User.last))
    end

    it "returns unprocessable entity with invalid params" do
      invalid_params = { user: { name: "", email: "" } }

      post users_path, params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
```

Reference: [RSpec Rails Request Specs — rspec.info](https://rspec.info/features/7-0/rspec-rails/request-specs/request-spec/)
