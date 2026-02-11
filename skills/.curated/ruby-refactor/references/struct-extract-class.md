---
title: Extract Class for Single Responsibility
impact: CRITICAL
impactDescription: reduces class coupling by 50-80%
tags: struct, extract-class, srp, sandi-metz
---

## Extract Class for Single Responsibility

When a class accumulates methods that operate on a subset of its data, it has absorbed a second responsibility. Extracting a value object gives that concept a name, a home for validation, and the ability to be reused independently. Sandi Metz's rule: classes should be 100 lines or fewer.

**Incorrect (User class absorbing email logic):**

```ruby
class User
  attr_accessor :name, :email, :role

  def validate_email
    return false if email.nil? || email.strip.empty?

    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def email_domain
    email.split("@").last.downcase
  end

  def send_welcome_email
    return unless validate_email

    Mailer.deliver(
      to: email,
      subject: "Welcome, #{name}!",
      body: "Your account on #{email_domain} is ready."
    )
  end

  def corporate_email?
    !%w[gmail.com yahoo.com hotmail.com].include?(email_domain)
  end
end
```

**Correct (extracted EmailAddress value object):**

```ruby
class User
  attr_accessor :name, :role
  attr_reader :email

  def initialize(name:, email:, role:)
    @name = name
    @email = EmailAddress.new(email) # value object owns all email logic
    @role = role
  end

  def send_welcome_email
    return unless email.valid?

    Mailer.deliver(
      to: email.to_s,
      subject: "Welcome, #{name}!",
      body: "Your account on #{email.domain} is ready."
    )
  end
end

class EmailAddress
  CORPORATE_FREEMAIL = %w[gmail.com yahoo.com hotmail.com].freeze
  FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def initialize(address)
    @address = address.to_s.strip
  end

  def valid?
    @address.match?(FORMAT)
  end

  def domain
    @address.split("@").last.downcase
  end

  def corporate?
    !CORPORATE_FREEMAIL.include?(domain)
  end

  def to_s
    @address
  end
end
```

Reference: Sandi Metz, *Practical Object-Oriented Design* -- classes should be 100 lines or fewer.
