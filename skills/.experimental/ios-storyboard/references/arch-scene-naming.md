---
title: Use Descriptive Scene Labels in Document Outline
impact: MEDIUM
impactDescription: reduces navigation time in complex storyboards
tags: arch, scene-labels, naming, readability
---

## Use Descriptive Scene Labels in Document Outline

Xcode assigns every scene a default label of "View Controller Scene" in the Document Outline. When a storyboard has more than a few scenes, the outline becomes a wall of identical names, forcing developers to click through each one to find the right screen. Setting the `userLabel` attribute on each scene makes the outline instantly navigable.

**Incorrect (default scene labels -- all identical):**

```xml
<!-- Profile.storyboard — Document Outline shows: -->
<!-- "View Controller Scene"                        -->
<!-- "View Controller Scene"                        -->
<!-- "View Controller Scene"                        -->
<!-- "Table View Controller Scene"                  -->
<scenes>
    <scene sceneID="abc-11">
        <objects>
            <viewController id="ProfileMainVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-22">
        <objects>
            <viewController id="EditProfileVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-33">
        <objects>
            <viewController id="ChangePasswordVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-44">
        <objects>
            <tableViewController id="ActivityLogVC"
                                 sceneMemberID="viewController">
                <!-- ... -->
            </tableViewController>
        </objects>
    </scene>
</scenes>
```

**Correct (descriptive userLabel on every scene):**

```xml
<!-- Profile.storyboard — Document Outline shows: -->
<!-- "Profile Main Scene"                          -->
<!-- "Edit Profile Scene"                          -->
<!-- "Change Password Scene"                       -->
<!-- "Activity Log Scene"                          -->
<scenes>
    <scene sceneID="abc-11" userLabel="Profile Main Scene">
        <objects>
            <viewController id="ProfileMainVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-22" userLabel="Edit Profile Scene">
        <objects>
            <viewController id="EditProfileVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-33" userLabel="Change Password Scene">
        <objects>
            <viewController id="ChangePasswordVC" sceneMemberID="viewController">
                <!-- ... -->
            </viewController>
        </objects>
    </scene>
    <scene sceneID="abc-44" userLabel="Activity Log Scene">
        <objects>
            <tableViewController id="ActivityLogVC"
                                 sceneMemberID="viewController">
                <!-- ... -->
            </tableViewController>
        </objects>
    </scene>
</scenes>
```

**Benefits:**
- Developers locate scenes in under 2 seconds instead of clicking through each one
- Code review of storyboard XML diffs is immediately understandable
- Scene labels appear in Xcode's Find navigator, making project-wide search effective
