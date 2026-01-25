---
title: Respect Standard Environment Variables
impact: MEDIUM
impactDescription: ensures consistent behavior across tools
tags: config, environment, standards, interoperability
---

## Respect Standard Environment Variables

Honor standard environment variables like `NO_COLOR`, `EDITOR`, `PAGER`, and proxy settings. This ensures your tool integrates well with the user's environment.

**Incorrect (ignores standard variables):**

```c
void open_editor(const char *file) {
    // Hardcoded editor
    execlp("vim", "vim", file, NULL);
}

void show_paged_output(const char *text) {
    // Hardcoded pager
    FILE *p = popen("less", "w");
    fputs(text, p);
    pclose(p);
}

void make_request(const char *url) {
    // Ignores proxy settings
    curl_easy_setopt(curl, CURLOPT_URL, url);
}
```

**Correct (respects standard variables):**

```c
void open_editor(const char *file) {
    const char *editor = getenv("VISUAL");
    if (!editor) editor = getenv("EDITOR");
    if (!editor) editor = "vi";  // POSIX default

    execlp(editor, editor, file, NULL);
}

void show_paged_output(const char *text) {
    const char *pager = getenv("PAGER");
    if (!pager) pager = "less";

    // Don't page if output is not a terminal
    if (!isatty(STDOUT_FILENO)) {
        puts(text);
        return;
    }

    FILE *p = popen(pager, "w");
    fputs(text, p);
    pclose(p);
}

void configure_proxy(CURL *curl) {
    const char *http_proxy = getenv("HTTP_PROXY");
    if (!http_proxy) http_proxy = getenv("http_proxy");
    if (http_proxy) {
        curl_easy_setopt(curl, CURLOPT_PROXY, http_proxy);
    }
}
```

**Standard environment variables:**

| Variable | Purpose |
|----------|---------|
| `EDITOR`, `VISUAL` | Text editor preference |
| `PAGER` | Output pager (less, more) |
| `SHELL` | User's preferred shell |
| `TERM` | Terminal type |
| `HOME` | User's home directory |
| `TMPDIR` | Temporary file directory |
| `TZ` | Timezone |
| `LANG`, `LC_*` | Locale settings |
| `NO_COLOR` | Disable colored output |
| `HTTP_PROXY`, `HTTPS_PROXY` | Proxy settings |
| `NO_PROXY` | Proxy exclusions |

Reference: [POSIX Environment Variables](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html)
