---
title: Show Default Values in Help
impact: MEDIUM-HIGH
impactDescription: reduces trial-and-error configuration
tags: help, defaults, documentation, usability
---

## Show Default Values in Help

Display default values for all options that have them. Users should know what happens without specifying each option.

**Incorrect (defaults not shown):**

```c
printf("Options:\n");
printf("  -t, --timeout=SEC   connection timeout\n");
printf("  -r, --retries=N     number of retries\n");
printf("  -p, --port=PORT     server port\n");
```

```bash
$ mytool --help
Options:
  -t, --timeout=SEC   connection timeout
  -r, --retries=N     number of retries
  -p, --port=PORT     server port
# What are the defaults? User must guess or read source
```

**Correct (defaults clearly shown):**

```c
printf("Options:\n");
printf("  -t, --timeout=SEC   connection timeout in seconds (default: 30)\n");
printf("  -r, --retries=N     number of retries on failure (default: 3)\n");
printf("  -p, --port=PORT     server port (default: 8080)\n");
printf("  -l, --log=LEVEL     log level: debug, info, warn, error (default: info)\n");
printf("  -c, --config=FILE   config file (default: ~/.config/mytool/config.yaml)\n");
```

```bash
$ mytool --help
Options:
  -t, --timeout=SEC   connection timeout in seconds (default: 30)
  -r, --retries=N     number of retries on failure (default: 3)
  -p, --port=PORT     server port (default: 8080)
  -l, --log=LEVEL     log level: debug, info, warn, error (default: info)
  -c, --config=FILE   config file (default: ~/.config/mytool/config.yaml)
```

**Formatting conventions:**
- `(default: VALUE)` at end of description
- List valid options for enum-like values
- Show both the value and its meaning when not obvious

Reference: [Command Line Interface Guidelines](https://clig.dev/)
