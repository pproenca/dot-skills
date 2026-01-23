---
title: Use Vertical Formatting for Readability
impact: HIGH
impactDescription: enables scanning code like a newspaper
tags: fmt, vertical, whitespace, organization
---

## Use Vertical Formatting for Readability

Code should read like a newspaper article: headline at the top, details as you go down. Use vertical whitespace to separate concepts. Keep related code close together.

**Incorrect (no vertical organization):**

```java
public class WikiPageResponder implements SecureResponder {
private static final String CONTENT_TYPE = "text/html";
private WikiPage page;
private PageData pageData;
private String pageTitle;
private Request request;
private PageCrawler crawler;
public Response makeResponse(FitNesseContext context, Request request) {
this.request = request;
this.page = loadPage();
if (page == null)
return notFoundResponse(context, request);
return makePageResponse(context);
}
private WikiPage loadPage() {
String resource = request.getResource();
return PageCrawlerImpl.getPageCrawler(context.root).getPage(resource);
}
}
```

**Correct (vertical formatting applied):**

```java
public class WikiPageResponder implements SecureResponder {

    private static final String CONTENT_TYPE = "text/html";

    private WikiPage page;
    private PageData pageData;
    private String pageTitle;
    private Request request;
    private PageCrawler crawler;

    public Response makeResponse(FitNesseContext context, Request request) {
        this.request = request;
        this.page = loadPage();

        if (page == null)
            return notFoundResponse(context, request);

        return makePageResponse(context);
    }

    private WikiPage loadPage() {
        String resource = request.getResource();
        return PageCrawlerImpl.getPageCrawler(context.root).getPage(resource);
    }
}
```

**Guidelines:**
- Blank lines between concepts (methods, logical sections)
- Related code grouped together
- Caller above callee (top-down reading)
- Variable declarations close to their usage

Reference: [Clean Code, Chapter 5: Formatting](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
