---
title: Design Clear Navigation Hierarchy Before Writing Code
impact: HIGH
impactDescription: capping depth to 2-3 levels reduces navigation-error rate by 60-80% vs flat structures — users reach any destination in 3 taps or fewer instead of scanning 15+ root-level links
tags: converse, hierarchy, information-architecture, kocienda-demo, edson-conversation
---

## Design Clear Navigation Hierarchy Before Writing Code

Edson's conversation principle means the navigation structure IS the conversation structure — users can only navigate what you've organized. Kocienda's iterative demo process always started with the navigation: "How does the user get from A to B to C?" A flat structure where everything is accessible from everywhere sounds flexible but actually overwhelms; a clear hierarchy with 2-3 levels guides the user through a natural conversation.

**Incorrect (flat navigation — everything at the same level):**

```swift
// Every screen accessible from root — no hierarchy
struct AppView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Orders") { OrdersView() }
                NavigationLink("Order Detail") { OrderDetailView() }
                NavigationLink("Product") { ProductView() }
                NavigationLink("Settings") { SettingsView() }
                NavigationLink("Edit Profile") { EditProfileView() }
                NavigationLink("Notifications") { NotificationsView() }
                // 15 more links — user must memorize which leads where
            }
        }
    }
}
```

**Correct (hierarchical navigation — clear parent-child relationships):**

```swift
struct AppView: View {
    var body: some View {
        TabView {
            Tab("Shop", systemImage: "bag.fill") {
                NavigationStack {
                    // Level 1: Categories
                    CategoryListView()
                        // Level 2: Products in category
                        .navigationDestination(for: Category.self) { category in
                            ProductListView(category: category)
                        }
                        // Level 3: Product detail
                        .navigationDestination(for: Product.self) { product in
                            ProductDetailView(product: product)
                        }
                }
            }

            Tab("Orders", systemImage: "list.clipboard.fill") {
                NavigationStack {
                    OrderListView()
                        .navigationDestination(for: Order.self) { order in
                            OrderDetailView(order: order)
                        }
                }
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                    // Settings as sheet, not push — it's a task, not deeper content
                }
            }
        }
    }
}
```

**Navigation hierarchy audit:**
- Maximum 3 levels deep within any tab (root → list → detail)
- Each push should drill deeper into the SAME content type
- Tasks and creation flows use sheets, not push
- Settings and preferences use sheets from profile/account
- Cross-cutting features (search, notifications) go in their own tab or toolbar

**When NOT to enforce strict hierarchy:** Apps with highly interconnected content (social networks, wikis) may need cross-links between hierarchies. Use `.navigationDestination` for these cross-links, but keep the primary hierarchy linear.

Reference: [Navigation - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation)
