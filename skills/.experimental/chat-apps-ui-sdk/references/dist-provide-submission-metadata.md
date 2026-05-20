---
title: Provide Accurate Submission Metadata
impact: MEDIUM
impactDescription: prevents directory review rejection
tags: dist, submission, metadata, review
---

## Provide Accurate Submission Metadata

Directory review needs a specific (non-generic) name, a description that matches actual behavior, a published privacy policy, correctly-sized screenshots, and a working demo account. Generic names, missing privacy policies, and trial or demo builds are rejected. Prepare this metadata as part of the build, not as an afterthought once the code is done.

**Incorrect (generic name, no privacy policy, a demo build):**

```json
{ "name": "Assistant", "description": "Does many things", "privacyPolicyUrl": null, "status": "demo" }
```

**Correct (specific name, honest description, required policy and screenshots):**

```json
{
  "name": "Transit Live Arrivals",
  "description": "Real-time bus and train arrivals for a stop you name.",
  "privacyPolicyUrl": "https://transit.example.com/privacy",
  "screenshots": ["inline-card.png", "fullscreen-map.png"]
}
```

Reference: [App submission guidelines – Apps SDK](https://developers.openai.com/apps-sdk/app-submission-guidelines)
