source 'https://rubygems.org'

gem 'rack-protection', :git => 'https://github.com/rkh/rack-protection'
gem 'sinatra', '=1.4.0'
gem 'sinatra-contrib',
  :git => 'https://github.com/sinatra/sinatra-contrib',
  :require => [
    'sinatra/content_for',
    'sinatra/namespace',
    'sinatra/config_file',
    'sinatra/respond_with'
  ]
gem 'sinatra-flash', :require => 'sinatra/flash'
gem 'activesupport', '>= 4.0.0', :require => [
  'active_support',
  'active_support/time',
  'active_support/core_ext/hash'
]
gem 'mysql'
gem 'json'
gem "dm-core", ">=1.2.0"
gem "dm-serializer", ">=1.2.0"
gem "dm-migrations", ">=1.2.0", :require => [
  'dm-migrations',
  'dm-migrations/migration_runner'
]
gem "dm-validations", ">=1.2.0"
gem "dm-constraints", ">=1.2.0"
gem "dm-types", ">=1.2.0"
gem "dm-mysql-adapter", ">=1.2.0"
gem 'multi_json'
gem 'addressable'
gem 'uuid'
gem 'rabl'
gem 'yajl-ruby'
gem 'gravatarify', ">= 3.1.0"
gem "pony"
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'pagehub-markdown', '>=0.1.3', :require => 'pagehub-markdown'
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
gem 'sinatra-api', '>=1.1.7'
gem 'rake'

group :development do
  gem 'thin'
end

group :test do
  gem 'rspec'
  gem 'rspec-core'
  # gem 'capybara-webkit', '>= 0.13.0', :git => 'https://github.com/thoughtbot/capybara-webkit'
  gem 'capybara-webkit'
  gem 'capybara', '>= 2.0.2'
  gem 'launchy'
end

group :production do
end

gem 'chartkick'
