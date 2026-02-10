---
title: Request Permissions in Context
impact: HIGH
impactDescription: contextual permission requests achieve 60-80% grant rates vs 30-40% for upfront requests — pre-permission explanation doubles acceptance
tags: ux, permissions, privacy, context
---

## Request Permissions in Context

Request permissions when the user needs the feature, not at launch. Explain why you need the permission before the system dialog appears.

**Incorrect (poor permission timing):**

```swift
// All permissions at launch
struct ContentView: View {
    var body: some View {
        HomeView()
            .onAppear {
                requestCameraPermission()
                requestLocationPermission()
                requestNotificationPermission()
                requestContactsPermission()
            }
    }
}
// Overwhelming and no context

// No explanation before request
Button("Take Photo") {
    AVCaptureDevice.requestAccess(for: .video) { _ in }
}
// User doesn't know why camera is needed
```

**Correct (contextual permission requests):**

```swift
// Pre-permission explanation
struct PhotoFeatureView: View {
    @State private var showPermissionExplanation = false

    var body: some View {
        Button("Add Photo") {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                showPermissionExplanation = true
            case .authorized:
                openCamera()
            case .denied, .restricted:
                showSettingsPrompt()
            @unknown default:
                break
            }
        }
        .alert("Camera Access", isPresented: $showPermissionExplanation) {
            Button("Enable Camera") {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted { openCamera() }
                }
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("We need camera access to let you add photos to your recipes.")
        }
    }
}

// Request when feature is used
struct LocationFeatureView: View {
    var body: some View {
        Button("Find Nearby Stores") {
            locationManager.requestWhenInUseAuthorization()
        }
        // Only asks when user wants location-based feature
    }
}

// Handle denied permission gracefully
if locationStatus == .denied {
    VStack {
        Text("Location access is needed to find stores near you")
        Button("Open Settings") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
}
```

**Permission best practices:**
- Ask only when feature requires it
- Explain benefit before system dialog
- Don't ask for multiple permissions at once
- Handle denial gracefully
- Provide alternative if permission denied

Reference: [Privacy - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/privacy)
