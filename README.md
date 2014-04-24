# Frikandel
[![Gem Version](https://badge.fury.io/rb/frikandel.png)](http://badge.fury.io/rb/frikandel) 
[![Build Status](https://api.travis-ci.org/taktsoft/frikandel.png)](https://travis-ci.org/taktsoft/frikandel)

This gem aims to improve the security of your rails application. It allows you to add a TTL (Time To Live) to the session cookie and allows you to bind the session to an IP address.

When the TTL expires or the IP address changes, the users session gets reset. This should help to make [session-fixation-attacks](http://guides.rubyonrails.org/security.html#session-fixation) harder to execute.


## Security considerations

Consider the following attack vector: The web application under attack is a rails application. The application writes the user id in the session after a successful login. The attacker has obtained a valid session cookie from an authenticated user.
By default the cookie is valid indefinitely. If the application tries to "reset the session" it simply issues a new session cookie to the attackers browser. If the attacker just ignores the new session cookie and continues to use the old session cookie the application has no way of knowing that.

By adding a TTL the attack window gets smaller. An stolen has to be used within a given time slot. A reauthentication is enforced after a given time has passed. By adding IP address binding the attacker has to use the same ip address as the victim the session was stolen from.

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

You can use session TTL or the combination of TTL and IP address binding. Please be advised that the sole use of IP address binding doesn't protect from session-fixation-attacks.


To activate Frikandel's session-fixation-protection for your application, you only need to include the proper module(s) in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include Frikandel::LimitSessionLifetime
  include Frikandel::BindSessionToIpAddress

  # ...
end
```

## Configuration

To configure frikandel's TTL-values, you can add an initializer in `config/initializers` namend `frikandel.rb` and insert the following lines:

```ruby
Frikandel::Configuration.max_ttl = 2.days
Frikandel::Configuration.ttl = 4.hours
```

The value at `Frikandel::Configuration.max_ttl` is the absolute value (in seconds) that a cookie is valid. In this example, all cookies will be invalidated after two days in all cases. This timestamp doesn't get refreshed. In a typical application that means the user has to re-login after this time. That's also the maximum time frame a stolen session can be used.

The second value `Frikandel::Configuration.ttl` states how long (in seconds) a session/cookie is valid, when the cookie timestamp gets not refreshed. The timestamp gets refrehed everytime a user visits the site.

The default values are `24.hours` for `max_ttl` and `2.hours` for `ttl`. If you are okay with this settings, you don't need to create an initializer for frikandel.


### Customize on_invalid_session behavior

You can also overwrite what should happen when a cookie times out on the controller-level. The default behaviour is to do a `reset_session` and `redirect_to root_path`. For example, if you want to overwrite the default behavior when a user is on the `PublicController`, you want to overwrite the `on_expired_session`-method in your controller:

```ruby
class PublicController < ApplicationController
  def on_invalid_session
    raise "Your Session Has Expired! Oh No!"
  end
end
```

If you want to revert the original behavior in a sub-class of your `PublicController`, you simply re-alias the method to `original_on_invalid_session` like this:

```ruby
class AdminController < PublicController
  alias on_invalid_session original_on_invalid_session
end
```

## Changes

2.0.0 Added IP address binding. Renamed callback from 'on_expired_session' to 'on_invalid_session'.

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
