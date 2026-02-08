---
title: Remove Stale Outlet Connections to Prevent Crashes
impact: LOW-MEDIUM
impactDescription: prevents NSUnknownKeyException crashes
tags: debug, outlets, storyboard, crashes
---

## Remove Stale Outlet Connections to Prevent Crashes

When you rename or delete an `@IBOutlet` property in code but forget to disconnect it in the storyboard, the storyboard XML still references the old key name. At runtime, `setValue:forUndefinedKey:` throws `NSUnknownKeyException`, crashing the app on launch of that view controller. This crash has no compile-time warning and only manifests at runtime.

**Incorrect (deleted IBOutlet still connected in storyboard causes crash):**

```swift
// ProfileViewController.swift — "headerImageView" was renamed to "avatarImageView"
class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 40
        displayNameLabel.text = "Jane Doe"
    }
}

// CRASH at runtime:
// *** Terminating app due to uncaught exception 'NSUnknownKeyException',
// reason: '[<ProfileViewController 0x7fa3b2d08e00> setValue:forUndefinedKey:]:
// this class is not key value coding-compliant for the key headerImageView.'
```

**Correct (verify outlet connections after renaming or deleting properties):**

```swift
// ProfileViewController.swift
class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = 40
        displayNameLabel.text = "Jane Doe"
    }
}

// After renaming: open Profile.storyboard, select ProfileViewController scene,
// open Connections Inspector (Cmd+6), and:
// 1. Remove the stale "headerImageView" connection (yellow warning triangle)
// 2. Reconnect the view to the new "avatarImageView" outlet
```

**When NOT to use:**

- If you use `@IBOutlet` exclusively with XIBs and never storyboards, the same issue applies but the cleanup happens in the XIB file instead.

**Benefits:**

- Eliminates a crash that only surfaces at runtime with no compiler warning
- Connections Inspector shows yellow warning icons for stale outlets, making them easy to spot
- Adopting a habit of checking Cmd+6 after every outlet rename prevents regressions

Reference: [Connecting Objects to Code](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/ConnectingObjectstoCode.html)
