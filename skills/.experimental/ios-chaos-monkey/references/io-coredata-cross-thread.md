---
title: "CoreData NSManagedObject Accessed from Wrong Thread"
impact: MEDIUM-HIGH
impactDescription: "SIGABRT crash, data corruption in persistent store"
tags: io, coredata, thread-confinement, managed-object, crash
---

## CoreData NSManagedObject Accessed from Wrong Thread

CoreData enforces thread confinement: an `NSManagedObject` must only be accessed on the queue that owns its `NSManagedObjectContext`. Passing the object to a background thread violates this contract, triggering a SIGABRT in debug or silent data corruption in release builds.

**Incorrect (passes managed object to background thread, violating confinement):**

```swift
import CoreData

class OrderRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func processOrder(_ order: Order) {
        DispatchQueue.global().async {
            // Accessing managed object off its context's queue — SIGABRT
            let total = order.totalAmount
            let name = order.customerName
            self.sendReceipt(name: name, amount: total)
        }
    }

    private func sendReceipt(name: String, amount: Double) {
        print("Receipt sent to \(name) for \(amount)")
    }
}
```

**Proof Test (exposes the crash by accessing object from wrong thread):**

```swift
import XCTest
import CoreData

final class OrderRepositoryThreadTests: XCTestCase {
    func testProcessOrderDoesNotCrashFromBackground() async throws {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        let context = container.viewContext
        let order = Order(context: context)
        order.customerName = "Alice"
        order.totalAmount = 99.99
        try context.save()

        let repo = OrderRepository(viewContext: context)

        // With -com.apple.CoreData.ConcurrencyDebug 1,
        // this crashes on background access
        let expectation = expectation(description: "receipt sent")
        repo.processOrder(order)

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 3)
    }
}
```

**Correct (passes objectID and refetches in background context):**

```swift
import CoreData

class OrderRepository {
    let viewContext: NSManagedObjectContext
    let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
        self.viewContext = container.viewContext
    }

    func processOrder(_ order: Order) {
        let objectID = order.objectID  // thread-safe identifier

        container.performBackgroundTask { bgContext in
            let bgOrder = bgContext.object(with: objectID) as! Order
            // Safe — accessing on bgContext's queue
            let total = bgOrder.totalAmount
            let name = bgOrder.customerName
            self.sendReceipt(name: name, amount: total)
        }
    }

    private func sendReceipt(name: String, amount: Double) {
        print("Receipt sent to \(name) for \(amount)")
    }
}
```
