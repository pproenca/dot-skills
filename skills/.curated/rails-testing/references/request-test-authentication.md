---
title: Test Authentication Boundaries
impact: HIGH
impactDescription: verifies that protected endpoints reject unauthenticated requests
tags: request, authentication, authorization, security, unauthenticated
---

## Test Authentication Boundaries

Every authenticated endpoint must be tested from both sides of the authentication boundary: logged in and not logged in. Testing only the happy path with a signed-in user means a missing `before_action :authenticate_user!` goes undetected until production, leaving sensitive data exposed. The unauthenticated context should always come first — it documents the security contract before the functional behavior.

**Incorrect (only testing the happy path with a logged-in user):**

```ruby
RSpec.describe "Projects", type: :request do
  describe "GET /projects" do
    it "lists the user's projects" do
      user = create(:user)
      sign_in(user)
      create_list(:project, 3, owner: user)

      get projects_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /projects" do
    it "creates a new project" do
      user = create(:user)
      sign_in(user)

      post projects_path, params: { project: { name: "My App" } }

      expect(response).to redirect_to(project_path(Project.last))
    end
  end
  # No test for what happens when the user is NOT signed in
end
```

**Correct (unauthenticated and authenticated contexts for every endpoint):**

```ruby
RSpec.describe "Projects", type: :request do
  describe "GET /projects" do
    context "when not authenticated" do
      it "redirects to the sign-in page" do
        get projects_path

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      it "returns the user's projects" do
        user = create(:user)
        sign_in(user)
        create_list(:project, 3, owner: user)

        get projects_path

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /projects/:id" do
    context "when not authenticated" do
      it "returns 401 Unauthorized for API endpoints" do
        project = create(:project)

        delete api_project_path(project), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      it "deletes the project and redirects" do
        user = create(:user)
        project = create(:project, owner: user)
        sign_in(user)

        expect {
          delete project_path(project)
        }.to change(Project, :count).by(-1)

        expect(response).to redirect_to(projects_path)
      end
    end
  end
end
```

**When NOT to use this pattern:**
- Public endpoints that intentionally allow unauthenticated access (e.g., landing pages, public API endpoints)

Reference: [Devise Test Helpers — Devise wiki](https://github.com/heartcombo/devise/wiki/How-To:-Test-with-Capybara)
