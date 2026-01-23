---
title: Organize Classes for Change
impact: MEDIUM
impactDescription: minimizes modification risk when requirements change
tags: class, ocp, change, design
---

## Organize Classes for Change

Classes should be organized so that change is minimally invasive. Following the Open-Closed Principle (OCP): classes should be open for extension but closed for modification.

**Incorrect (must modify class for each new SQL type):**

```java
public class Sql {
    public Sql(String table, Column[] columns) { /* ... */ }

    public String create() { /* ... */ }
    public String insert(Object[] fields) { /* ... */ }
    public String selectAll() { /* ... */ }
    public String findByKey(String key) { /* ... */ }
    // Must modify this class to add update, delete, etc.
    // Each change risks breaking existing functionality
}
```

**Correct (extend without modifying):**

```java
public abstract class Sql {
    protected String table;
    protected Column[] columns;

    public Sql(String table, Column[] columns) {
        this.table = table;
        this.columns = columns;
    }

    public abstract String generate();
}

public class CreateSql extends Sql {
    public CreateSql(String table, Column[] columns) {
        super(table, columns);
    }

    public String generate() { /* CREATE TABLE ... */ }
}

public class InsertSql extends Sql {
    private Object[] fields;

    public InsertSql(String table, Column[] columns, Object[] fields) {
        super(table, columns);
        this.fields = fields;
    }

    public String generate() { /* INSERT INTO ... */ }
}

// Adding UpdateSql doesn't require modifying existing classes
public class UpdateSql extends Sql { /* ... */ }
```

**Benefits:**
- Adding new SQL types = adding new classes
- Existing classes remain untouched
- Each class does one thing

Reference: [Clean Code, Chapter 10: Classes](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
