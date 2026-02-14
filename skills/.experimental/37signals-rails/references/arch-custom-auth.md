---
title: Custom Passwordless Auth Over Devise
impact: HIGH
impactDescription: eliminates Devise dependency — ~150 lines replaces 5,000+ lines of gem code
tags: arch, authentication, passwordless, session
---

## Custom Passwordless Auth Over Devise

37signals uses custom passwordless email-link authentication across all their apps. No Devise, no Doorkeeper, no OAuth gems. The implementation is ~150 lines: a `SignInLink` model that generates a 6-digit code with 15-minute expiration, a `Session` model that tracks user_agent and IP, and bearer token support for API access. This gives full control over the auth flow and eliminates one of the heaviest dependencies in the Rails ecosystem.

**Incorrect (Devise with extensive configuration):**

```ruby
# Gemfile
gem "devise"
gem "devise-two-factor"
gem "omniauth"

# app/models/user.rb — Devise modules add hidden complexity
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
end

# config/initializers/devise.rb — 300+ lines of configuration
Devise.setup do |config|
  config.mailer_sender = "noreply@example.com"
  config.password_length = 8..128
  config.reset_password_within = 6.hours
end
```

**Correct (custom passwordless auth — models):**

```ruby
# app/models/identity.rb — global user, email-based
class Identity < ApplicationRecord
  has_many :users  # one per account (multi-tenant)
  has_many :sessions, dependent: :destroy
  normalizes :email, with: -> { _1.strip.downcase }
end

# app/models/sign_in_link.rb — passwordless auth token
class SignInLink < ApplicationRecord
  belongs_to :identity
  generates_token_for :authentication, expires_in: 15.minutes
  before_create { self.code = SecureRandom.random_number(10**6).to_s.rjust(6, "0") }

  def consume!
    raise "Expired" if created_at < 15.minutes.ago
    raise "Already used" if consumed_at.present?
    update!(consumed_at: Time.current)
    identity
  end
end

# app/models/session.rb — tracks active sessions
class Session < ApplicationRecord
  belongs_to :identity
  belongs_to :user
end
```

**Correct (custom passwordless auth — controllers):**

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    identity = Identity.find_by!(email: params[:email])
    link = identity.sign_in_links.create!
    AuthMailer.sign_in_link(identity, link).deliver_later
    redirect_to verify_path
  end

  def verify
    link = SignInLink.find_by!(code: params[:code])
    identity = link.consume!
    session = identity.sessions.create!(user: identity.users.find_by(account: Current.account))
    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    redirect_to root_path
  end

  def destroy
    Current.session&.destroy
    cookies.delete(:session_id)
    redirect_to root_path
  end
end

# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern
  included do
    before_action :resume_session
    helper_method :signed_in?
  end
  private
  def resume_session
    Current.session = Session.find_by(id: cookies.signed[:session_id])
    Current.identity = Current.session&.identity
    Current.user = Current.session&.user
  end
  def signed_in? = Current.session.present?
end
```

**When NOT to use:**
- If you need OAuth provider integration (Sign in with Google/GitHub), consider `omniauth` as a standalone gem without Devise. The session management can still be custom.

Reference: [Basecamp Fizzy AGENTS.md](https://github.com/basecamp/fizzy/blob/main/AGENTS.md)
