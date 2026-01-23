---
title: Use Intention-Revealing Names
impact: CRITICAL
impactDescription: eliminates mental mapping overhead
tags: name, intention, readability, clarity
---

## Use Intention-Revealing Names

Names should reveal intent. A name should tell you why something exists, what it does, and how it is used. If a name requires a comment, it does not reveal its intent.

**Incorrect (requires mental decoding):**

```java
int d; // elapsed time in days

public List<int[]> getThem() {
    List<int[]> list1 = new ArrayList<>();
    for (int[] x : theList)
        if (x[0] == 4)  // What is 4? What is x[0]?
            list1.add(x);
    return list1;
}
```

**Correct (self-documenting):**

```java
int elapsedTimeInDays;

public List<Cell> getFlaggedCells() {
    List<Cell> flaggedCells = new ArrayList<>();
    for (Cell cell : gameBoard)
        if (cell.isFlagged())
            flaggedCells.add(cell);
    return flaggedCells;
}
```

The code now explicitly communicates its purpose: finding flagged cells in a minesweeper game. No comment needed.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
