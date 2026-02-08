---
title: Extract Features into Independent Modules
impact: MEDIUM
impactDescription: reduces build times, enforces dependency boundaries
tags: arch, module, feature, spm, build-time
---

## Extract Features into Independent Modules

A single app target means every source file change recompiles the entire project. As the codebase grows, incremental build times balloon because Xcode cannot parallelize compilation within one target. Extracting features into local Swift packages enables parallel compilation across modules and enforces clear API boundaries -- a feature module cannot accidentally reach into another feature's internals unless you explicitly declare the dependency. This also makes features independently testable and reusable.

**Incorrect (monolithic target where all features share one compilation unit):**

```swift
// MyApp/
//   Sources/
//     App.swift
//     Auth/LoginView.swift
//     Auth/AuthService.swift
//     Profile/ProfileView.swift
//     Profile/ProfileService.swift
//     Settings/SettingsView.swift
//     Settings/ThemeManager.swift

// App.swift -- everything imports everything
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                LoginView()       // directly uses AuthService
                ProfileView()     // directly uses ProfileService
                SettingsView()    // directly uses ThemeManager
            }
        }
    }
}
```

**Correct (features extracted into local Swift packages with explicit dependencies):**

```swift
// Packages/AuthFeature/Package.swift
let package = Package(
    name: "AuthFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuthFeature", targets: ["AuthFeature"])
    ],
    targets: [
        .target(name: "AuthFeature"),
        .testTarget(name: "AuthFeatureTests", dependencies: ["AuthFeature"])
    ]
)

// App.swift -- imports only public interfaces
import AuthFeature
import ProfileFeature
import SettingsFeature

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                LoginView()
                ProfileView()
                SettingsView()
            }
        }
    }
}
```

Reference: [Organizing your code with local packages](https://developer.apple.com/documentation/xcode/organizing-your-code-with-local-packages)
