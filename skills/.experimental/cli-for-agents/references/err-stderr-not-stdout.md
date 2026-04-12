---
title: Send Errors and Warnings to stderr, Not stdout
impact: HIGH
impactDescription: prevents error text from corrupting piped data
tags: err, stderr, stdout, pipes
---

## Send Errors and Warnings to stderr, Not stdout

When an agent pipes `mycli service list | jq '.[].name'`, error text mixed into stdout breaks the JSON parser downstream. The UNIX convention is strict: success data goes to stdout, everything else — errors, warnings, progress, debug — goes to stderr. An agent that redirects `2>/dev/null` still gets clean data on stdout; an agent that wants both can redirect separately.

**Incorrect (errors printed to stdout via console.log):**

```javascript
#!/usr/bin/env node
async function listServices() {
  try {
    const services = await api.listServices();
    for (const s of services) {
      console.log(JSON.stringify(s));
    }
  } catch (err) {
    // Error message mixes into the JSON stream downstream
    console.log(`Error: ${err.message}`);
    process.exit(1);
  }
}
listServices();
```

**Correct (data to stdout, errors and diagnostics to stderr):**

```javascript
#!/usr/bin/env node
async function listServices() {
  try {
    const services = await api.listServices();
    for (const s of services) {
      process.stdout.write(JSON.stringify(s) + '\n');
    }
  } catch (err) {
    process.stderr.write(`Error: ${err.message}\n`);
    process.exit(1);
  }
}
listServices();
```

**Benefits:**
- `mycli list | jq ...` still works even on partial failures
- `mycli list 2>/dev/null` silences warnings without losing data
- `mycli list > data.json 2> errors.log` captures them separately

Reference: [clig.dev — Send output to stdout, messages to stderr](https://clig.dev/#the-basics)
