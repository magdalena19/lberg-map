ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'pry'
require 'auto_translation/auto_translate'

def validate_captcha
  fill_in 'captcha', with: SimpleCaptcha::SimpleCaptchaData.first.value
end

def login_as_user
  user = create :user, email: 'user@example.com', password: 'secret', password_confirmation: 'secret'
  visit 'login/'
  fill_in 'sessions_email', with: user.email
  fill_in 'sessions_password', with: 'secret'
  click_on 'Login'
end

def login_as_admin
  admin = create :user, :admin, name: 'Admin', email: 'admin@example.com', password: 'secret', password_confirmation: 'secret'
  visit login_path
  fill_in 'sessions_email', with: admin.email
  fill_in 'sessions_password', with: 'secret'
  click_on 'Login'
end

def spawn_categories
  %w[Playground Hospital Lawyer Cafe Free_wifi].each do |category_name|
    create :category, name_en: category_name
  end
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!


# Stub geocoder response
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    { data: 
      { 'lat' => 52,
        'lon' => 12,
        'address' => {
          'house_number' => '19',
          'street' => 'Magdalenenstraße',
          'postcode' => '10365',
          'district' => 'Lichtenberg',
          'town' => 'Berlin',
          'state' => 'Berlin',
          'country' => 'Germany'
        },
        'type' => 'house',
        'boundingbox' => [52.5, 52.3, 13.0, 12.5],
      }
    }
  ]
)

def stub_autotranslation
  allow_any_instance_of(AutoTranslate).to receive(:receive_translation).and_return('stubbed autotranslation')
end

# CAPYBARA configuration
Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--ignore-ssl-errors=true'])
end

Capybara.configure do |config|
  config.javascript_driver = :poltergeist
  config.current_driver = Capybara.javascript_driver
  # config.run_server = true
  # config.app_host = 'http://localhost:3000/en'
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, no_transaction: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    stub_autotranslation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Capybara::DSL
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
