---
title: Replace case/when with Polymorphism
impact: CRITICAL
impactDescription: eliminates shotgun surgery across N branches
tags: cond, polymorphism, case-when, open-closed
---

## Replace case/when with Polymorphism

Every case/when on a type field is a magnet for shotgun surgery: adding a new type requires editing every switch site in the codebase. Polymorphism moves each branch into its own class, so adding a new type means adding a new file, not modifying existing code. This satisfies the Open/Closed Principle and eliminates an entire category of missed-branch bugs.

**Incorrect (case/when on type):**

```ruby
class NotificationService
  def deliver(notification)
    case notification.type
    when :email
      validate_email(notification.recipient)
      EmailClient.send(
        to: notification.recipient,
        subject: notification.subject,
        body: notification.body
      )
    when :sms
      validate_phone(notification.recipient)
      SmsGateway.send(
        phone: notification.recipient,
        message: notification.body
      )
    when :push
      validate_device_token(notification.recipient)
      PushService.send(
        token: notification.recipient,
        title: notification.subject,
        payload: notification.body
      )
    else
      raise ArgumentError, "unknown notification type: #{notification.type}"  # adding a type means editing this method
    end
  end
end
```

**Correct (polymorphic notifier classes with registry):**

```ruby
class BaseNotifier
  def deliver(notification)
    validate(notification.recipient)
    send_message(notification)
  end

  private

  def validate(recipient)
    raise NotImplementedError
  end

  def send_message(notification)
    raise NotImplementedError
  end
end

class EmailNotifier < BaseNotifier
  private

  def validate(recipient)
    validate_email(recipient)
  end

  def send_message(notification)
    EmailClient.send(
      to: notification.recipient,
      subject: notification.subject,
      body: notification.body
    )
  end
end

class SmsNotifier < BaseNotifier
  private

  def validate(recipient) = validate_phone(recipient)

  def send_message(notification)
    SmsGateway.send(phone: notification.recipient, message: notification.body)
  end
end

# PushNotifier follows the same pattern...

class NotificationService
  NOTIFIERS = {
    email: EmailNotifier.new,
    sms: SmsNotifier.new
  }.freeze  # adding a type means adding a class and one registry entry

  def deliver(notification)
    notifier = NOTIFIERS.fetch(notification.type) do
      raise ArgumentError, "unknown notification type: #{notification.type}"
    end
    notifier.deliver(notification)
  end
end
```
