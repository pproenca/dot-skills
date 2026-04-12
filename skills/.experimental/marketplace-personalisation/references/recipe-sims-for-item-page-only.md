---
title: Use SIMS Only for Item-Page Similar Recommendations
impact: MEDIUM-HIGH
impactDescription: prevents user-history waste on item-page surfaces
tags: recipe, sims, similar-items
---

## Use SIMS Only for Item-Page Similar Recommendations

SIMS (Similar-Items) is a collaborative-filtering recipe that finds items frequently co-interacted with a given seed item — it ignores user history entirely. That makes it exactly right for item-page surfaces ("other listings you might consider") where the seed item is the signal, and exactly wrong for homefeeds or personalised shelves where user history is the signal. Deploying SIMS on a homepage produces recommendations that are independent of who is logged in, which is the opposite of personalisation.

**Incorrect (SIMS on a homefeed — user identity ignored):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=SIMS_CAMPAIGN_ARN,
    numResults=24,
)
```

**Correct (SIMS on an item-page surface, user-personalization elsewhere):**

```python
def item_page_similar(current_listing: Listing) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=SIMS_CAMPAIGN_ARN,
        itemId=current_listing.id,
        numResults=12,
    )
    return hydrate_listings(response["itemList"])

def homefeed(seeker: Seeker) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=USER_PERSONALIZATION_CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

Reference: [AWS Personalize — Choosing a Recipe](https://docs.aws.amazon.com/personalize/latest/dg/working-with-predefined-recipes.html)
