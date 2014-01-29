# Cookiettl

This Gem adds a TTL (Time To Live) Date into every cookie that your application sets. When the cookie has expired, the users session gets reset. This should help protect from Session Fixation.

## Requirements

Rails 3 or 4 is currently supported.

## Installation

Add this line to your application's Gemfile:

    gem 'cookiettl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cookiettl

## Usage

Add an initializer namend `cookiettl.rb` and insert the following lines:

```ruby
Cookiettl::Configuration.max_ttl = 1.day
Cookiettl::Configuration.ttl = 2.hours
```

The value at `Cookiettl::Configuration.max_ttl` is the absolute value that a cookie is valid. In this example, all cookies will be invalidated after one day.

The second value `Cookiettl::Configuration.ttl` states how long a session/cookie is valid, when the cookie timestamp gets not refreshed. The timestamp gets refrehed everytime a user visits the site.

### Customize on_expired behavior
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

## Contributing

1. Fork it ( http://github.com/jk779/cookiettl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
