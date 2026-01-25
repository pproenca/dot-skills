---
title: Make Error Messages Actionable
impact: HIGH
impactDescription: reduces user debugging time by 5-10×
tags: error, actionable, usability, debugging
---

## Make Error Messages Actionable

Error messages should tell users what went wrong AND how to fix it. A good error message saves users from searching documentation or Stack Overflow.

**Incorrect (describes problem without solution):**

```c
if (port < 1 || port > 65535) {
    fprintf(stderr, "Invalid port number\n");
    return 1;
}

if (!config_file_exists) {
    fprintf(stderr, "Configuration error\n");
    return 1;
}
```

```bash
$ mytool --port 70000
Invalid port number
# User must guess valid range

$ mytool
Configuration error
# User doesn't know what config or where
```

**Correct (explains problem and suggests fix):**

```c
if (port < 1 || port > 65535) {
    fprintf(stderr, "%s: port %d is out of range (must be 1-65535)\n",
            program_name, port);
    return 1;
}

if (!config_file_exists) {
    fprintf(stderr, "%s: config file not found at %s\n",
            program_name, config_path);
    fprintf(stderr, "  Create one with: %s --init\n", program_name);
    fprintf(stderr, "  Or specify location: %s --config PATH\n", program_name);
    return 1;
}
```

```bash
$ mytool --port 70000
mytool: port 70000 is out of range (must be 1-65535)

$ mytool
mytool: config file not found at ~/.config/mytool/config.yaml
  Create one with: mytool --init
  Or specify location: mytool --config PATH
```

**Actionable error components:**
1. What went wrong (specific value/condition)
2. Why it's wrong (constraint violated)
3. How to fix it (concrete next step)

Reference: [Command Line Interface Guidelines](https://clig.dev/)
