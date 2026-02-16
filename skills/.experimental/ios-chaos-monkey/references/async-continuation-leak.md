---
title: "CheckedContinuation Never Resumed Leaks Awaiting Task"
impact: HIGH
impactDescription: "task suspended forever, memory leak, potential hang"
tags: async, continuation, leak, callback, hang
---

## CheckedContinuation Never Resumed Leaks Awaiting Task

When `withCheckedContinuation` wraps a callback-based API, every execution path must call `resume` exactly once. If the callback has an early return, error branch, or timeout that skips `resume()`, the awaiting task is suspended forever. The task, its captured state, and everything it retains leak permanently. `CheckedContinuation` logs a runtime warning but the task still hangs.

**Incorrect (error path skips resume, task hangs forever):**

```swift
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.delegate = self
            manager.requestLocation()
        }
    }

    func locationManager(_ mgr: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations[0])
        continuation = nil
    }

    func locationManager(_ mgr: CLLocationManager, didFailWithError error: Error) {
        // BUG: if error is kCLErrorDomain, resume is never called
        guard (error as? CLError)?.code != .denied else { return }
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
```

**Proof Test (exposes the leaked continuation on authorization denial):**

```swift
import XCTest
import CoreLocation
@testable import MyApp

final class LocationManagerContinuationTests: XCTestCase {
    func testLocationDeniedResumesWithError() async {
        let locationManager = LocationManager()
        let expectation = expectation(description: "continuation resumes")

        Task {
            do {
                _ = try await locationManager.requestLocation()
                XCTFail("Should have thrown on denial")
            } catch {
                expectation.fulfill()  // never reached — continuation leaked
            }
        }

        // Simulate authorization denial
        let error = CLError(.denied)
        locationManager.locationManager(CLLocationManager(), didFailWithError: error)

        await fulfillment(of: [expectation], timeout: 3)
    }
}
```

**Correct (every exit path resumes the continuation exactly once):**

```swift
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.delegate = self
            manager.requestLocation()
        }
    }

    func locationManager(_ mgr: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations[0])
        continuation = nil
    }

    func locationManager(_ mgr: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)  // resumes on ALL errors
        continuation = nil
    }
}
```
