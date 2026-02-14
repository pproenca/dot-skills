---
title: Use params.expect() for Parameter Validation
impact: HIGH
impactDescription: prevents user-triggered 500 errors — returns 400 on parameter tampering instead
tags: ctrl, params, validation, rails-8
---

## Use params.expect() for Parameter Validation

Rails 8.0+ provides `params.expect()` which replaces the `params.require(:model).permit(:field)` chain with a single, declarative call. It raises `ActionController::ExpectedParameterMissing` when keys are absent and validates the parameter structure in one expression. This eliminates a class of bugs where `require` raises a different exception than `permit` silently drops keys.

**Incorrect (legacy require/permit chain):**

```ruby
class ProjectsController < ApplicationController
  private

  def project_params
    params.require(:project).permit(:name, :description, :due_date, :archived)
  end
end

class MembershipsController < ApplicationController
  private

  # Nested permit is verbose and error-prone
  def membership_params
    params.require(:membership).permit(
      :role,
      user_attributes: [:id, :name, :email],
      permissions: []
    )
  end
end
```

**Correct (params.expect for clean validation):**

```ruby
class ProjectsController < ApplicationController
  private

  def project_params
    params.expect(project: [:name, :description, :due_date, :archived])
  end
end

class MembershipsController < ApplicationController
  private

  # Nested structures are naturally expressed
  def membership_params
    params.expect(membership: [:role, user_attributes: [:id, :name, :email], permissions: []])
  end
end

# Multiple top-level keys return an array — destructure them
class BatchesController < ApplicationController
  private

  def extract_params
    batch, filters = params.expect(batch: [:name], filters: [:status, :priority])
    # batch => { "name" => "..." }
    # filters => { "status" => "...", "priority" => "..." }
    [batch, filters]
  end
end
```

**Alternative:** For optional parameter groups that may not be present in the request, `params.permit` without `expect` is still appropriate since missing keys should not raise errors.

Reference: [Basecamp AGENTS.md](https://github.com/basecamp/fizzy/blob/main/AGENTS.md)
