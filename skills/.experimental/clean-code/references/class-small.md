---
title: Keep Classes Small
impact: MEDIUM
impactDescription: enables comprehension and focused testing
tags: class, size, srp, cohesion
---

## Keep Classes Small

Classes should be small. With functions, we measure size by counting lines. With classes, we count responsibilities. A class should have only one reason to change.

**Incorrect (large class with multiple responsibilities):**

```java
public class SuperDashboard extends JFrame implements MetaDataUser {
    public String getCustomizerLanguagePath() { /* ... */ }
    public void setSystemConfigPath(String path) { /* ... */ }
    public String getSystemConfigDocument() { /* ... */ }
    public void setSystemConfigDocument(String doc) { /* ... */ }
    public boolean getGuruState() { /* ... */ }
    public boolean getNoviceState() { /* ... */ }
    public boolean getOpenSourceState() { /* ... */ }
    public void showObject(MetaObject object) { /* ... */ }
    public void showProgress(String s) { /* ... */ }
    public boolean isMetadataDirty() { /* ... */ }
    public void setIsMetadataDirty(boolean dirty) { /* ... */ }
    public Component getLastFocusedComponent() { /* ... */ }
    // 70+ more methods...
}
```

**Correct (small focused classes):**

```java
public class Version {
    public int getMajorVersionNumber() { /* ... */ }
    public int getMinorVersionNumber() { /* ... */ }
    public int getBuildNumber() { /* ... */ }
}

public class Dashboard extends JFrame {
    private final Version version;
    private final UserPreferences preferences;
    private final ProgressIndicator progress;

    public void show() { /* ... */ }
}

public class UserPreferences {
    public Language getLanguage() { /* ... */ }
    public boolean isNovice() { /* ... */ }
    public boolean isGuru() { /* ... */ }
}

public class ProgressIndicator {
    public void showProgress(String message) { /* ... */ }
    public void hideProgress() { /* ... */ }
}
```

**Single Responsibility Principle (SRP):** A class should have one, and only one, reason to change.

Reference: [Clean Code, Chapter 10: Classes](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
