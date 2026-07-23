---
title: Enforce disjoint subtypes through the key
tags: rel, inheritance, supertype-subtype, discriminator
---

## Enforce disjoint subtypes through the key

Variants of one entity — payment methods that are cards or bank accounts,
accounts that are checking or savings — get modelled one of two ways by default,
and both leave the disjointness to application code. A single table with a `kind`
column and a union of every variant's columns cannot make the card columns
required for cards, because a `NOT NULL` applies to every row; so all of them
become nullable and the real rule ("if kind is 'card', expiry must be present")
lives in a validator somewhere. Splitting into one table per variant fixes the
nullability but introduces a worse problem: nothing stops the same payment
method id from appearing in *both* subtype tables.

Carrying the discriminator into the key fixes both. The supertype holds the
identity and the `kind`, exposes `UNIQUE (id, kind)` so the pair is referenceable,
and each subtype pins its own `kind` with a `CHECK` and references the pair:

```sql
CREATE TABLE payment_methods (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kind         text   NOT NULL CHECK (kind IN ('card', 'bank_account')),
    customer_id  bigint NOT NULL REFERENCES customers,
    added_at     timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, kind)
);

CREATE TABLE payment_cards (
    id          bigint PRIMARY KEY,
    kind        text NOT NULL GENERATED ALWAYS AS ('card') STORED,
    last_four   text NOT NULL CHECK (last_four ~ '^[0-9]{4}$'),
    expires_on  date NOT NULL,
    network     text NOT NULL,
    FOREIGN KEY (id, kind) REFERENCES payment_methods (id, kind) ON DELETE CASCADE
);

CREATE TABLE payment_bank_accounts (
    id              bigint PRIMARY KEY,
    kind            text NOT NULL GENERATED ALWAYS AS ('bank_account') STORED,
    routing_number  text NOT NULL CHECK (routing_number ~ '^[0-9]{9}$'),
    account_last4   text NOT NULL CHECK (account_last4 ~ '^[0-9]{4}$'),
    FOREIGN KEY (id, kind) REFERENCES payment_methods (id, kind) ON DELETE CASCADE
);
```

A card row can only reference a supertype row whose `kind` is `'card'`, so the
same id cannot also appear in `payment_bank_accounts` — the database proves the
variants are disjoint. Each subtype's columns are `NOT NULL` because within that
table they always apply. The generated `kind` column removes the chance of
inserting the wrong literal.

**When NOT to use this pattern:** the variants must genuinely differ in their
*required* columns. If the subtypes share every column and differ only in
behaviour, a single table with a `kind` column is correct and this structure is
three tables and two joins buying nothing. If a row can legitimately be more
than one variant at once, the variants are not subtypes — they are optional
facets, and each gets its own table with a plain foreign key.

Reference: [Fowler, *PoEAA*: Class Table Inheritance](https://martinfowler.com/eaaCatalog/classTableInheritance.html), [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
