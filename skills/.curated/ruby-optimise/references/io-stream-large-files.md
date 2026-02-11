---
title: Stream Large Files Line by Line
impact: MEDIUM-HIGH
impactDescription: O(1) memory vs O(n) — saves GBs on large files
tags: io, files, streaming, memory
---

## Stream Large Files Line by Line

`File.read` loads the entire file contents into a single string in memory. For a 2 GB CSV, that means 2 GB of RAM consumed before processing begins. `File.foreach` streams one line at a time, keeping memory usage constant regardless of file size.

**Incorrect (loads entire file into memory):**

```ruby
class ProductImporter
  def import(path)
    lines = File.read(path).split("\n")  # entire file loaded into one string, then split into array
    lines.drop(1).each do |line|
      columns = line.split(",")
      Product.create!(
        sku: columns[0],
        name: columns[1],
        price: BigDecimal(columns[2])
      )
    end
  end
end
```

**Correct (streams line by line with constant memory):**

```ruby
class ProductImporter
  def import(path)
    first_line = true

    File.foreach(path, chomp: true) do |line|
      if first_line
        first_line = false
        next
      end

      columns = line.split(",")
      Product.create!(
        sku: columns[0],
        name: columns[1],
        price: BigDecimal(columns[2])
      )
    end
  end
end
```
