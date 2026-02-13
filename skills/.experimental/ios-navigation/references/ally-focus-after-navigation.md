---
title: Manage Focus After Programmatic Navigation Events
impact: MEDIUM-HIGH
impactDescription: prevents VoiceOver users from losing their place after state changes
tags: ally, focus, voiceover, accessibility-focus-state, programmatic
---

## Manage Focus After Programmatic Navigation Events

When a modal is dismissed, a flow completes, or an error appears, VoiceOver focus may land on an unpredictable element — often the first element on screen or the navigation bar. This disorients users who cannot see the screen. Use `@AccessibilityFocusState` to explicitly direct VoiceOver focus to the most relevant element after programmatic navigation changes, such as a success message, error field, or the triggering button.

**Incorrect (no focus management after sheet dismissal):**

```swift
struct ProfileView: View {
    @State private var showEditSheet = false
    @State private var saveConfirmation = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile")
                    .font(.largeTitle)

                // After the edit sheet is dismissed, VoiceOver focus
                // lands on... somewhere. Usually the nav bar title
                // or the first element. The confirmation message
                // is never announced — user has no idea the save worked.
                if !saveConfirmation.isEmpty {
                    Text(saveConfirmation)
                        .foregroundColor(.green)
                }

                Button("Edit Profile") {
                    showEditSheet = true
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet { result in
                    saveConfirmation = "Profile saved successfully"
                    showEditSheet = false
                    // BAD: VoiceOver focus is now lost.
                    // User must swipe around to discover what happened.
                }
            }
        }
    }
}
```

**Correct (focus directed to confirmation after dismissal):**

```swift
struct ProfileView: View {
    @State private var showEditSheet = false
    @State private var saveConfirmation = ""

    // @AccessibilityFocusState binds to a VoiceOver focus target.
    // Setting it to true moves VoiceOver focus to the bound element.
    @AccessibilityFocusState private var isConfirmationFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile")
                    .font(.largeTitle)

                if !saveConfirmation.isEmpty {
                    Text(saveConfirmation)
                        .foregroundColor(.green)
                        // Bind this element to the focus state.
                        // When isConfirmationFocused = true,
                        // VoiceOver immediately announces this text.
                        .accessibilityFocused($isConfirmationFocused)
                }

                Button("Edit Profile") {
                    showEditSheet = true
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet { result in
                    saveConfirmation = "Profile saved successfully"
                    showEditSheet = false

                    // Move VoiceOver focus to the confirmation message
                    // after a brief delay to let the sheet dismiss animation
                    // complete and the confirmation view appear.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isConfirmationFocused = true
                    }
                }
            }
        }
    }
}

// For enum-based focus (e.g., forms with multiple error targets):
struct SignUpView: View {
    enum FocusTarget: Hashable {
        case emailError, passwordError, successBanner
    }

    @AccessibilityFocusState private var focusTarget: FocusTarget?

    var body: some View {
        Form {
            TextField("Email", text: $email)
            if let emailError {
                Text(emailError)
                    .foregroundColor(.red)
                    .accessibilityFocused($focusTarget, equals: .emailError)
            }
            // On validation failure, direct focus to the first error:
            // focusTarget = .emailError
        }
    }
}
```
