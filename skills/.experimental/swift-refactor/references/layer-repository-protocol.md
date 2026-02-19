---
title: Extract Repository Protocols in Domain, Implementations in Data
impact: HIGH
impactDescription: O(1) implementation swap — change database, API, or mock without touching domain or presentation
tags: layer, repository, protocol, domain, data-layer
---

## Extract Repository Protocols in Domain, Implementations in Data

When ViewModels or views directly call network or database APIs, the domain layer becomes coupled to specific frameworks. Extract a Repository protocol in the Domain layer defining WHAT data operations are needed. Place the concrete implementation in the Data layer, where it handles HOW to fetch/store. This lets you swap between API, database, cache, or mock implementations without changing any business logic.

**Incorrect (use case directly calls URLSession — coupled to networking framework):**

```swift
final class FetchProductsUseCaseImpl: FetchProductsUseCase {
    func execute(categoryId: String) async throws -> [Product] {
        let url = URL(string: "https://api.example.com/categories/\(categoryId)/products")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
```

**Correct (protocol in Domain, implementation in Data):**

```swift
// Domain/Repositories/ProductRepository.swift
// Pure protocol — no framework imports
protocol ProductRepository: Sendable {
    func fetchProducts(categoryId: String) async throws -> [Product]
    func saveProduct(_ product: Product) async throws
}

// Domain/UseCases/FetchProductsUseCaseImpl.swift
final class FetchProductsUseCaseImpl: FetchProductsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(categoryId: String) async throws -> [Product] {
        try await repository.fetchProducts(categoryId: categoryId)
    }
}

// Data/Repositories/APIProductRepository.swift
import Foundation

final class APIProductRepository: ProductRepository {
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts(categoryId: String) async throws -> [Product] {
        let url = URL(string: "https://api.example.com/categories/\(categoryId)/products")!
        let (data, _) = try await session.data(from: url)
        return try decoder.decode([Product].self, from: data)
    }

    func saveProduct(_ product: Product) async throws {
        // POST to API
    }
}

// Data/Repositories/MockProductRepository.swift
final class MockProductRepository: ProductRepository {
    var stubbedProducts: [Product] = []

    func fetchProducts(categoryId: String) async throws -> [Product] {
        stubbedProducts
    }

    func saveProduct(_ product: Product) async throws {
        stubbedProducts.append(product)
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
