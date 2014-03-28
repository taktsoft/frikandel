# Frikandel

This Gem adds a TTL (Time To Live) Date to every cookie that your application sets. When the cookie has expired, the users session gets reset. This should help protect from Session-Fixation-Attacks.

## Requirements

Rails 3 or 4 is currently supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'frikandel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frikandel

## Usage

Add an initializer namend `frikandel.rb` and insert the following lines:

```ruby
Frikandel::Configuration.max_ttl = 1.day
Frikandel::Configuration.ttl = 2.hours
```

The value at `Frikandel::Configuration.max_ttl` is the absolute value that a cookie is valid. In this example, all cookies will be invalidated after one day.

The second value `Frikandel::Configuration.ttl` states how long a session/cookie is valid, when the cookie timestamp gets not refreshed. The timestamp gets refrehed everytime a user visits the site.

#### Customize on_expired behavior
You can also overwrite what should happen when a cookie times out on the controller-level.
For example, if you want to overwrite the default behavior (= reset the session) when a user is on the `PublicController`, you want to overwrite the `on_expired_cookie`-method in your Controller:

```ruby
class PublicController < ApplicationController
  def on_expired_cookie
    raise "Your Cookie Has Expired! Oh No!"
  end
end
```

If you want to revert the original behavior in a child of your `PublicController`, you simply re-alias the method to `original_on_expired_cookie` like this:

```ruby
class AdminController < PublicController
  alias on_expired_cookie original_on_expired_cookie
end
```
