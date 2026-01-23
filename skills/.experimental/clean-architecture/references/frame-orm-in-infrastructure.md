---
title: Keep ORM Usage in Infrastructure Layer
impact: MEDIUM
impactDescription: isolates persistence complexity, enables ORM switching
tags: frame, orm, infrastructure, persistence
---

## Keep ORM Usage in Infrastructure Layer

ORM-specific code (entities, mappings, queries) belongs in the infrastructure layer. The domain and application layers should not know which ORM (or if any ORM) is being used.

**Incorrect (ORM in application layer):**

```python
# application/usecases/get_orders.py
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, or_

class GetOrdersUseCase:
    def __init__(self, session: Session):  # SQLAlchemy session in use case
        self.session = session

    def execute(self, customer_id: str, filters: OrderFilters):
        # SQLAlchemy query in use case
        query = self.session.query(Order).options(
            joinedload(Order.items),
            joinedload(Order.customer)
        )

        if filters.status:
            query = query.filter(Order.status == filters.status)

        if filters.date_range:
            query = query.filter(and_(
                Order.created_at >= filters.date_range.start,
                Order.created_at <= filters.date_range.end
            ))

        return query.order_by(Order.created_at.desc()).all()

# Use case is now coupled to SQLAlchemy
# Switching to Peewee or raw SQL requires rewriting use case
```

**Correct (ORM isolated in infrastructure):**

```python
# application/ports/order_repository.py
from abc import ABC, abstractmethod

class OrderRepository(ABC):
    @abstractmethod
    def find_by_customer(
        self,
        customer_id: CustomerId,
        filters: OrderFilters
    ) -> list[Order]:
        pass

# application/usecases/get_orders.py
class GetOrdersUseCase:
    def __init__(self, orders: OrderRepository):  # Interface, not Session
        self.orders = orders

    def execute(self, customer_id: str, filters: OrderFilters) -> list[Order]:
        return self.orders.find_by_customer(
            CustomerId(customer_id),
            filters
        )

# infrastructure/persistence/sqlalchemy_order_repository.py
from sqlalchemy.orm import Session, joinedload

class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session: Session):
        self.session = session

    def find_by_customer(
        self,
        customer_id: CustomerId,
        filters: OrderFilters
    ) -> list[Order]:
        query = self.session.query(OrderEntity).options(
            joinedload(OrderEntity.items)
        ).filter(OrderEntity.customer_id == customer_id.value)

        if filters.status:
            query = query.filter(OrderEntity.status == filters.status.value)

        entities = query.order_by(OrderEntity.created_at.desc()).all()
        return [self._to_domain(e) for e in entities]

    def _to_domain(self, entity: OrderEntity) -> Order:
        # Map ORM entity to domain entity
        pass
```

**Benefits:**
- Use case tests don't need database or ORM setup
- Can switch ORMs without touching business logic
- Complex queries encapsulated in repository

Reference: [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
