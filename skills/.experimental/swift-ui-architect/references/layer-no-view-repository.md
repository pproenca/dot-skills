---
title: Views Never Access Repositories Directly
impact: HIGH
impactDescription: reduces view-data coupling from O(N×M) to O(N) through single ViewModel boundary
tags: layer, view, repository, boundary, viewmodel
---

## Views Never Access Repositories Directly

Views access data exclusively through ViewModels, which delegate to Use Cases, which call Repository protocols. A view directly accessing a repository bypasses business logic, makes the view untestable without a live data source, and couples the UI to data implementation details. The flow is always: View -> ViewModel -> UseCase -> Repository.

**Incorrect (view calling repository directly — bypasses business logic, untestable):**

```swift
struct UserProfileView: View {
    // View depends directly on a repository — violates layer boundary
    @Environment(\.modelContext) private var modelContext

    @State private var user: User?
    @State private var isLoading = false

    let userId: String

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let user {
                Text(user.name)
                Text(user.email)
            }
        }
        .task {
            isLoading = true
            // Direct repository/database access from view
            // No business logic layer — where do validation rules go?
            // Cannot test without a real ModelContext
            let descriptor = FetchDescriptor<UserEntity>(
                predicate: #Predicate { $0.id == userId }
            )
            if let entity = try? modelContext.fetch(descriptor).first {
                user = User(from: entity)
            } else {
                // Network call directly in view
                let url = URL(string: "https://api.example.com/users/\(userId)")!
                if let (data, _) = try? await URLSession.shared.data(from: url) {
                    user = try? JSONDecoder().decode(User.self, from: data)
                }
            }
            isLoading = false
        }
    }
}

// Problems:
// 1. View contains data access logic — untestable without database/network
// 2. Business rules (caching strategy, fallback logic) embedded in view
// 3. Changing data source requires modifying every view
// 4. No single place to apply cross-cutting concerns (logging, analytics)
```

**Correct (View -> ViewModel -> UseCase -> Repository — clean layer flow):**

```swift
// View — only calls ViewModel methods and reads display properties
struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.userName)
                Text(viewModel.userEmail)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}

// ViewModel — calls UseCase, transforms result for display
@Observable
final class UserProfileViewModel {
    private let fetchProfileUseCase: FetchUserProfileUseCase

    var userName: String = ""
    var userEmail: String = ""
    var isLoading: Bool = false

    init(userId: String, fetchProfileUseCase: FetchUserProfileUseCase) {
        self.fetchProfileUseCase = fetchProfileUseCase
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        guard let profile = try? await fetchProfileUseCase.execute(userId: userId) else {
            return
        }

        // Transform domain model to display-ready properties
        userName = profile.name
        userEmail = profile.email
    }

    private let userId: String
}

// UseCase — applies business rules, calls repository
final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(userId: String) async throws -> UserProfile {
        // Business logic lives here — not in view, not in repository
        let user = try await userRepository.fetchUser(id: userId)
        return UserProfile(
            name: user.displayName,
            email: user.email,
            memberSince: user.joinDate
        )
    }
}

// Repository — handles data access (defined as protocol in Domain)
// View never knows this exists
final class RemoteUserRepository: UserRepository {
    func fetchUser(id: String) async throws -> User {
        // Networking implementation — completely hidden from views
        try await networkClient.get(url: usersEndpoint.appending(path: id))
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
