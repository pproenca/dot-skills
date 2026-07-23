# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — the decisions that come up in every schema, and cost most when
wrong, go first.

Examples are written for **PostgreSQL 18**, because roughly a third of these
rules depend on mechanisms MySQL and SQLite do not have (`EXCLUDE`, partial
unique indexes, range types, `WITHOUT OVERLAPS`, deferrable constraints,
`NOT VALID`). Where a rule is about judgment rather than syntax, it transfers to
any relational engine; where it is Postgres-specific, the rule says so.

The scope is what a capable model gets *wrong*. It already normalizes to roughly
third normal form, declares foreign keys, and adds `created_at`. What it gets
wrong is importing ORM habits that discard referential integrity, and not
knowing the engine can prove an invariant that it instead leaves to application
code.

---

## 1. Identity and Keys (key)

**Description:** What a row *is*. The primary key is the one decision every
foreign key in the schema depends on, so it is the most expensive to change and
the one most often made by reflex — a surrogate `id` stamped on every table
without asking what actually makes a row unique. This category also covers the
two key choices that only hurt much later: the generator (`serial` vs identity
vs UUID) and whether the key can survive partitioning.

## 2. Relationships and Cardinality (rel)

**Description:** How tables connect. This is where framework defaults do the
most damage: polymorphic association columns that no foreign key can constrain,
link tables that are really entities (or entities that are really link tables),
blanket `ON DELETE CASCADE`, and one-to-one splits that buy a join and enforce
nothing. Every rule here is about keeping the relationship *declarable* to the
database rather than merely intended by the application.

## 3. Constraints as the Model (cons)

**Description:** The invariants the schema itself enforces. A constraint the
database checks cannot be bypassed by a background job, a psql session, a
retried request, or a second service — application-level checks can be bypassed
by all five, and the ones that read-then-write also race. This category covers
which mechanism expresses which shape of invariant, and how to add one to a
table that already has rows in it.

## 4. Types and Domains (type)

**Description:** Choosing the column type for what the value *means*, not out of
habit. A type is the cheapest constraint available: it is checked on every write,
costs nothing at runtime, and rules out whole classes of bad row before any
`CHECK` runs. The wrong defaults here are inherited from other engines and other
decades — `varchar(255)`, naive `timestamp`, floats for money, status columns
whose allowed values exist only in application code.

## 5. Derived and Encoded Data (norm)

**Description:** What it costs to store a fact twice, and what the database
cannot see inside. No constraint can hold two copies of a value equal, so every
deliberate copy needs a mechanism the engine runs rather than a promise the
application makes. The same blindness applies to structure hidden inside a
value — an encoded reference code, a JSON blob holding known attributes — where
the parts exist but no foreign key, type, or statistic can reach them.

## 6. Time, History and Lifecycle (time)

**Description:** What happens to a row when the world changes. The default is to
`UPDATE` it, which destroys the only record of why the value changed, and to add
a `deleted_at` flag, which silently disables the unique constraints and foreign
keys on that table. These rules cover when a change is an event rather than an
edit, and how to model validity over time so that "what was true on 1 March" is
a query rather than an archaeology project.
