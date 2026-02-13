---
title: Use fullScreenCover Only for Immersive Standalone Experiences
impact: HIGH
impactDescription: prevents accidental dismiss, signals a mode change to the user
tags: modal, fullscreen-cover, immersive, close-button
---

## Use fullScreenCover Only for Immersive Standalone Experiences

fullScreenCover has no swipe-to-dismiss gesture and covers the entire screen, including the parent navigation bar. This signals to the user that they have entered a distinct mode. Reserve it for login flows, onboarding, media playback, or camera capture where accidental dismissal would be disruptive. Always provide an explicit close button because there is no other way to leave.

**Incorrect (using fullScreenCover for a settings form):**

```swift
struct ProfileView: View {
    @State private var showSettings = false

    var body: some View {
        Button("Settings") { showSettings = true }
            // BAD: A settings form is supplementary content, not immersive.
            // fullScreenCover removes swipe-to-dismiss, making the experience
            // feel heavier than it needs to be. Users expect to flick a settings
            // sheet away quickly. This also hides the parent context entirely,
            // which is unnecessary for a simple preferences screen.
            .fullScreenCover(isPresented: $showSettings) {
                SettingsFormView()
            }
    }
}
```

**Correct (fullScreenCover for camera capture with explicit close button):**

```swift
struct PostComposerView: View {
    @State private var showCamera = false

    var body: some View {
        Button("Take Photo") { showCamera = true }
            // GOOD: Camera capture is immersive and standalone.
            // Accidental swipe-dismiss could lose a photo mid-capture.
            // fullScreenCover prevents that and signals a clear mode switch.
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView()
            }
    }
}

struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraManager()

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            VStack {
                HStack {
                    // GOOD: Explicit close button is mandatory for fullScreenCover.
                    // Without it, the user has no way to leave the screen.
                    Button("Close") { dismiss() }
                        .font(.body.weight(.medium))
                        .padding()
                    Spacer()
                }
                Spacer()
                CaptureButton(action: camera.takePhoto)
                    .padding(.bottom, 40)
            }
        }
    }
}
```
