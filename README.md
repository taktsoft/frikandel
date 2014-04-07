# Frikandel
[![Gem Version](https://badge.fury.io/rb/frikandel.png)](http://badge.fury.io/rb/frikandel) 
[![Build Status](https://travis-ci.org/taktsoft/extreme_feedback_device.png)](https://travis-ci.org/taktsoft/frikandel)

This Gem adds a TTL (Time To Live) Date to every cookie that your application sets. When the cookie has expired, the users session gets reset. This should help protect from Session-Fixation-Attacks.


## Requirements

Rails 3.2 and 4.x are currently supported.


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

To activate frikandel's Session-Fixation-Protection for your application, you only need to include a module in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include Frikandel::LimitSessionLifetime

  # ...
end
```

## Configuration

To configure frikandel's TTL-values, you can add an initializer in `config/initializers` namend `frikandel.rb` and insert the following lines:

```ruby
Frikandel::Configuration.max_ttl = 2.days
Frikandel::Configuration.ttl = 4.hours
```

The value at `Frikandel::Configuration.max_ttl` is the absolute value in seconds that a cookie is valid. In this example, all cookies will be invalidated after two days in all cases. This timestamp doesn't get refreshed.

The second value `Frikandel::Configuration.ttl` states how long (in seconds) a session/cookie is valid, when the cookie timestamp gets not refreshed. The timestamp gets refrehed everytime a user visits the site.

The default values are `24.hours` for `max_ttl` and `2.hours` for `ttl`. If you are okay with this settings, you don't need to create an initializer for frikandel.


### Customize on_expired_session behavior

You can also overwrite what should happen when a cookie times out on the controller-level. The default behaviour is to do a `reset_session` and `redirect_to root_path`. For example, if you want to overwrite the default behavior when a user is on the `PublicController`, you want to overwrite the `on_expired_session`-method in your controller:

```ruby
class PublicController < ApplicationController
  def on_expired_session
    raise "Your Session Has Expired! Oh No!"
  end
end
```

If you want to revert the original behavior in a sub-class of your `PublicController`, you simply re-alias the method to `original_on_expired_session` like this:

```ruby
class AdminController < PublicController
  alias on_expired_session original_on_expired_session
end
```

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
