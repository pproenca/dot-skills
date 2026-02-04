---
title: Handle Errors with Clear Recovery Actions
impact: HIGH
impactDescription: helps users understand and recover from problems
tags: feed, errors, recovery, messaging
---

## Handle Errors with Clear Recovery Actions

When errors occur, explain what went wrong and provide clear actions to resolve. Never show technical error messages or leave users without a path forward.

**Incorrect (unhelpful error handling):**

```swift
// Technical error message
.alert("Error", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(error.localizedDescription)
    // "Error Domain=NSURLErrorDomain Code=-1009..."
}

// No error handling at all
Button("Save") {
    try? await save() // Silently fails
}

// Generic error without context
Text("Something went wrong")
    .foregroundColor(.red)
```

**Correct (helpful error recovery):**

```swift
// User-friendly error with action
.alert("Unable to Save", isPresented: $showError) {
    Button("Try Again") { retry() }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("Check your internet connection and try again.")
}

// Error state with recovery
ContentUnavailableView {
    Label("Connection Lost", systemImage: "wifi.slash")
} description: {
    Text("Unable to load items. Check your connection and pull to refresh.")
} actions: {
    Button("Try Again") {
        Task { await loadItems() }
    }
    .buttonStyle(.borderedProminent)
}

// Inline field validation
VStack(alignment: .leading) {
    TextField("Email", text: $email)
        .textContentType(.emailAddress)

    if !emailError.isEmpty {
        Label(emailError, systemImage: "exclamationmark.circle")
            .font(.caption)
            .foregroundColor(.red)
    }
}

// Network error with offline state
if networkError {
    VStack {
        Image(systemName: "wifi.exclamationmark")
            .font(.largeTitle)
        Text("You're Offline")
            .font(.headline)
        Text("Connect to the internet to see updates")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}
```

**Error message guidelines:**
- Explain what happened in plain language
- Avoid blaming the user
- Provide a clear action to resolve
- Use appropriate severity (error vs warning)
- Log technical details, don't show them

Reference: [Feedback - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/feedback)
