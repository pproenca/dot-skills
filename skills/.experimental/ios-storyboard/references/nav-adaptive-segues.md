---
title: Use Show and Show Detail Instead of Push and Modal
impact: MEDIUM-HIGH
impactDescription: enables automatic adaptation for iPad split views
tags: nav, segue, adaptive, split-view, iPad
---

## Use Show and Show Detail Instead of Push and Modal

The legacy Push and Modal segue types hard-code a single presentation style regardless of device or size class. The adaptive Show and Show Detail segue types let UIKit choose the appropriate presentation automatically: pushing onto a navigation stack on iPhone, or replacing the detail pane in a split view on iPad.

**Incorrect (legacy push segue that breaks on iPad split view):**

```xml
<!-- Hard-coded push ignores split view context on iPad -->
<segue destination="ArticleDetailVC" kind="push"
       identifier="ShowArticle" id="seg-001"/>

<segue destination="ComposeVC" kind="modal"
       identifier="ComposeMessage"
       modalPresentationStyle="fullScreen" id="seg-002"/>
```

**Correct (adaptive segue types that adjust to the device context):**

```xml
<segue destination="ArticleDetailVC" kind="show"
       identifier="ShowArticle" id="seg-001"/>

<!-- showDetail replaces the detail pane on iPad, pushes on iPhone -->
<segue destination="ComposeVC" kind="showDetail"
       identifier="ComposeMessage" id="seg-002"/>
```

**When NOT to use:**
- Use Present Modally when you explicitly need a modal sheet that should never push (e.g., a login gate or camera capture flow)

**Reference:**
- [Apple: Adaptive Presentations](https://developer.apple.com/documentation/uikit/uisplitviewcontroller)
