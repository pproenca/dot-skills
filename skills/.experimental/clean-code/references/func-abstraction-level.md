---
title: Maintain One Level of Abstraction
impact: CRITICAL
impactDescription: prevents jarring context switches
tags: func, abstraction, stepdown, readability
---

## Maintain One Level of Abstraction

Statements within a function should all be at the same level of abstraction. Mixing high-level concepts with low-level details is confusing. Code should read like a top-down narrative.

**Incorrect (mixed abstraction levels):**

```java
public void analyzeDocument(String documentPath) {
    // High level
    Document document = loadDocument(documentPath);

    // Low level - string manipulation details
    String text = document.getText();
    text = text.replaceAll("\\s+", " ");
    text = text.toLowerCase();
    String[] words = text.split(" ");

    // High level again
    WordFrequency frequency = analyzeFrequency(words);

    // Low level - file I/O details
    FileOutputStream fos = new FileOutputStream("output.txt");
    BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(fos));
    for (Map.Entry<String, Integer> entry : frequency.getEntries()) {
        writer.write(entry.getKey() + ": " + entry.getValue());
        writer.newLine();
    }
    writer.close();
}
```

**Correct (consistent abstraction level):**

```java
public void analyzeDocument(String documentPath) {
    Document document = loadDocument(documentPath);
    String normalizedText = normalizeText(document);
    WordFrequency frequency = analyzeFrequency(normalizedText);
    saveResults(frequency);
}

private String normalizeText(Document document) {
    String text = document.getText();
    text = collapseWhitespace(text);
    text = toLowerCase(text);
    return text;
}

private void saveResults(WordFrequency frequency) {
    ResultWriter writer = new ResultWriter("output.txt");
    writer.write(frequency);
}
```

Read the code from top to bottom. Each function introduces the next level of abstraction.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
