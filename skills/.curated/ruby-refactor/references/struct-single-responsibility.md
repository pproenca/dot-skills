---
title: One Reason to Change per Class
impact: HIGH
impactDescription: reduces change cascade across codebase
tags: struct, srp, cohesion, coupling
---

## One Reason to Change per Class

When a class has two responsibilities, a change to one can break the other. If you describe a class using "and" -- "this class formats reports *and* sends them" -- it has too many reasons to change. Split it so each class changes for exactly one reason.

**Incorrect (Report class formats AND sends):**

```ruby
class Report
  def initialize(data)
    @data = data
  end

  def generate
    rows = @data.map do |record|
      "#{record[:name].ljust(20)} #{format('$%<amount>.2f', amount: record[:amount])}"
    end

    header = "Sales Report - #{Date.today}"
    separator = "-" * 40
    body = [header, separator, *rows, separator, total_line].join("\n")
    body
  end

  def send_via_email(recipient)
    body = generate
    # Report should not know about email transport
    smtp = Net::SMTP.start("mail.example.com", 587, "example.com", "user", "pass", :login)
    message = <<~EMAIL
      From: reports@example.com
      To: #{recipient}
      Subject: Daily Sales Report

      #{body}
    EMAIL
    smtp.send_message(message, "reports@example.com", recipient)
    smtp.finish
  end

  private

  def total_line
    total = @data.sum { |record| record[:amount] }
    "Total:#{' ' * 14}#{format('$%.2f', total)}"
  end
end
```

**Correct (split into ReportFormatter and ReportSender):**

```ruby
class ReportFormatter
  def initialize(data)
    @data = data
  end

  def generate
    rows = @data.map do |record|
      "#{record[:name].ljust(20)} #{format('$%<amount>.2f', amount: record[:amount])}"
    end

    header = "Sales Report - #{Date.today}"
    separator = "-" * 40
    [header, separator, *rows, separator, total_line].join("\n")
  end

  private

  def total_line
    total = @data.sum { |record| record[:amount] }
    "Total:#{' ' * 14}#{format('$%.2f', total)}"
  end
end

class ReportSender
  def initialize(smtp_config)
    @smtp_config = smtp_config
  end

  def send_via_email(body, recipient)
    smtp = Net::SMTP.start(*@smtp_config.values_at(:host, :port, :domain, :user, :password, :auth))
    message = <<~EMAIL
      From: reports@example.com
      To: #{recipient}
      Subject: Daily Sales Report

      #{body}
    EMAIL
    smtp.send_message(message, "reports@example.com", recipient)
    smtp.finish
  end
end

# Usage: each class changes for exactly one reason
formatter = ReportFormatter.new(data)
sender = ReportSender.new(smtp_config)
sender.send_via_email(formatter.generate, "manager@example.com")
```

**Smell test:** If you describe the class with "and," split it.
