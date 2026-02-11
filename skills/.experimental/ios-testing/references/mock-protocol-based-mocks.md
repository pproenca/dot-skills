---
title: "Create Mocks From Protocols, Not Subclasses"
impact: HIGH
impactDescription: "eliminates hidden side effects from parent class"
tags: mock, protocols, isolation, test-doubles
---

## Create Mocks From Protocols, Not Subclasses

Subclassing concrete types like URLSession to create mocks inherits real implementation behavior that executes silently during tests, producing unpredictable side effects and false confidence. Protocol-based mocks contain only the behavior you define, guaranteeing full isolation.

**Incorrect (parent class methods still execute during tests):**

```swift
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?

    override func data(from url: URL) async throws -> (Data, URLResponse) {
        return (mockData!, mockResponse!) // parent class initializers and internal state still run
    }
}

func testFetchProfile() async throws {
    let session = MockURLSession()
    session.mockData = try JSONEncoder().encode(User(name: "Alice"))
    session.mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)

    let viewModel = ProfileViewModel(session: session)
    try await viewModel.loadProfile(userId: "42")
    #expect(viewModel.user?.name == "Alice")
}
```

**Correct (zero inherited behavior — mock controls everything):**

```swift
protocol NetworkClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkClient {} // production conformance, no extra code

struct MockNetworkClient: NetworkClient {
    var result: Result<(Data, URLResponse), Error> // no parent class — only what you define exists

    func data(from url: URL) async throws -> (Data, URLResponse) {
        return try result.get()
    }
}

func testFetchProfile() async throws {
    let responseData = try JSONEncoder().encode(User(name: "Alice"))
    let response = HTTPURLResponse(url: URL(string: "https://api.example.com")!,
                                   statusCode: 200, httpVersion: nil, headerFields: nil)!
    let client = MockNetworkClient(result: .success((responseData, response)))

    let viewModel = ProfileViewModel(networkClient: client)
    try await viewModel.loadProfile(userId: "42")
    #expect(viewModel.user?.name == "Alice")
}
```
