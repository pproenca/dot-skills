---
title: Benchmark Critical Paths with Criterion
impact: LOW-MEDIUM
impactDescription: detects 5%+ performance regressions
tags: perf, benchmarks, criterion, regression, measurement
---

## Benchmark Critical Paths with Criterion

Use Criterion for benchmarking performance-critical code. It provides statistical analysis, comparison with baselines, and regression detection.

**Incorrect (no benchmarking, regressions undetected):**

```rust
// No benchmarks - performance regressions go unnoticed
// "It seems slower" is not actionable data

#[test]
fn test_parse_document() {
    let result = parse_document(SAMPLE_INPUT);
    assert!(result.is_ok());
    // No timing information, no regression detection
}
```

**Correct (Criterion benchmarks with regression detection):**

```rust
// benches/parser_benchmarks.rs
use criterion::{criterion_group, criterion_main, Criterion, black_box};
use mylib::parse_document;

fn benchmark_parse(c: &mut Criterion) {
    let input = include_str!("fixtures/sample.txt");

    c.bench_function("parse_document", |b| {
        b.iter(|| parse_document(black_box(input)))
    });
}

criterion_group!(benches, benchmark_parse);
criterion_main!(benches);
```

**Cargo.toml setup:**

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "parser_benchmarks"
harness = false
```

**Comparing implementations:**

```rust
fn benchmark_sort_algorithms(c: &mut Criterion) {
    let mut group = c.benchmark_group("sorting");
    let data: Vec<i32> = (0..10000).rev().collect();

    group.bench_function("quicksort", |b| {
        b.iter_batched(|| data.clone(), |mut v| quicksort(&mut v), BatchSize::SmallInput)
    });

    group.bench_function("mergesort", |b| {
        b.iter_batched(|| data.clone(), |mut v| mergesort(&mut v), BatchSize::SmallInput)
    });

    group.finish();
}
```

**Running and comparing:**

```bash
cargo bench -- --save-baseline main
git checkout feature-branch
cargo bench -- --baseline main
```

**Output shows statistical significance:**

```text
parse_document   time:   [1.2345 µs 1.2456 µs 1.2567 µs]
                 change: [+2.12% +3.45% +4.78%] (p = 0.00 < 0.05)
                 Performance has regressed.
```

Reference: [Criterion.rs documentation](https://bheisler.github.io/criterion.rs/book/)
