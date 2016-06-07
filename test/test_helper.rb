ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/reporters'
require 'minitest/rails/capybara'

reporter_options = { color: true }
Minitest::Reporters.use!(
  Minitest::Reporters::DefaultReporter.new(reporter_options),
  ENV,
  Minitest.backtrace_filter
  )

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  Geocoder.configure(:lookup => :test)
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        'latitude' => 52,
        'longitude' => 12,
        'address' => {
          'road' => 'Magdalenenstr.',
          'house_number' => '19',
          'postcode' => '10365',
          'town' => 'Berlin',
        },
        'type' => 'house',
      }
    ]
  )
  # Add more helper methods to be used by all tests here...
end
