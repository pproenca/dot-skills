---
title: Avoid Cryptic Abbreviations
impact: MEDIUM-HIGH
impactDescription: Full words reduce misinterpretation risk and eliminate the 5-10 seconds developers spend deciphering each abbreviation
tags: name, readability, abbreviations, clarity, onboarding
---

## Avoid Cryptic Abbreviations

Abbreviations save a few keystrokes but cost readers significant mental effort to decode. What seems obvious to the author (who just created the abbreviation) becomes a puzzle for future readers. Use complete words that anyone can understand without context clues or tribal knowledge.

**Incorrect (cryptic abbreviations):**

```typescript
// Bad: What do these mean?
const usrMgr = new UserManager();
const cfg = loadConfig();
const txn = db.beginTransaction();
const btn = document.getElementById('submit');
const req = new HttpRequest();
const res = await fetch(url);
const err = validate(input);
const tmp = calculateIntermediate();
const cnt = items.length;
const idx = findPosition(target);
const ctx = createContext();
const val = getValue();
const cb = () => console.log('done');
```

**Correct (full words):**

```typescript
// Good: immediately understandable
const userManager = new UserManager();
const configuration = loadConfig();
const transaction = db.beginTransaction();
const submitButton = document.getElementById('submit');
const httpRequest = new HttpRequest();
const response = await fetch(url);
const validationError = validate(input);
const intermediateResult = calculateIntermediate();
const itemCount = items.length;
const targetIndex = findPosition(target);
const requestContext = createContext();
const currentValue = getValue();
const onComplete = () => console.log('done');
```

**Incorrect (Python - domain abbreviations):**

```python
# Bad: abbreviations require domain knowledge
def calc_ttl_amt(ord_itms, disc_pct):
    subtl = sum(itm.prc * itm.qty for itm in ord_itms)
    return subtl * (1 - disc_pct)

# What does this even mean?
cust_addr_ln1 = get_cust_info()['addr']['ln1']
```

**Correct (Python - spelled out):**

```python
# Good: no guessing required
def calculate_total_amount(order_items, discount_percentage):
    subtotal = sum(item.price * item.quantity for item in order_items)
    return subtotal * (1 - discount_percentage)

customer_address_line1 = get_customer_info()['address']['line1']
```

**Incorrect (Go - excessive shortening):**

```go
// Bad: Go convention taken too far
func procReq(r *http.Req, w http.RespWriter) {
    usr := getUsr(r.Ctx())
    if usr == nil {
        w.WriteHdr(401)
        return
    }
    rsp := buildRsp(usr)
    json.NewEnc(w).Enc(rsp)
}
```

**Correct (Go - balanced naming):**

```go
// Good: clear but still idiomatic Go
func processRequest(request *http.Request, writer http.ResponseWriter) {
    user := getUser(request.Context())
    if user == nil {
        writer.WriteHeader(401)
        return
    }
    response := buildResponse(user)
    json.NewEncoder(writer).Encode(response)
}
```

### Acceptable Abbreviations

Some abbreviations are so universally understood they are acceptable:

| Abbreviation | Meaning | Context |
|--------------|---------|---------|
| `id` | identifier | Universal |
| `url` | uniform resource locator | Web development |
| `api` | application programming interface | Programming |
| `http` | hypertext transfer protocol | Web development |
| `db` | database | When context is obvious |
| `io` | input/output | Systems programming |
| `i`, `j`, `k` | loop indices | Small loop scopes |
| `e`, `err` | error | Go convention, catch blocks |
| `ctx` | context | Go convention only |

### When NOT to Apply

- Well-established domain acronyms (HTML, JSON, SQL, UUID)
- Industry-standard abbreviations (API, HTTP, URL)
- Language-specific idioms (`err` in Go, `e` in catch blocks)
- Mathematical notation in algorithms

### Benefits

- Zero decoding time for readers
- New team members productive immediately
- No tribal knowledge required
- Reduces bugs from misinterpreted abbreviations
- Code is searchable with full words
