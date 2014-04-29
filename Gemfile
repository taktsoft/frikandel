source 'https://rubygems.org'

# Specify your gem's dependencies in frikandel.gemspec
gemspec

# Thanks to http://www.schneems.com/post/50991826838/testing-against-multiple-rails-versions/
rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  [">= 3.2.0", "<= 4.1"]
else
  "~> #{rails_version}"
end

gem "rails", rails
