---
title: Don't Test ActiveRecord or Framework Behavior
impact: MEDIUM-HIGH
impactDescription: wastes time testing code you don't own
tags: model, framework, activerecord, anti-pattern, unit-testing
---

## Don't Test ActiveRecord or Framework Behavior

ActiveRecord's `save`, `find`, `destroy`, and query interface are tested by Rails itself — retesting them in your suite wastes time and creates noise that obscures your actual domain logic tests. Focus on the behavior YOU wrote on top of the framework: custom finders, computed attributes, state transitions, and business rules. If a test would pass with an empty model class plus the framework default, it is not testing your code.

**Incorrect (testing that ActiveRecord CRUD operations work):**

```ruby
RSpec.describe Project, type: :model do
  describe "persistence" do
    it "persists to the database" do
      project = create(:project, name: "Alpha")

      expect(Project.find(project.id)).to eq(project)
    end

    it "updates attributes" do
      project = create(:project, name: "Alpha")

      project.update!(name: "Beta")

      expect(project.reload.name).to eq("Beta")
    end

    it "destroys the record" do
      project = create(:project)

      expect { project.destroy! }.to change(Project, :count).by(-1)
    end

    it "supports where queries" do
      create(:project, status: "active")
      create(:project, status: "archived")

      expect(Project.where(status: "active").count).to eq(1)
    end
  end
end
```

**Correct (testing your custom domain logic built on the framework):**

```ruby
RSpec.describe Project, type: :model do
  describe "#overdue?" do
    it "returns true when the deadline has passed and the project is incomplete" do
      project = build(:project, deadline: 1.day.ago, completed_at: nil)

      expect(project).to be_overdue
    end

    it "returns false when the project is completed even if past deadline" do
      project = build(:project, deadline: 1.day.ago, completed_at: 2.days.ago)

      expect(project).not_to be_overdue
    end
  end

  describe "#budget_utilization" do
    it "calculates the percentage of budget spent across all tasks" do
      project = create(:project, budget_cents: 100_000)
      create(:task, project: project, cost_cents: 25_000)
      create(:task, project: project, cost_cents: 50_000)

      expect(project.budget_utilization).to eq(0.75)
    end

    it "returns zero when no tasks have costs" do
      project = create(:project, budget_cents: 100_000)

      expect(project.budget_utilization).to eq(0.0)
    end
  end

  describe ".stale" do
    it "returns projects with no activity in the last 90 days" do
      stale = create(:project, last_activity_at: 91.days.ago)
      active = create(:project, last_activity_at: 1.day.ago)

      expect(Project.stale).to contain_exactly(stale)
    end
  end
end
```

Reference: [Better Specs — Don't Test the Framework](https://www.betterspecs.org/)
