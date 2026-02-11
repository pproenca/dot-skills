---
title: Test Associations Explicitly
impact: HIGH
impactDescription: catches 100% of missing foreign keys and orphaned dependent records
tags: model, associations, has-many, belongs-to, dependent-destroy
---

## Test Associations Explicitly

Untested associations silently break when foreign key columns are missing from migrations or when `dependent` options are forgotten. A missing `dependent: :destroy` on a `has_many` leaves orphaned records that corrupt reporting and violate referential integrity. Use shoulda-matchers for declaration verification and add behavioral tests for the side effects that matter most.

**Incorrect (skipping association tests because "ActiveRecord handles it"):**

```ruby
RSpec.describe Team, type: :model do
  # "No need to test associations, ActiveRecord takes care of it"

  describe "#archive" do
    it "archives the team" do
      team = create(:team)

      team.archive!

      expect(team.reload).to be_archived
    end
    # Never verifies that destroying a team cascades to memberships
  end
end
```

**Correct (declaration tests plus behavioral verification of dependent options):**

```ruby
RSpec.describe Team, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:memberships).source(:user) }
    it { is_expected.to have_one(:subscription).dependent(:destroy) }
  end

  describe "dependent destroy behavior" do
    it "destroys associated memberships when the team is destroyed" do
      team = create(:team)
      create_list(:membership, 3, team: team)

      expect { team.destroy! }.to change(Membership, :count).by(-3)
    end

    it "does not destroy the parent organization when the team is destroyed" do
      team = create(:team)

      expect { team.destroy! }.not_to change(Organization, :count)
    end
  end

  describe "foreign key constraints" do
    it "cannot create a team without an organization" do
      team = build(:team, organization: nil)

      expect(team).not_to be_valid
      expect(team.errors[:organization]).to include("must exist")
    end
  end
end
```

Reference: [shoulda-matchers Association Matchers — thoughtbot](https://github.com/thoughtbot/shoulda-matchers#activerecord-matchers)
