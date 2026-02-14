---
title: Test Behavior Not Implementation
impact: MEDIUM
impactDescription: tests survive 90%+ of refactors without modification
tags: test, behavior, integration, verification
---

## Test Behavior Not Implementation

Focus on behavior verification over unit-level implementation testing. Integration tests that exercise real user flows — clicking buttons, submitting forms, seeing results — are more valuable than isolated unit tests that mock every collaborator. When tests assert on internal method calls and mock chains, they break on every refactor even when the feature still works perfectly. Test what the user sees, not how the code is wired internally.

**Incorrect (heavily mocked unit test coupled to implementation):**

```ruby
# test/models/project_test.rb — tests internal wiring, not outcomes
class ProjectTest < ActiveSupport::TestCase
  test "archive calls the right methods in order" do
    project = projects(:basecamp)
    mock_archiver = Minitest::Mock.new

    mock_archiver.expect :deactivate_memberships, true
    mock_archiver.expect :cancel_recurring_todos, true
    mock_archiver.expect :remove_from_dashboard, true
    mock_archiver.expect :send_archive_notification, true

    ProjectArchiver.stub :new, mock_archiver do
      project.archive!
    end

    mock_archiver.verify
    assert project.archived?
  end

  test "archive sets archived_at" do
    project = projects(:basecamp)
    freeze_time do
      project.archive!
      assert_equal Time.current, project.archived_at
    end
  end

  test "archive enqueues notification job" do
    project = projects(:basecamp)
    assert_enqueued_with(job: ProjectArchivedNotificationJob) do
      project.archive!
    end
  end
end
```

**Correct (behavior-focused integration test verifying user outcomes):**

```ruby
# test/system/project_archiving_test.rb — tests what the user experiences
class ProjectArchivingTest < ApplicationSystemTestCase
  test "archiving a project removes it from the dashboard and notifies members" do
    project = projects(:basecamp)
    member = users(:jorge)
    sign_in project.creator

    visit project_path(project)
    click_on "Archive this project"
    click_on "Confirm archive"

    assert_text "#{project.name} has been archived"
    assert_no_selector "#project_#{project.id}"

    visit dashboard_path
    assert_no_text project.name

    sign_in member
    assert_text "#{project.name} was archived"
  end
end

# test/models/project_test.rb — model test verifies state change, not wiring
class ProjectTest < ActiveSupport::TestCase
  test "archive marks the project as archived and records timestamp" do
    project = projects(:basecamp)

    freeze_time do
      project.archive!

      assert project.archived?
      assert_equal Time.current, project.archived_at
    end
  end

  test "archived projects are excluded from active scope" do
    project = projects(:basecamp)
    project.archive!

    assert_not_includes Project.active, project
  end
end
```

**Benefits:**
- Integration tests survive internal refactoring — rename methods, extract concerns, restructure callbacks, and the tests still pass
- Behavior tests catch real bugs that mocked unit tests miss (e.g., a broken template, a missing route, a JavaScript error)
- Test suite acts as living documentation of what users can do, not how code is organized

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
