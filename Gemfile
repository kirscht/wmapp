source "http://rubygems.org"

gem "rails", "~> 5.1.0"
gem "bcrypt-ruby", require: "bcrypt"
gem "actionpack-page_caching"
gem "active_model_serializers", "~> 0.9.0"
gem "responders"

gem "pg", '0.20'

gem "redis"
gem "hiredis"
gem "redis-rails"

gem "json"
gem "sass-rails", "~> 5.0"
gem "coffee-rails"
gem "uglifier"
gem "dynamic_form"
gem "jquery-rails"
gem "backbone-on-rails"
gem "sprockets-es6"

gem "gemoji"
gem "b3s_emoticons", git: "https://github.com/b3s/b3s_emoticons.git"

# gem 'dynamic_image', '~> 2.0.0.beta5
gem "fog-aws"
gem "dynamic_image"
gem "sentry-raven"

# To use debugger
# gem 'ruby-debug'

# OAuth
gem "doorkeeper" # , '~> 0.7.2'

gem "acts_as_list"

gem "nokogiri"
gem "daemon-spawn"
gem "httparty", "~> 0.13.5"

gem "progress_bar"

gem "newrelic_rpm", group: "newrelic"

gem "fastimage"
gem "ruby-filemagic", require: "filemagic"
gem "redcarpet", "~> 3.5"
gem "rouge"
gem "font-awesome-rails", "~> 4.7"

# TODO: Remove this when the redesign is done
gem "non-stupid-digest-assets"
gem "activemodel-serializers-xml"

group :development do
  gem "yui-compressor", require: "yui/compressor"
  gem "web-console"
end

group :development_mac do
  gem "rb-fsevent"
  gem "ruby_gntp"
end

group :test do
  gem "codeclimate-test-reporter", require: false
  gem "rails-controller-testing"

  # RSpec
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "json_spec"
  gem "capybara"
  gem "fuubar"
  gem "database_cleaner"
  gem "webmock", require: false
end

group :test, :development do
  gem "puma"
  gem "dotenv-rails", "~> 0.10.0"

  gem "pry"

  # FactoryGirl
  gem "factory_girl_rails"
end
