---
title: Build It Yourself Before Reaching for Gems
impact: CRITICAL
impactDescription: eliminates black-box dependencies, gives full control over behavior
tags: arch, gems, dependencies, diy
---

## Build It Yourself Before Reaching for Gems

Implement features with vanilla Rails first. Only extract to gems after patterns prove themselves across multiple projects. 37signals avoids Devise (custom passwordless auth), RSpec (Minitest), FactoryBot (fixtures), and Redis (Solid Queue/Cable/Cache). A custom implementation you understand completely beats a black-box gem you have to debug blindly.

**Incorrect (Devise for simple authentication):**

```ruby
# Gemfile — pulls in Warden, OmniAuth, bcrypt wrappers, 14 modules
gem "devise"

# app/models/user.rb — opaque module soup
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable
end

# 20+ routes you didn't ask for
# Migration with 30+ columns you may never use
# Debugging requires reading Devise + Warden internals
```

**Correct (custom session-based auth you fully control):**

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email, with: -> { _1.strip.downcase }

  # Rails 7.1 built-in token generation
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end
end

# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user
  before_create { self.token = SecureRandom.urlsafe_base64(32) }
end

# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    user = User.authenticate_by(
      email: params[:email],
      password: params[:password]
    )

    if user
      session = user.sessions.create!
      cookies.signed.permanent[:session_token] = session.token
      redirect_to root_path
    else
      redirect_to new_session_path, alert: "Invalid email or password"
    end
  end

  def destroy
    Current.session&.destroy
    cookies.delete(:session_token)
    redirect_to new_session_path
  end
end
```

**Benefits:**
- Zero hidden behavior — every auth decision is explicit in your code
- No gem upgrade surprises or CVE patches for code paths you don't use
- Adapts instantly to your domain (passwordless, one-time links, API tokens)
- Team learns Rails fundamentals instead of gem-specific DSLs

Reference: [Basecamp/Fizzy](https://github.com/basecamp/fizzy)
