---
title: Make Operations Idempotent to Safely Retry After Failures
impact: HIGH
impactDescription: enables automatic retry, prevents duplicate processing
tags: disp, idempotency, retry, reliability
---

## Make Operations Idempotent to Safely Retry After Failures

Operations should be safe to retry without side effects. If a process dies mid-operation and the operation is retried, the end result should be the same as if it succeeded once. This is critical for crash recovery and queue-based processing.

**Incorrect (non-idempotent operations):**

```python
@app.task
def send_welcome_email(user_id):
    user = get_user(user_id)
    send_email(user.email, "Welcome!")
    # If worker dies after sending but before ack:
    # Task retried = user gets 2 emails

@app.task
def charge_customer(order_id, amount):
    order = get_order(order_id)
    stripe.Charge.create(amount=amount, customer=order.customer_id)
    order.status = 'paid'
    order.save()
    # If dies after charging but before save:
    # Retry = customer charged twice!

@app.task
def process_inventory(item_id, quantity):
    item = get_item(item_id)
    item.stock -= quantity  # Decrement
    item.save()
    # Retry = double decrement
```

**Correct (idempotent operations):**

```python
@app.task
def send_welcome_email(user_id):
    user = get_user(user_id)

    # Check if already sent (idempotency key in database)
    if user.welcome_email_sent:
        return  # Already done, safe to return

    send_email(user.email, "Welcome!")

    # Mark as sent atomically
    User.objects.filter(id=user_id, welcome_email_sent=False) \
        .update(welcome_email_sent=True)
    # If update affects 0 rows, another process already sent it

@app.task
def charge_customer(order_id, amount):
    order = get_order(order_id)

    if order.status == 'paid':
        return  # Already processed

    # Use idempotency key with Stripe
    idempotency_key = f"order-{order_id}-charge"
    stripe.Charge.create(
        amount=amount,
        customer=order.customer_id,
        idempotency_key=idempotency_key  # Stripe prevents duplicates
    )

    order.status = 'paid'
    order.save()

@app.task
def process_inventory(item_id, quantity, operation_id):
    # Check if this specific operation was already processed
    if InventoryOperation.objects.filter(id=operation_id).exists():
        return  # Already done

    with transaction.atomic():
        item = Item.objects.select_for_update().get(id=item_id)
        item.stock -= quantity
        item.save()
        # Record that we did this operation
        InventoryOperation.objects.create(id=operation_id, item_id=item_id)
```

**Idempotency patterns:**

```python
# 1. Unique operation ID
def process(operation_id, data):
    if Operation.exists(operation_id):
        return Operation.get(operation_id).result  # Return cached result
    result = do_work(data)
    Operation.create(id=operation_id, result=result)
    return result

# 2. State machine (can only transition once)
order.transition_to('shipped')  # If already shipped, no-op

# 3. External idempotency keys (Stripe, payment providers)
stripe.Charge.create(idempotency_key=unique_key)

# 4. Conditional updates
UPDATE items SET stock = stock - 10
WHERE id = 123 AND stock >= 10  # Only if we have stock
```

**Benefits:**
- Safe automatic retries
- Queue workers can use acks_late
- Duplicate messages don't cause problems
- Simpler error handling

Reference: [The Twelve-Factor App - Disposability](https://12factor.net/disposability)
