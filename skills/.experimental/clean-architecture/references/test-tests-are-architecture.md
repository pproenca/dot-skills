---
title: Tests Are Part of the System Architecture
impact: LOW-MEDIUM
impactDescription: enables fast feedback, documents behavior
tags: test, architecture, design, first-class
---

## Tests Are Part of the System Architecture

Tests participate in the architecture like any other component. They follow the dependency rule, couple to stable APIs, and should be designed for maintainability.

**Incorrect (tests as afterthought):**

```python
# tests/test_everything.py - Monolithic test file
import pytest
from unittest.mock import patch, MagicMock

class TestOrders:
    @patch('app.services.order_service.db')
    @patch('app.services.order_service.stripe')
    @patch('app.services.order_service.email_sender')
    @patch('app.services.order_service.inventory')
    def test_create_order(self, mock_inv, mock_email, mock_stripe, mock_db):
        # Testing implementation details
        mock_db.query.return_value.filter.return_value.first.return_value = Customer(id=1)
        mock_inv.check.return_value = True
        mock_stripe.PaymentIntent.create.return_value = MagicMock(id='pi_123')

        from app.services.order_service import create_order
        result = create_order({'customer_id': 1, 'items': [...]})

        # Asserting on internal calls, not behavior
        mock_db.query.assert_called()
        mock_stripe.PaymentIntent.create.assert_called_once()

# Tests coupled to implementation, break with refactoring
# Tests slow because they patch everything
```

**Correct (tests designed as architecture component):**

```python
# tests/unit/domain/test_order.py - Fast, stable, test domain rules
class TestOrder:
    def test_calculates_total_from_line_items(self):
        order = Order.create(customer_id="c1")
        order.add_item(Product("p1", Money(100)))
        order.add_item(Product("p2", Money(50)))

        assert order.total == Money(150)

    def test_rejects_negative_quantity(self):
        order = Order.create(customer_id="c1")

        with pytest.raises(InvalidQuantityError):
            order.add_item(Product("p1", Money(100)), quantity=-1)

# tests/integration/application/test_create_order.py - Test use case
class TestCreateOrderUseCase:
    def test_creates_order_and_reserves_inventory(self):
        # Use test doubles, not mocks of internals
        orders = InMemoryOrderRepository()
        inventory = FakeInventoryService(available={"p1": 10})
        use_case = CreateOrderUseCase(orders, inventory)

        result = use_case.execute(CreateOrderCommand(
            customer_id="c1",
            items=[OrderItem("p1", quantity=2)]
        ))

        # Assert on observable behavior
        assert orders.find_by_id(result.order_id) is not None
        assert inventory.reserved["p1"] == 2

# tests/e2e/test_order_flow.py - Full flow, few tests
class TestOrderFlow:
    def test_complete_order_journey(self, api_client, test_db):
        # Create order via API
        response = api_client.post('/orders', json={...})
        order_id = response.json['order_id']

        # Verify order persisted
        order = test_db.query(Order).get(order_id)
        assert order.status == 'pending'
```

**Test architecture mirrors system:**
```text
tests/
├── unit/                    # Fast, isolated
│   ├── domain/              # Entity business rules
│   └── application/         # Use case logic
├── integration/             # Component interaction
│   ├── persistence/         # Repository implementations
│   └── external/            # Gateway implementations
└── e2e/                     # Full system
    └── api/                 # HTTP endpoints
```

**Benefits:**
- Unit tests run in milliseconds
- Refactoring doesn't break tests
- Tests document intended behavior

Reference: [Clean Architecture - The Test Boundary](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch28.xhtml)
