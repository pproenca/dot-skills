---
title: Specify Data Models and Schema Changes
impact: MEDIUM
impactDescription: reduces database migration failures by 80%
tags: tech, data, schema, database
---

## Specify Data Models and Schema Changes

Document data models, relationships, and migration strategies before implementation. Undocumented schema changes cause data integrity issues, failed migrations, and production incidents.

**Incorrect (implementation-time schema design):**

```markdown
## Feature: Subscription Tiers

We need to track user subscriptions with different tiers.

// Developer interprets this as:
// - Adds tier column to users table
// - Another dev adds separate subscriptions table
// - Migration conflicts in production
// - Data inconsistency between interpretations
```

**Correct (explicit data model specification):**

```markdown
## Data Model: Subscription Management

### Entity Relationship Diagram

```text
┌─────────────────┐       ┌─────────────────────┐
│      User       │       │   SubscriptionPlan  │
├─────────────────┤       ├─────────────────────┤
│ id (PK)         │       │ id (PK)             │
│ email           │       │ name                │
│ created_at      │       │ price_cents         │
└────────┬────────┘       │ billing_period      │
         │                │ features (JSONB)    │
         │ 1:N            │ is_active           │
         │                └──────────┬──────────┘
         ▼                           │
┌─────────────────────┐              │
│    Subscription     │◄─────────────┘
├─────────────────────┤     N:1
│ id (PK)             │
│ user_id (FK)        │
│ plan_id (FK)        │
│ status              │
│ current_period_start│
│ current_period_end  │
│ canceled_at         │
│ created_at          │
│ updated_at          │
└─────────────────────┘
```

### Schema Definitions

**Table: subscription_plans**
```sql
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
    billing_period VARCHAR(20) NOT NULL CHECK (billing_period IN ('monthly', 'yearly')),
    features JSONB NOT NULL DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscription_plans_slug ON subscription_plans(slug);
CREATE INDEX idx_subscription_plans_active ON subscription_plans(is_active) WHERE is_active = true;
```

**Table: subscriptions**
```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'past_due', 'canceled', 'trialing')),
    current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    canceled_at TIMESTAMP WITH TIME ZONE,
    stripe_subscription_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_active_subscription UNIQUE (user_id)
        WHERE status IN ('active', 'trialing')
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_period_end ON subscriptions(current_period_end);
```

### Migration Strategy

**Phase 1: Add tables (non-breaking)**
```sql
-- Migration: 20240315_001_create_subscription_tables.sql
-- Safe to run: Yes (additive only)
-- Rollback: DROP TABLE subscriptions, subscription_plans;

BEGIN;
-- Create tables as defined above
COMMIT;
```

**Phase 2: Seed initial plans**
```sql
-- Migration: 20240315_002_seed_subscription_plans.sql
INSERT INTO subscription_plans (name, slug, price_cents, billing_period, features)
VALUES
    ('Free', 'free', 0, 'monthly', '{"projects": 3, "storage_gb": 1}'),
    ('Pro', 'pro', 1999, 'monthly', '{"projects": -1, "storage_gb": 100}'),
    ('Enterprise', 'enterprise', 9999, 'monthly', '{"projects": -1, "storage_gb": -1}');
```

**Phase 3: Migrate existing users**
```sql
-- Migration: 20240315_003_migrate_existing_users.sql
-- Creates subscriptions for existing users based on current tier
INSERT INTO subscriptions (user_id, plan_id, status, current_period_start, current_period_end)
SELECT
    u.id,
    sp.id,
    'active',
    u.created_at,
    u.created_at + INTERVAL '1 month'
FROM users u
CROSS JOIN subscription_plans sp
WHERE sp.slug = 'free'
AND NOT EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id = u.id);
```

### Data Constraints

| Constraint | Rule | Enforcement |
|------------|------|-------------|
| One active subscription | User can have only one active/trialing subscription | DB constraint |
| Valid status transitions | active → canceled, trialing → active/canceled | Application code |
| Price non-negative | price_cents >= 0 | DB CHECK constraint |
| Period integrity | period_end > period_start | Application validation |
```

**Data model checklist:**
- Entity relationships clearly diagrammed
- All columns with types and constraints
- Indexes for query patterns
- Migration strategy with rollback
- Data integrity rules documented

Reference: [Prisma Schema Best Practices](https://www.prisma.io/docs/orm/prisma-schema)
