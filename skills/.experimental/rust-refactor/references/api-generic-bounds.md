---
title: Use Trait Bounds for Generic Flexibility
impact: HIGH
impactDescription: 10× code reuse through single generic implementation
tags: api, generics, trait-bounds, flexibility, where
---

## Use Trait Bounds for Generic Flexibility

Use trait bounds instead of concrete types to accept any implementation of a behavior. This maximizes code reuse.

**Incorrect (concrete types limit flexibility):**

```rust
fn write_log(writer: &mut File, message: &str) -> io::Result<()> {
    writeln!(writer, "{}", message)
}

fn read_all(reader: &mut BufReader<File>) -> io::Result<String> {
    let mut content = String::new();
    reader.read_to_string(&mut content)?;
    Ok(content)
}
```

**Correct (trait bounds accept any implementation):**

```rust
use std::io::{Write, BufRead, Read};

fn write_log<W: Write>(writer: &mut W, message: &str) -> io::Result<()> {
    writeln!(writer, "{}", message)
}

fn read_all<R: Read>(reader: &mut R) -> io::Result<String> {
    let mut content = String::new();
    reader.read_to_string(&mut content)?;
    Ok(content)
}

// Now works with any writer/reader
fn main() -> io::Result<()> {
    let mut stdout = io::stdout();
    write_log(&mut stdout, "Hello")?;  // Works with stdout

    let mut file = File::create("log.txt")?;
    write_log(&mut file, "Hello")?;  // Works with files

    let mut buffer = Vec::new();
    write_log(&mut buffer, "Hello")?;  // Works with Vec
    Ok(())
}
```

**Where clause for complex bounds:**

```rust
fn process<T, U>(item: T, config: U) -> T::Output
where
    T: Process + Clone,
    U: Config + Default,
{
    // Complex bounds are more readable with where
}
```

Reference: [Generics - Rust Book](https://doc.rust-lang.org/book/ch10-02-traits.html)
