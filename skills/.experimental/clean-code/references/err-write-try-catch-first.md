---
title: Write Try-Catch-Finally First
impact: MEDIUM
impactDescription: prevents missing error handling cases
tags: err, try-catch, tdd, boundaries
---

## Write Try-Catch-Finally First

When writing code that could throw exceptions, start with the try-catch-finally statement. This helps define what the user of the code should expect, regardless of what goes wrong in the try block.

**Incorrect (error handling added as afterthought):**

```java
// Written without considering error cases
public List<RecordedGrip> retrieveSection(String sectionName) {
    FileInputStream stream = new FileInputStream(sectionName);
    BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
    String line;
    List<RecordedGrip> grips = new ArrayList<>();
    while ((line = reader.readLine()) != null) {
        grips.add(parseGrip(line));
    }
    return grips;
    // What if file doesn't exist? What if parsing fails?
}
```

**Correct (start with try-catch structure):**

```java
// TDD approach: start with test for exception case
@Test(expected = StorageException.class)
public void retrieveSectionShouldThrowOnInvalidFileName() {
    sectionStore.retrieveSection("invalid-file");
}

// Then write code starting with try-catch
public List<RecordedGrip> retrieveSection(String sectionName) throws StorageException {
    try {
        FileInputStream stream = new FileInputStream(sectionName);
        try {
            return readGrips(stream);
        } finally {
            stream.close();
        }
    } catch (IOException e) {
        throw new StorageException("Error reading section: " + sectionName, e);
    }
}
```

**Benefits:**
- Forces you to consider error cases first
- Establishes clear transaction boundaries
- The finally block ensures cleanup happens

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
