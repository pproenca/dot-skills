# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the decisions that come up most often and cost most when wrong go first.

---

## 1. Design Process & Requirements (proc)

**Description:** How to approach the work: design the logical structure independent of any RDBMS, follow the design steps in order, and drive the whole thing from a mission statement and analysis of real information requirements rather than assumptions. These decisions frame everything else — a schema designed against the wrong requirements, or against a specific product's quirks, has to be rebuilt rather than patched.

## 2. Table Structure (tbl)

**Description:** Deciding what each table is. Every table must represent exactly one subject, carry only fields that belong to that subject, and hold the absolute minimum of redundant data. Wrong table decomposition is the single most expensive mistake — it propagates duplicate data, inconsistency, and modification anomalies into every field, key, and relationship built on top of it.

## 3. Field Design (fld)

**Description:** Deciding what each field is. A field holds one atomic value that describes a single characteristic of the table's subject, is not a stored calculation, and is named so its meaning is unambiguous. Multivalued, multipart, and calculated fields are the field-level defects that force the table structure to be reworked.

## 4. Keys (key)

**Description:** Choosing the identifiers. Every table needs one primary key drawn from its candidate keys; foreign keys mirror the primary keys they reference. Keys are what make records addressable and relationships enforceable, so a table without a sound key cannot have sound integrity.

## 5. Relationships (rel)

**Description:** Connecting the tables. Establish the relationship type, place foreign keys correctly, resolve many-to-many with a junction table, and define a deletion rule and participation for each relationship. These characteristics are where referential integrity and real business constraints live.

## 6. Data Integrity, Rules & Views (intg)

**Description:** Guaranteeing the data stays valid and usable. The four levels of integrity, the field specification that pins down each field, business rules that impose constraints, validation tables for allowed values, and views for derived or restricted data. This is the layer that turns a set of sound structures into a trustworthy database.

## 7. Antipatterns (anti)

**Description:** The designs to recognize and reject: the single-giant-table flat file, the spreadsheet pressed into service as a database, and letting the RDBMS product dictate the design — plus the only two circumstances under which bending the rules is defensible, and how to do it deliberately.

## 8. Terminology (term)

**Description:** The precise vocabulary the methodology depends on — data versus information, what a null actually means, and the core relational terms — so that structural rules are read and applied with the intended meaning rather than loose approximations.
