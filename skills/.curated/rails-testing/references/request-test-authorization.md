---
title: Test Authorization for Each Role
impact: HIGH
impactDescription: prevents privilege escalation
tags: request, authorization, roles, access-control, security, pundit
---

## Test Authorization for Each Role

Authorization bugs are among the most dangerous security vulnerabilities because they silently grant access instead of failing loudly. Testing only that an admin can perform an action tells you nothing about whether a regular member, a user from another organization, or a user accessing another user's resources is properly blocked. Test every role boundary explicitly, including cross-tenant access attempts that should return 404 (not 403, to avoid leaking resource existence).

**Incorrect (testing only admin access works):**

```ruby
RSpec.describe "Admin: Users", type: :request do
  describe "DELETE /admin/users/:id" do
    it "allows admins to delete users" do
      admin = create(:user, role: :admin)
      target_user = create(:user)
      sign_in(admin)

      expect {
        delete admin_user_path(target_user)
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
    end
    # What happens when a non-admin hits this endpoint?
  end
end
```

**Correct (testing each role boundary and cross-resource access):**

```ruby
RSpec.describe "Admin: Users", type: :request do
  describe "DELETE /admin/users/:id" do
    context "as an admin" do
      it "deletes the user and redirects to the user list" do
        admin = create(:user, role: :admin)
        target_user = create(:user)
        sign_in(admin)

        expect {
          delete admin_user_path(target_user)
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "as a regular member" do
      it "returns 403 Forbidden" do
        member = create(:user, role: :member)
        target_user = create(:user)
        sign_in(member)

        delete admin_user_path(target_user)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when not authenticated" do
      it "redirects to sign-in" do
        target_user = create(:user)

        delete admin_user_path(target_user)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end

RSpec.describe "Projects", type: :request do
  describe "PATCH /projects/:id" do
    context "as the project owner" do
      it "updates the project" do
        owner = create(:user)
        project = create(:project, owner: owner)
        sign_in(owner)

        patch project_path(project), params: { project: { name: "Renamed" } }

        expect(response).to redirect_to(project_path(project))
        expect(project.reload.name).to eq("Renamed")
      end
    end

    context "as a team member with read-only access" do
      it "returns 403 Forbidden" do
        project = create(:project)
        reader = create(:user)
        create(:membership, project: project, user: reader, role: :viewer)
        sign_in(reader)

        patch project_path(project), params: { project: { name: "Hijacked" } }

        expect(response).to have_http_status(:forbidden)
        expect(project.reload.name).not_to eq("Hijacked")
      end
    end

    context "as a user from another organization" do
      it "returns 404 Not Found to avoid leaking resource existence" do
        project = create(:project)
        outsider = create(:user)
        sign_in(outsider)

        patch project_path(project), params: { project: { name: "Hijacked" } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
```

Reference: [Pundit — Authorization for Ruby on Rails](https://github.com/varvet/pundit#rspec)
