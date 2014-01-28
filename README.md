# Cookiettl

This Gem adds a TTL (Time To Live) Date into every cookie that your application sets. When the cookie has expired, the users Session gets reset. This should help protect from Session Fixation.

## Requirements

This Gem relies on the (common) User-Signin and -out Mechanisms. To properly work,, it need the function `current_user` and `current_user?`.

Please see the file lib/cookiettl.rb how that plays together.

## Installation

Add this line to your application's Gemfile:

    gem 'cookiettl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cookiettl

## Usage

Add the following lines to your `application.rb`:

    Cookiettl::Filter::SESSION_MAX_TTL = 1.day
    Cookiettl::Filter::SESSION_TTL = 2.hours

The value at `SESSION_MAX_TTL` is the absolute value that a cookie is valid. In this example, all cookies will be invalidated after one day.

The second value `SESSION_TTL` states how long a session/cookie is valid, when the cookie timestamp gets not refreshed. Refreshing means, that a User with their cookie visits the site and the site updates the ttl inside the cookie.



## Contributing

1. Fork it ( http://github.com/jk779/cookiettl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
