---
title: Pass Only Needed Properties, Not Entire Models
impact: HIGH
impactDescription: 2-10× fewer re-renders by scoping dependencies to exact properties read
tags: view, dependencies, minimal, scoping, props
---

## Pass Only Needed Properties, Not Entire Models

When a child view only needs a user's name and avatar, pass those two values — not the entire User model. Passing the whole model creates a dependency on ALL of User's properties. When `user.lastLoginDate` changes, the avatar view re-renders for no reason. Scoping dependencies to exactly what's read prevents cascade re-renders.

**Incorrect (passing entire model — re-renders on any User property change):**

```swift
struct UserAvatarView: View {
    // Depends on the ENTIRE User model
    // Re-renders when user.lastLoginDate, user.preferences,
    // user.orderHistory, or ANY other property changes
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            // Only reads 2 out of 15+ properties
            Text(user.name)
                .font(.headline)
        }
    }
}

// Parent passes the entire model
struct ProfileHeaderView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        UserAvatarView(user: viewModel.user)  // Over-broad dependency
    }
}
```

**Correct (passing only needed values — re-renders only when name or avatar change):**

```swift
struct UserAvatarView: View {
    // Depends on exactly what it reads — nothing more
    let name: String
    let avatarURL: URL?

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: avatarURL) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            Text(name)
                .font(.headline)
        }
    }
}

// Parent passes only what the child needs
struct ProfileHeaderView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        // Only re-renders when name or avatarURL change
        // Changes to lastLoginDate, preferences, etc. are ignored
        UserAvatarView(
            name: viewModel.user.name,
            avatarURL: viewModel.user.avatarURL
        )
    }
}
```

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
