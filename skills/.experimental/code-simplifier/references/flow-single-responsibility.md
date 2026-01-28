---
title: Each Code Block Should Do One Thing
impact: HIGH
impactDescription: Single-responsibility blocks are 60% faster to understand and 40% less likely to introduce bugs when modified
tags: flow, single-responsibility, cohesion, blocks, functions
---

## Each Code Block Should Do One Thing

When a code block (function, loop, conditional branch) tries to do multiple things, it becomes harder to name, test, and modify. Each block should have one clear purpose. If you can't describe what a block does without using "and", split it up.

**Incorrect (loop doing multiple things):**

```typescript
function processOrders(orders: Order[]) {
  let totalRevenue = 0;
  const flaggedOrders: Order[] = [];
  const customerOrderCounts: Map<string, number> = new Map();
  const emailsToSend: Email[] = [];

  for (const order of orders) {
    // Calculate revenue
    totalRevenue += order.total;

    // Flag suspicious orders
    if (order.total > 10000 || order.items.length > 50) {
      flaggedOrders.push(order);
    }

    // Count orders per customer
    const count = customerOrderCounts.get(order.customerId) || 0;
    customerOrderCounts.set(order.customerId, count + 1);

    // Prepare confirmation emails
    if (order.status === 'completed') {
      emailsToSend.push({
        to: order.customerEmail,
        subject: 'Order Confirmed',
        body: generateOrderEmail(order),
      });
    }

    // Update inventory
    for (const item of order.items) {
      inventory.decrement(item.sku, item.quantity);
    }
  }

  return { totalRevenue, flaggedOrders, customerOrderCounts, emailsToSend };
}
```

**Correct (separate single-purpose functions):**

```typescript
function processOrders(orders: Order[]): ProcessingResult {
  return {
    totalRevenue: calculateTotalRevenue(orders),
    flaggedOrders: findSuspiciousOrders(orders),
    customerOrderCounts: countOrdersByCustomer(orders),
    emailsToSend: prepareConfirmationEmails(orders),
  };
}

function calculateTotalRevenue(orders: Order[]): number {
  return orders.reduce((sum, order) => sum + order.total, 0);
}

function findSuspiciousOrders(orders: Order[]): Order[] {
  return orders.filter(
    order => order.total > 10000 || order.items.length > 50
  );
}

function countOrdersByCustomer(orders: Order[]): Map<string, number> {
  const counts = new Map<string, number>();
  for (const order of orders) {
    const current = counts.get(order.customerId) || 0;
    counts.set(order.customerId, current + 1);
  }
  return counts;
}

function prepareConfirmationEmails(orders: Order[]): Email[] {
  return orders
    .filter(order => order.status === 'completed')
    .map(order => ({
      to: order.customerEmail,
      subject: 'Order Confirmed',
      body: generateOrderEmail(order),
    }));
}

function updateInventory(orders: Order[]): void {
  for (const order of orders) {
    for (const item of order.items) {
      inventory.decrement(item.sku, item.quantity);
    }
  }
}
```

**Incorrect (function with multiple responsibilities):**

```typescript
async function handleUserSignup(data: SignupData) {
  // Validate
  if (!data.email || !isValidEmail(data.email)) {
    throw new Error('Invalid email');
  }
  if (!data.password || data.password.length < 8) {
    throw new Error('Password too short');
  }

  // Check existing
  const existing = await db.users.findByEmail(data.email);
  if (existing) {
    throw new Error('Email already registered');
  }

  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(data.password, salt);

  // Create user
  const user = await db.users.create({
    email: data.email,
    password: hashedPassword,
    createdAt: new Date(),
  });

  // Send welcome email
  await emailService.send({
    to: user.email,
    template: 'welcome',
    data: { name: user.name },
  });

  // Create audit log
  await auditLog.record({
    action: 'user_signup',
    userId: user.id,
    timestamp: new Date(),
  });

  // Initialize settings
  await db.userSettings.create({
    userId: user.id,
    theme: 'light',
    notifications: true,
  });

  return user;
}
```

**Correct (orchestrator with single-purpose helpers):**

```typescript
async function handleUserSignup(data: SignupData): Promise<User> {
  validateSignupData(data);
  await ensureEmailNotTaken(data.email);

  const user = await createUser(data);

  // Post-creation tasks (could be event-driven)
  await Promise.all([
    sendWelcomeEmail(user),
    recordSignupAudit(user),
    initializeUserSettings(user),
  ]);

  return user;
}

function validateSignupData(data: SignupData): void {
  if (!data.email || !isValidEmail(data.email)) {
    throw new ValidationError('Invalid email');
  }
  if (!data.password || data.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters');
  }
}

async function ensureEmailNotTaken(email: string): Promise<void> {
  const existing = await db.users.findByEmail(email);
  if (existing) {
    throw new ConflictError('Email already registered');
  }
}

async function createUser(data: SignupData): Promise<User> {
  const hashedPassword = await hashPassword(data.password);
  return db.users.create({
    email: data.email,
    password: hashedPassword,
    createdAt: new Date(),
  });
}

async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
}
```

### Signs a Block Does Too Much

- Name includes "and" or describes multiple actions
- Multiple unrelated variables being modified
- Comments separating different "sections"
- Difficult to write a focused unit test
- Changes to one part risk breaking another

### Benefits

- Each piece can be tested in isolation
- Functions can be reused in different contexts
- Changes are localized - modify one thing without risking others
- Names become self-documenting
- Easier to parallelize independent operations
