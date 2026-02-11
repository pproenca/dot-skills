---
title: Keep Functions Small
impact: CRITICAL
impactDescription: enables comprehension at a glance
tags: func, size, readability, comprehension
---

## Keep Functions Small

Functions should be small. They should be smaller than that. Functions should hardly ever be 20 lines long. Each function should do one thing, do it well, and do it only.

**Incorrect (large function doing multiple things):**

```java
public void renderPageWithSetupsAndTeardowns(PageData pageData, boolean isSuite) {
    if (isTestPage(pageData)) {
        WikiPage testPage = pageData.getWikiPage();
        StringBuffer newPageContent = new StringBuffer();
        includeSetupPages(testPage, newPageContent, isSuite);
        newPageContent.append(pageData.getContent());
        includeTeardownPages(testPage, newPageContent, isSuite);
        pageData.setContent(newPageContent.toString());
    }
}

private void includeSetupPages(WikiPage testPage, StringBuffer buffer, boolean isSuite) {
    if (isSuite) {
        WikiPage suitePage = PageCrawlerImpl.getInheritedPage(
            SuiteResponder.SUITE_SETUP_NAME, testPage);
        if (suitePage != null) {
            WikiPagePath pagePath = testPage.getPageCrawler()
                .getFullPath(suitePage);
            String pagePathName = PathParser.render(pagePath);
            buffer.append("!include -setup .")
                  .append(pagePathName)
                  .append("\n");
        }
    }
    // ... 20 more lines
}
```

**Correct (small, focused functions):**

```java
public void renderPageWithSetupsAndTeardowns(PageData pageData, boolean isSuite) {
    if (isTestPage(pageData))
        includeSetupsAndTeardowns(pageData, isSuite);
}

private void includeSetupsAndTeardowns(PageData pageData, boolean isSuite) {
    WikiPage testPage = pageData.getWikiPage();
    String content = buildPageContent(testPage, isSuite);
    pageData.setContent(content);
}

private String buildPageContent(WikiPage testPage, boolean isSuite) {
    return getSetups(testPage, isSuite) +
           testPage.getContent() +
           getTeardowns(testPage, isSuite);
}
```

Each function is 3-5 lines. Each does exactly one thing. Each is at one level of abstraction.

**When NOT to apply this pattern:**
- If a 15-20 line function does one thing at one level of abstraction, it does not need further decomposition. The goal is comprehensibility, not minimizing line count.
- Do not extract functions that are only called from one place and whose names merely restate their implementation — this adds indirection without clarity.
- Ousterhout's "deep modules" critique: extremely small functions can create "shallow modules" that spread logic across many files, forcing readers to jump between functions to understand a single behavior. Balance depth (functionality per interface) against size.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
