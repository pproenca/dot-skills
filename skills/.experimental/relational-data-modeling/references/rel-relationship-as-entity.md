---
title: Model a many-to-many as an entity when the relationship has facts of its own
tags: rel, many-to-many, join-table, domain-modeling
---

## Model a many-to-many as an entity when the relationship has facts of its own

"Many-to-many" describes cardinality, not design, and treating it as a design
loses the facts that belong to the relationship itself. A bare two-column link
table for `enrollments` has nowhere to put the grade, the enrolment date, or the
withdrawal, so those end up duplicated onto the student or invented in
application code — and the relationship, which the domain talks about by name,
never appears in the schema.

The test is whether the relationship has a name in the domain's language, its
own attributes, or its own lifecycle. If a subject-matter expert says
"enrolment" and can tell you when one starts and ends, it is an entity: name the
table after it and give it the columns. If they only ever say "the tags on a
post", it is a link.

```sql
-- An entity: it is named, dated, and has a state of its own.
CREATE TABLE enrollments (
    student_id    bigint NOT NULL REFERENCES students,
    section_id    bigint NOT NULL REFERENCES course_sections,
    enrolled_on   date   NOT NULL,
    withdrawn_on  date,
    final_grade   numeric(4,2),
    PRIMARY KEY (student_id, section_id),
    CHECK (withdrawn_on IS NULL OR withdrawn_on >= enrolled_on),
    CHECK (final_grade IS NULL OR withdrawn_on IS NULL)
);

-- A link: the pairing is the entire fact.
CREATE TABLE post_tags (
    post_id  bigint NOT NULL REFERENCES posts ON DELETE CASCADE,
    tag_id   bigint NOT NULL REFERENCES tags,
    PRIMARY KEY (post_id, tag_id)
);
```

That key is deliberately restrictive, and it is worth seeing what it decides:
`PRIMARY KEY (student_id, section_id)` says a student enrols in a given section
at most once ever, so a repeat after withdrawal is unrepresentable. If the domain
allows re-enrolment, the identity is not the pair but the pair *over a period* —
which is a temporal key, not an extra `id` column. See
[`time-validity-as-a-range`](time-validity-as-a-range.md). The same goes for the
`final_grade` check above: it forbids grading anyone who withdrew, which is right
in some institutions and wrong in others. Constraints on a relationship encode
policy, so read them as policy.

The promotion is one-directional in practice: link tables acquire attributes as
domains mature, entities rarely lose them. When a link table gains its second
attribute, that is the signal to rename it after what it actually represents —
`post_tags` becoming `taggings` with a `tagged_by` and `tagged_at` is a real
change in what the table means, not a cosmetic one.

Reference: [Fowler, *PoEAA*: Association Table Mapping](https://martinfowler.com/eaaCatalog/associationTableMapping.html)
