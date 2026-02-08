---
title: Assign Storyboard Scenes to Individual Developers
impact: MEDIUM
impactDescription: eliminates concurrent storyboard edits
tags: vcs, storyboard, ownership, merge-conflicts
---

## Assign Storyboard Scenes to Individual Developers

When two developers edit scenes in the same storyboard file simultaneously, git produces merge conflicts in XML that are nearly impossible to resolve by hand. Xcode rewrites element ordering, regenerates object IDs, and updates connection metadata on every save, so even non-overlapping scene edits create hundreds of conflicting lines. Assigning storyboard ownership per developer or splitting scenes into separate storyboard files eliminates this entirely.

**Incorrect (two developers editing the same storyboard, producing unresolvable conflicts):**

```xml
<<<<<<< HEAD
    <scene sceneID="checkout-1">
        <objects>
            <viewController id="CheckoutVC" sceneMemberID="viewController">
                <view key="view" contentMode="scaleToFill" id="abc-123">
                    <rect key="frame" x="0" y="0" width="375" height="812"/>
=======
    <scene sceneID="checkout-1">
        <objects>
            <viewController id="CheckoutVC" sceneMemberID="viewController">
                <view key="view" contentMode="scaleToFill" id="abc-123">
                    <rect key="frame" x="0" y="0" width="393" height="852"/>
>>>>>>> feature/payment-redesign
```

**Correct (split storyboards with CODEOWNERS enforcing ownership):**

```bash
# .github/CODEOWNERS
# Each storyboard owned by one developer or team
Checkout.storyboard    @sarah
Profile.storyboard     @marcus
Onboarding.storyboard  @team-growth
Search.storyboard      @alex
```

Pair this with feature-scoped storyboards containing 3-5 scenes each:

```bash
Storyboards/
  Checkout.storyboard      # Sarah's feature
  Profile.storyboard       # Marcus's feature
  Onboarding.storyboard    # Growth team
  Search.storyboard        # Alex's feature
```

**Benefits:**

- CODEOWNERS blocks PRs that modify another developer's storyboard without review
- Small storyboards produce readable XML diffs in pull requests
- Developers never need to coordinate who has a storyboard "checked out"
