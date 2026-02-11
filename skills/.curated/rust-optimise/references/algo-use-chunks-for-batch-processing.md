---
title: Use chunks() for Batch Processing
impact: MEDIUM
impactDescription: reduces overhead per element
tags: algo, chunks, batch, processing, iteration
---

## Use chunks() for Batch Processing

Processing elements in batches reduces per-element overhead for operations like database inserts or API calls.

**Incorrect (element by element):**

```rust
async fn insert_users(db: &Database, users: Vec<User>) -> Result<(), Error> {
    for user in users {
        db.insert(&user).await?;  // N round trips
    }
    Ok(())
}
```

**Correct (batch processing):**

```rust
async fn insert_users(db: &Database, users: Vec<User>) -> Result<(), Error> {
    for batch in users.chunks(100) {
        db.insert_batch(batch).await?;  // N/100 round trips
    }
    Ok(())
}
```

**For owned data, use chunks_exact or array_chunks:**

```rust
fn process_pixels(pixels: &[u8]) -> Vec<Color> {
    pixels
        .chunks_exact(4)  // RGBA bytes
        .map(|chunk| Color::from_rgba(chunk[0], chunk[1], chunk[2], chunk[3]))
        .collect()
}
```

**Chunk variants:**
- `chunks(n)`: Yields slices of up to n elements
- `chunks_exact(n)`: Yields slices of exactly n (ignores remainder)
- `array_chunks()`: Yields fixed-size arrays (nightly)

Reference: [slice::chunks documentation](https://doc.rust-lang.org/std/primitive.slice.html#method.chunks)
