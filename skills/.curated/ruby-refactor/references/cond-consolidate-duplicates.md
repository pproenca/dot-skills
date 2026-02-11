---
title: Consolidate Duplicate Conditional Fragments
impact: HIGH
impactDescription: reduces duplication by 30-50%
tags: cond, consolidate, duplication, dry
---

## Consolidate Duplicate Conditional Fragments

When every branch of a conditional repeats the same setup or teardown code, the duplication obscures what actually differs between the branches. Changes to the shared logic must be applied to every branch, and missing one creates subtle inconsistencies. Extracting common fragments before and after the conditional makes the unique behavior in each branch visually obvious and reduces the total line count.

**Incorrect (duplicated setup and teardown in each branch):**

```ruby
class ReportExporter
  def export(records, format:)
    if format == :csv
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      filename = "report_#{timestamp}"
      log_export_started(filename, format)

      content = generate_csv_content(records)

      write_to_storage(filename, content, extension: "csv")
      log_export_completed(filename, format)  # duplicated in both branches
      notify_requester(filename)               # duplicated in both branches
    else
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      filename = "report_#{timestamp}"
      log_export_started(filename, format)

      content = generate_json_content(records)

      write_to_storage(filename, content, extension: "json")
      log_export_completed(filename, format)  # same as above
      notify_requester(filename)               # same as above
    end
  end
end
```

**Correct (shared code extracted, only the difference remains in the conditional):**

```ruby
class ReportExporter
  def export(records, format:)
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    filename = "report_#{timestamp}"
    log_export_started(filename, format)

    content, extension = case format  # only the format-specific logic varies
    when :csv  then [generate_csv_content(records), "csv"]
    when :json then [generate_json_content(records), "json"]
    else raise ArgumentError, "unsupported format: #{format}"
    end

    write_to_storage(filename, content, extension: extension)
    log_export_completed(filename, format)
    notify_requester(filename)
  end
end
```
