---
title: Integration Tests Over System Tests
impact: CRITICAL
impactDescription: 10x faster test suite — HEY dropped 359 system tests with zero bugs slipping through
tags: test, system-tests, integration-tests, minitest
---

## Integration Tests Over System Tests

37signals killed all 359 system tests in HEY, replacing them with ~10 smoke tests and leaning on controller integration tests. Not a single bug slipped through that the deleted tests would have caught. System tests remain slow, brittle, and full of false negatives — DHH's verdict: "System tests have failed to be worth their weight." Rails 8.1 stops generating system tests by default. Write fast integration tests that exercise real controller actions with real database hits instead.

**Incorrect (system tests as primary test strategy):**

```ruby
# test/system/cards_test.rb — slow, brittle, flaky
class CardsSystemTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "creating a card shows it on the board" do
    sign_in users(:david)
    visit board_path(boards(:product))

    click_on "New Card"
    fill_in "Title", with: "Fix login bug"
    fill_in "Description", with: "Users can't sign in on mobile"
    click_on "Create Card"

    assert_text "Fix login bug"
    assert_selector ".card", text: "Fix login bug"
  end

  test "archiving a card removes it from the board" do
    sign_in users(:david)
    visit card_path(cards(:feature_request))

    click_on "Archive"
    assert_no_selector ".card", text: cards(:feature_request).title

    visit archives_path
    assert_text cards(:feature_request).title
  end
end

# 359 tests like this: slow boot, Selenium overhead, CSS selector breakage,
# timing-dependent waits, false negatives on CI
```

**Correct (fast integration tests with controller assertions):**

```ruby
# test/controllers/cards_controller_test.rb — fast, reliable, deterministic
class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @board = boards(:product)
    @user = users(:david)
    sign_in @user
  end

  test "create adds card to board" do
    assert_difference -> { @board.cards.count } do
      post board_cards_path(@board), params: {
        card: { title: "Fix login bug", description: "Users can't sign in on mobile" }
      }
    end

    card = Card.last
    assert_equal "Fix login bug", card.title
    assert_redirected_to card_path(card)
  end

  test "create with invalid params renders form" do
    assert_no_difference -> { Card.count } do
      post board_cards_path(@board), params: { card: { title: "" } }
    end

    assert_response :unprocessable_entity
  end
end

# test/controllers/cards/closures_controller_test.rb
class Cards::ClosuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @card = cards(:feature_request)
    sign_in users(:david)
  end

  test "create closes the card" do
    post card_closure_path(@card)

    assert @card.reload.closed?
    assert_redirected_to board_path(@card.board)
  end

  test "destroy reopens the card" do
    @card.close!(by: users(:david))

    delete card_closure_path(@card)

    assert_not @card.reload.closed?
    assert_redirected_to card_path(@card)
  end
end

# test/system/smoke_test.rb — keep ~10 smoke tests for critical flows
class SmokeTest < ApplicationSystemTestCase
  test "user can sign in and see their boards" do
    visit root_path
    # Minimal smoke test for the most critical happy path
    assert_text "Sign in"
  end
end
```

**When NOT to use:**
- Keep a small set (~10) of smoke tests for the most critical user flows (sign in, payment, onboarding). These verify that the full stack works end-to-end. Everything else should be integration tests.

Reference: [System tests have failed](https://world.hey.com/dhh/system-tests-have-failed-d90af718)
