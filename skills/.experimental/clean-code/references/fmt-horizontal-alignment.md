---
title: Avoid Horizontal Alignment
impact: MEDIUM
impactDescription: prevents alignment maintenance burden
tags: fmt, horizontal, alignment, whitespace
---

## Avoid Horizontal Alignment

Horizontal alignment of variable declarations or assignments looks nice but creates maintenance problems. When one line changes length, all aligned lines need reformatting.

**Incorrect (horizontal alignment):**

```java
private   Socket          socket;
private   InputStream     input;
private   OutputStream    output;
private   Request         request;
private   Response        response;
private   FitNesseContext context;
private   long            requestParsingTimeLimit;
private   long            requestProgress;

public void setResponse(Response       response)  { this.response  = response;  }
public void setSocket(Socket           socket)    { this.socket    = socket;    }
public void setContext(FitNesseContext context)   { this.context   = context;   }
```

**Correct (natural formatting):**

```java
private Socket socket;
private InputStream input;
private OutputStream output;
private Request request;
private Response response;
private FitNesseContext context;
private long requestParsingTimeLimit;
private long requestProgress;

public void setResponse(Response response) {
    this.response = response;
}

public void setSocket(Socket socket) {
    this.socket = socket;
}

public void setContext(FitNesseContext context) {
    this.context = context;
}
```

**Why avoid alignment?**
- Adding a longer variable name requires reformatting all lines
- Eyes are drawn to the wrong thing (the alignment, not the names)
- Most formatters don't preserve it anyway

Reference: [Clean Code, Chapter 5: Formatting](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
