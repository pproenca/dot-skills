---
title: Make the Application Completely Self-Contained with Embedded Server
impact: MEDIUM
impactDescription: simplifies deployment, removes webserver injection dependency
tags: port, self-contained, webserver, binding
---

## Make the Application Completely Self-Contained with Embedded Server

A twelve-factor app is completely self-contained and does not rely on runtime injection of a webserver. The app exports HTTP (or other protocols) as a service by binding to a port, using a webserver library that is part of the application's dependencies.

**Incorrect (requires external webserver):**

```apache
# Apache config - app requires Apache to run
<VirtualHost *:80>
    ServerName myapp.com
    WSGIScriptAlias / /var/www/myapp/wsgi.py
    # App cannot run without Apache
    # Different servers need different configs
    # Deployment complexity increases
</VirtualHost>
```

```php
<!-- PHP requires Apache/nginx mod_php or php-fpm -->
<!-- index.php cannot listen on a port by itself -->
<?php
// No way to "run" this standalone
echo "Hello World";
?>
```

**Correct (self-contained with embedded server):**

```python
# Python with Gunicorn - webserver is a dependency
# requirements.txt: gunicorn==21.2.0

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello World"

# Run with: gunicorn app:app --bind 0.0.0.0:$PORT
# No Apache/nginx required - app binds directly to port
```

```javascript
// Node.js - http server is built into the language
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World');
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
// No external webserver needed
```

```go
// Go - standard library includes http server
package main

import (
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("Hello World"))
    })

    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    http.ListenAndServe(":"+port, nil)
}
// Single binary serves HTTP directly
```

**Benefits:**
- `docker run -p 8080:8080 myapp` just works
- Same deployment model across all languages
- Local development matches production
- Platform assigns port, app binds to it

Reference: [The Twelve-Factor App - Port Binding](https://12factor.net/port-binding)
