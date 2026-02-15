---
title: Maximum 10 Nodes in View Body
impact: HIGH
impactDescription: bodies exceeding 10 nodes prevent isolated diffing, multiplying re-render cost
tags: view, body-complexity, decomposition, lint, swiftlint
---

## Maximum 10 Nodes in View Body

When a view body contains more than ~10 direct child nodes, SwiftUI cannot efficiently isolate which subtree changed. The entire body re-evaluates on any property change. Airbnb enforces this via a custom SwiftLint rule using SwiftSyntax that triggers warnings when body complexity exceeds a threshold.

**Incorrect (monolithic body with 15+ inline nodes — entire body re-evaluates on any change):**

```swift
struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            // 15+ direct child nodes — SwiftUI cannot isolate diffs
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)

                Text(viewModel.name)
                    .font(.title)
                    .bold()

                Text(viewModel.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Bio")
                    .font(.headline)

                Text(viewModel.bio)
                    .font(.body)

                Divider()

                if viewModel.isPremium {
                    Label("Premium Member", systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                }

                ForEach(viewModel.stats) { stat in
                    HStack {
                        Text(stat.label)
                        Spacer()
                        Text(stat.value)
                            .bold()
                    }
                }

                Button("Edit Profile") {
                    viewModel.editTapped()
                }
                .buttonStyle(.borderedProminent)

                Button("Sign Out") {
                    viewModel.signOutTapped()
                }
                .foregroundStyle(.red)

                Text("Member since \(viewModel.joinDate)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }
}
```

**Correct (decomposed into focused subviews — each subtree diffs independently):**

```swift
struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Each subview receives only its needed properties
                // SwiftUI can diff each subtree independently
                ProfileHeaderView(
                    name: viewModel.name,
                    email: viewModel.email
                )

                ProfileBioSection(bio: viewModel.bio)

                ProfileStatsSection(
                    stats: viewModel.stats,
                    isPremium: viewModel.isPremium
                )

                ProfileActionsView(
                    onEdit: viewModel.editTapped,
                    onSignOut: viewModel.signOutTapped,
                    joinDate: viewModel.joinDate
                )
            }
            .padding()
        }
    }
}

// Each subview only re-renders when its specific inputs change
struct ProfileHeaderView: View {
    let name: String
    let email: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)

            Text(name)
                .font(.title)
                .bold()

            Text(email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProfileBioSection: View {
    let bio: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text("Bio").font(.headline)
            Text(bio).font(.body)
        }
    }
}

struct ProfileStatsSection: View {
    let stats: [ProfileStat]
    let isPremium: Bool

    var body: some View {
        VStack(spacing: 8) {
            Divider()

            if isPremium {
                Label("Premium Member", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }

            ForEach(stats) { stat in
                HStack {
                    Text(stat.label)
                    Spacer()
                    Text(stat.value).bold()
                }
            }
        }
    }
}
```

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-b1e8e4a78688)
