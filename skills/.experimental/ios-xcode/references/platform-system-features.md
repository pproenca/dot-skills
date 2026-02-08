---
title: Integrate System Features Natively
impact: MEDIUM
impactDescription: reduces code by 50-80% vs custom implementations
tags: platform, system, share, photos, contacts, integration
---

## Integrate System Features Natively

Use system-provided UI for sharing, photo picking, and contacts. Users trust familiar interfaces, and you get automatic updates.

**Incorrect (custom share implementation):**

```swift
struct ArticleView: View {
    let article: Article
    @State private var showingCustomShare = false

    var body: some View {
        Button("Share") { showingCustomShare = true }
            .sheet(isPresented: $showingCustomShare) {
                // Custom share UI
                VStack {
                    Button("Copy Link") { /* ... */ }
                    Button("Twitter") { /* ... */ }
                    Button("Facebook") { /* ... */ }
                    // Missing: AirDrop, Messages, Mail, Notes...
                    // Must maintain every share destination
                }
            }
    }
}
```

**Correct (system ShareLink):**

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        ShareLink(item: article.url, subject: Text(article.title)) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        // All share destinations included
        // Updated automatically by iOS
    }
}
```

**Photo picker (iOS 16+):**

```swift
struct ProfileEditor: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?

    var body: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let avatarImage {
                avatarImage.resizable().frame(width: 100, height: 100)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
```

**Benefits of system UI:**
- Familiar to users, builds trust
- Automatically updated with iOS
- Handles permissions and privacy
- Consistent accessibility support

Reference: [Human Interface Guidelines - System Features](https://developer.apple.com/design/human-interface-guidelines/)
