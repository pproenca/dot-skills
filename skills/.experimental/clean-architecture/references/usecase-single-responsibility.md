---
title: Each Use Case Has One Reason to Change
impact: HIGH
impactDescription: isolates change impact, enables parallel development
tags: usecase, single-responsibility, cohesion, srp
---

## Each Use Case Has One Reason to Change

Each use case class should orchestrate exactly one application-specific workflow. Combining multiple use cases creates coupling that forces unrelated changes together.

**Incorrect (multiple use cases in one class):**

```python
class OrderService:
    def __init__(self, repo, payment, shipping, notification):
        self.repo = repo
        self.payment = payment
        self.shipping = shipping
        self.notification = notification

    def create_order(self, items, customer_id):
        # Use case 1: Create order
        order = Order.create(items, customer_id)
        self.repo.save(order)
        return order

    def process_payment(self, order_id, payment_method):
        # Use case 2: Process payment
        order = self.repo.find(order_id)
        self.payment.charge(order.total, payment_method)
        order.mark_paid()
        self.repo.save(order)

    def ship_order(self, order_id, address):
        # Use case 3: Ship order
        order = self.repo.find(order_id)
        tracking = self.shipping.create_shipment(order, address)
        order.mark_shipped(tracking)
        self.notification.send_shipped(order)
        self.repo.save(order)

    # Changes to shipping logic force retest of payment logic
```

**Correct (separate use case classes):**

```python
class CreateOrderUseCase:
    def __init__(self, repo: OrderRepository):
        self.repo = repo

    def execute(self, command: CreateOrderCommand) -> OrderId:
        order = Order.create(command.items, command.customer_id)
        self.repo.save(order)
        return order.id


class ProcessPaymentUseCase:
    def __init__(self, repo: OrderRepository, payment: PaymentGateway):
        self.repo = repo
        self.payment = payment

    def execute(self, command: ProcessPaymentCommand) -> None:
        order = self.repo.find(command.order_id)
        self.payment.charge(order.total, command.payment_method)
        order.mark_paid()
        self.repo.save(order)


class ShipOrderUseCase:
    def __init__(
        self,
        repo: OrderRepository,
        shipping: ShippingService,
        notification: NotificationPort
    ):
        self.repo = repo
        self.shipping = shipping
        self.notification = notification

    def execute(self, command: ShipOrderCommand) -> TrackingNumber:
        order = self.repo.find(command.order_id)
        tracking = self.shipping.create_shipment(order, command.address)
        order.mark_shipped(tracking)
        self.notification.send_shipped(order)
        self.repo.save(order)
        return tracking
```

**Benefits:**
- Changes to shipping don't affect payment tests
- Teams can work on different use cases in parallel
- Each use case has minimal dependencies

Reference: [Clean Architecture - Use Cases](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
