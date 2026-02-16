---
title: "Keychain Access from Multiple Threads Returns Unexpected Errors"
impact: MEDIUM
impactDescription: "errSecInteractionNotAllowed on ~5% of concurrent keychain queries"
tags: io, keychain, security, thread-safety, actor
---

## Keychain Access from Multiple Threads Returns Unexpected Errors

The Security framework's `SecItemCopyMatching` and `SecItemUpdate` are not fully thread-safe when called concurrently. Racing reads and writes produce intermittent `errSecInteractionNotAllowed` or `errSecDuplicateItem` errors, causing token lookups to fail silently in production.

**Incorrect (concurrent keychain access produces intermittent errors):**

```swift
import Foundation
import Security

class TokenStore {
    private let service = "com.app.auth"

    func saveToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        // Concurrent calls race between delete and add
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        // Concurrent read during write returns unexpected errors
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
}
```

**Proof Test (exposes intermittent errors from concurrent keychain access):**

```swift
import XCTest

final class TokenStoreConcurrencyTests: XCTestCase {
    func testConcurrentSaveAndLoadDoNotFail() async {
        let store = TokenStore()
        var errors = 0
        let iterations = 50

        await withTaskGroup(of: Bool.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    do {
                        try store.saveToken("token-\(i)")
                        return true
                    } catch {
                        return false  // race-induced failure
                    }
                }
                group.addTask {
                    return store.loadToken() != nil || true
                }
            }
            for await success in group {
                if !success { errors += 1 }
            }
        }

        XCTAssertEqual(errors, 0,
            "\(errors) keychain operations failed due to concurrent access")
    }
}
```

**Correct (actor serializes all keychain operations, eliminating races):**

```swift
import Foundation
import Security

actor TokenStore {
    private let service = "com.app.auth"

    func saveToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        // Actor ensures serial access — no race between delete and add
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
}
```
