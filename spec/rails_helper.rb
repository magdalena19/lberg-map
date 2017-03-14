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

def create_place_as_user(place_name)
  login_as_user
  visit new_place_path
  fill_in_valid_place_information
  fill_in('place_name', with: place_name)
  click_on('Create Place')
end

def create_place_as_guest(place_name)
  visit new_place_path
  fill_in_valid_place_information
  fill_in('place_name', with: place_name)
  validate_captcha
  click_on('Create Place')
end

def fill_in_valid_place_information
  fill_in('place_name', with: 'Any place')
  fill_in('place_street', with: 'Magdalenenstr.')
  fill_in('place_house_number', with: '19')
  fill_in('place_postal_code', with: '10963')
  fill_in('place_city', with: 'Berlin')
  fill_in('place_email', with: 'schnipp@schnapp.com')
  fill_in('place_homepage', with: 'http://schnapp.com')
  fill_in('place_phone', with: '03081763253')
  fill_in('place_categories', with: 'Hospital, Cafe')
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
  allow_any_instance_of(AutoTranslate).to receive(:translate).and_return('stubbed autotranslation')
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
