---
title: Start from a mission statement and mission objectives
tags: proc, requirements, scope
---

## Start from a mission statement and mission objectives

The wrong default is to start listing tables from a guess about the domain. Without a stated purpose there is no test for whether a table, field, or relationship belongs in the database, so scope drifts and unrelated subjects accrete. The mission statement (one or two sentences on why the database exists) and the mission objectives (the specific tasks it must support) are that test: the objectives name the actions the organization performs on its data, and each action points at the subjects — the tables — the database needs.

A mission statement is well-written when it states the database's purpose succinctly, avoids describing specific tasks, and makes sense both to you and to the people the database is for. A mission objective is a single declarative sentence naming one general task, free of unnecessary detail.

```text
Mission statement:
  "The purpose of the Mike's Bikes database is to maintain the data we use to
   support our sales, service, and inventory activities."

Mission objectives (each implies a subject/table):
  - Keep track of our customers                → CUSTOMERS
  - Keep track of every sale                   → SALES, SALE ITEMS
  - Keep track of the products we sell         → PRODUCTS
  - Keep track of each service performed       → SERVICES
```
