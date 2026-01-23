---
title: Use Case Defines the Transaction Boundary
impact: HIGH
impactDescription: ensures data consistency, prevents partial updates
tags: usecase, transactions, consistency, boundaries
---

## Use Case Defines the Transaction Boundary

The use case is the natural transaction boundary. All operations within a use case should succeed or fail atomically. Infrastructure manages the transaction; use case defines the scope.

**Incorrect (transaction managed inside repository):**

```python
class OrderRepository:
    def save(self, order):
        with self.db.transaction():  # Transaction per operation
            self.db.insert('orders', order)

class InventoryRepository:
    def reserve(self, items):
        with self.db.transaction():  # Separate transaction
            for item in items:
                self.db.update('inventory', item.sku, decrement=item.qty)

class PlaceOrderUseCase:
    def execute(self, command):
        order = Order.create(command.items)
        self.orders.save(order)  # Commits
        self.inventory.reserve(command.items)  # If this fails, order is orphaned!
        self.payments.charge(order.total)  # If this fails, inventory is reserved but unpaid
```

**Correct (use case defines transaction boundary):**

```python
# application/ports/UnitOfWork.py
class UnitOfWork(Protocol):
    def begin(self) -> None: ...
    def commit(self) -> None: ...
    def rollback(self) -> None: ...

# application/usecases/PlaceOrderUseCase.py
class PlaceOrderUseCase:
    def __init__(self, uow: UnitOfWork, orders, inventory, payments):
        self.uow = uow
        self.orders = orders
        self.inventory = inventory
        self.payments = payments

    def execute(self, command):
        self.uow.begin()
        try:
            order = Order.create(command.items)

            self.inventory.reserve(command.items)
            self.payments.charge(order.total)
            self.orders.save(order)

            self.uow.commit()  # All or nothing
            return order.id

        except Exception as e:
            self.uow.rollback()  # Clean rollback
            raise

# Alternative using context manager
class PlaceOrderUseCase:
    def execute(self, command):
        with self.uow:  # Transaction spans entire use case
            order = Order.create(command.items)
            self.inventory.reserve(command.items)
            self.payments.charge(order.total)
            self.orders.save(order)
            return order.id
```

**Note:** For distributed systems, consider saga patterns or eventual consistency rather than distributed transactions.

Reference: [Unit of Work Pattern](https://martinfowler.com/eaaCatalog/unitOfWork.html)
