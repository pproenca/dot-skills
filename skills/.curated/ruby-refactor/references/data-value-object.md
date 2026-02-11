---
title: Replace Primitive Obsession with Value Objects
impact: MEDIUM-HIGH
impactDescription: reduces scattered validation from N call sites to 1 constructor
tags: data, value-object, primitive-obsession, domain
---

## Replace Primitive Obsession with Value Objects

Passing raw strings or numbers to represent domain concepts scatters validation and formatting logic across every call site. When the same primitive is validated in three places, a fourth will inevitably be missed. A value object gives the concept a name, validates once at construction, and provides a natural home for derived behavior.

**Incorrect (raw string with validation scattered across call sites):**

```ruby
class UserRegistration
  def register(email, name)
    # Validation duplicated wherever email is used
    raise ArgumentError, "invalid email" unless email.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)

    user = User.create!(email: email, name: name)
    Mailer.send_welcome(user.email)
    Analytics.track_signup(email.split("@").last) # domain extraction repeated elsewhere
    user
  end
end

class PasswordReset
  def request_reset(email)
    raise ArgumentError, "invalid email" unless email.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)

    token = SecureRandom.hex(20)
    ResetToken.create!(email: email, token: token)
    Mailer.send_reset(email)
  end
end
```

**Correct (value object centralizes validation and behavior):**

```ruby
class EmailAddress
  PATTERN = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_reader :address

  def initialize(address)
    raise ArgumentError, "invalid email" unless address.match?(PATTERN)

    @address = address.downcase.freeze
  end

  # Domain behavior lives with the data that owns it
  def domain = address.split("@").last
  def to_s = address
  def ==(other) = other.is_a?(self.class) && address == other.address
  def hash = address.hash
end

class UserRegistration
  def register(email, name)
    email = EmailAddress.new(email)

    user = User.create!(email: email.to_s, name: name)
    Mailer.send_welcome(email.to_s)
    Analytics.track_signup(email.domain)
    user
  end
end

class PasswordReset
  def request_reset(email)
    email = EmailAddress.new(email) # validates once — no duplication

    token = SecureRandom.hex(20)
    ResetToken.create!(email: email.to_s, token: token)
    Mailer.send_reset(email.to_s)
  end
end
```
