---
title: Encapsulate Business Invariants Within Entities
impact: CRITICAL
impactDescription: prevents invalid state, centralizes validation
tags: entity, invariants, validation, encapsulation
---

## Encapsulate Business Invariants Within Entities

Business rules that must always be true (invariants) should be enforced by the entity itself. External code should not be able to put an entity into an invalid state.

**Incorrect (invariants scattered outside entity):**

```python
# application/usecases/transfer_money.py
class TransferMoneyUseCase:
    def execute(self, from_id, to_id, amount):
        from_account = self.repo.find(from_id)
        to_account = self.repo.find(to_id)

        # Validation scattered in use case
        if from_account.balance < amount:
            raise InsufficientFundsError()
        if amount <= 0:
            raise InvalidAmountError()
        if from_account.status != 'active':
            raise AccountInactiveError()

        from_account.balance -= amount  # Direct field mutation
        to_account.balance += amount

# Another use case might forget these checks!
```

**Correct (invariants enforced by entity):**

```python
# domain/entities/account.py
class Account:
    def __init__(self, id: AccountId, balance: Money, status: AccountStatus):
        self._id = id
        self._balance = balance
        self._status = status

    def withdraw(self, amount: Money) -> None:
        self._ensure_active()
        self._ensure_positive_amount(amount)
        self._ensure_sufficient_funds(amount)
        self._balance = self._balance.subtract(amount)

    def deposit(self, amount: Money) -> None:
        self._ensure_active()
        self._ensure_positive_amount(amount)
        self._balance = self._balance.add(amount)

    def _ensure_active(self) -> None:
        if self._status != AccountStatus.ACTIVE:
            raise AccountInactiveError(self._id)

    def _ensure_positive_amount(self, amount: Money) -> None:
        if amount.is_zero_or_negative():
            raise InvalidAmountError(amount)

    def _ensure_sufficient_funds(self, amount: Money) -> None:
        if self._balance.less_than(amount):
            raise InsufficientFundsError(self._id, self._balance, amount)

# application/usecases/transfer_money.py
class TransferMoneyUseCase:
    def execute(self, from_id, to_id, amount):
        from_account = self.repo.find(from_id)
        to_account = self.repo.find(to_id)

        from_account.withdraw(amount)  # Invariants guaranteed
        to_account.deposit(amount)
```

**Benefits:**
- Impossible to create invalid account state
- Validation rules documented in one place
- Every use case gets consistent validation automatically

Reference: [Domain-Driven Design - Aggregates](https://martinfowler.com/bliki/DDD_Aggregate.html)
