---
title: Compose Methods at Single Abstraction Level
impact: CRITICAL
impactDescription: makes method readable in one pass
tags: struct, compose-method, abstraction-level, readability
---

## Compose Methods at Single Abstraction Level

When a method mixes high-level intent with low-level implementation details, readers must constantly shift between "what" and "how." Composing the method so every line operates at the same abstraction level makes it readable in a single pass, like a table of contents.

**Incorrect (mixed abstraction levels in registration):**

```ruby
class RegistrationService
  def register(params)
    # High-level: validate -- but implemented inline at low level
    raise ArgumentError, "Email is required" if params[:email].nil?
    raise ArgumentError, "Invalid email format" unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    raise ArgumentError, "Password too short" if params[:password].length < 8
    raise ArgumentError, "Name is required" if params[:name].to_s.strip.empty?

    # Low-level: hash the password directly in flow
    salt = SecureRandom.hex(16)
    hashed_password = OpenSSL::Digest::SHA256.hexdigest("#{salt}:#{params[:password]}")

    user = User.create!(
      name: params[:name].strip,
      email: params[:email].downcase,
      password_digest: "#{salt}$#{hashed_password}",
      confirmed: false
    )

    # Low-level email construction mixed in
    token = SecureRandom.urlsafe_base64(32)
    user.update!(confirmation_token: token)
    Mailer.deliver(
      to: user.email,
      subject: "Confirm your account",
      body: "Click here: https://app.example.com/confirm?token=#{token}"
    )

    user
  end
end
```

**Correct (all calls at the same abstraction level):**

```ruby
class RegistrationService
  def register(params)
    validate(params)
    user = create_user(params)
    send_confirmation(user) # each step reads like a sentence
    user
  end

  private

  def validate(params)
    raise ArgumentError, "Email is required" if params[:email].nil?
    raise ArgumentError, "Invalid email format" unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    raise ArgumentError, "Password too short" if params[:password].length < 8
    raise ArgumentError, "Name is required" if params[:name].to_s.strip.empty?
  end

  def create_user(params)
    User.create!(
      name: params[:name].strip,
      email: params[:email].downcase,
      password_digest: hash_password(params[:password]),
      confirmed: false
    )
  end

  def hash_password(password)
    salt = SecureRandom.hex(16)
    digest = OpenSSL::Digest::SHA256.hexdigest("#{salt}:#{password}")
    "#{salt}$#{digest}"
  end

  def send_confirmation(user)
    token = SecureRandom.urlsafe_base64(32)
    user.update!(confirmation_token: token)
    Mailer.deliver(
      to: user.email,
      subject: "Confirm your account",
      body: "Click here: https://app.example.com/confirm?token=#{token}"
    )
  end
end
```

Reference: [Compose Method](https://wiki.c2.com/?ComposeMethod) -- every line in a method should be at the same level of abstraction.
