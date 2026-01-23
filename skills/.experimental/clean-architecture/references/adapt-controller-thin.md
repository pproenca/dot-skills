---
title: Keep Controllers Thin
impact: MEDIUM
impactDescription: simplifies testing, isolates HTTP concerns
tags: adapt, controller, thin, http
---

## Keep Controllers Thin

Controllers should only handle HTTP concerns: parsing requests, validating input format, calling use cases, and formatting responses. No business logic.

**Incorrect (fat controller with business logic):**

```python
class OrderController:
    @app.route('/orders', methods=['POST'])
    def create_order(self):
        data = request.json

        # Input validation - OK in controller
        if not data.get('items'):
            return jsonify({'error': 'Items required'}), 400

        # Business logic - WRONG in controller
        customer = db.query(Customer).get(data['customer_id'])
        if not customer.is_active:
            return jsonify({'error': 'Inactive customer'}), 400

        total = 0
        for item in data['items']:
            product = db.query(Product).get(item['product_id'])
            if product.stock < item['quantity']:
                return jsonify({'error': f'{product.name} out of stock'}), 400
            total += product.price * item['quantity']

        # More business logic
        if total > customer.credit_limit:
            return jsonify({'error': 'Exceeds credit limit'}), 400

        order = Order(
            customer_id=customer.id,
            items=data['items'],
            total=total
        )
        db.session.add(order)
        db.session.commit()

        return jsonify({'order_id': order.id}), 201
```

**Correct (thin controller delegates to use case):**

```python
class OrderController:
    def __init__(self, create_order_use_case: CreateOrderUseCase):
        self.create_order = create_order_use_case

    @app.route('/orders', methods=['POST'])
    def create(self):
        # Parse HTTP request
        data = request.json

        # Validate request format (not business rules)
        if not data.get('items'):
            return jsonify({'error': 'Items required'}), 400

        # Build command
        command = CreateOrderCommand(
            customer_id=data['customer_id'],
            items=[
                OrderItemCommand(p['product_id'], p['quantity'])
                for p in data['items']
            ]
        )

        # Delegate to use case
        try:
            result = self.create_order.execute(command)
            return jsonify({'order_id': result.order_id}), 201

        except CustomerInactiveError:
            return jsonify({'error': 'Customer account inactive'}), 400
        except InsufficientStockError as e:
            return jsonify({'error': f'{e.product_name} out of stock'}), 400
        except CreditLimitExceededError:
            return jsonify({'error': 'Order exceeds credit limit'}), 400
```

**Controller responsibilities:**
- Parse HTTP request to command/query objects
- Validate request format (required fields present)
- Call appropriate use case
- Map exceptions to HTTP status codes
- Format response

**Use case responsibilities:**
- Business validation (credit limits, stock)
- Business logic (calculations, state changes)
- Orchestrate entities and repositories

Reference: [Clean Architecture - Controllers](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch22.xhtml)
