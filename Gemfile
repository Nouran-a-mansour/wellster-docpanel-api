source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "4.0.3"

gem "rails", "~> 8.1.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rack-cors"
gem "bootsnap", require: false
group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end