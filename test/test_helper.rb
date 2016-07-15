ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/reporters'
require 'minitest/rails/capybara'
require 'capybara/poltergeist'

reporter_options = { color: true }
Minitest::Reporters.use!(
  # Minitest::Reporters::DefaultReporter.new(reporter_options),
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
end

Geocoder.configure(lookup: :test)
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
      'boundingbox' => [52.5, 52.3, 13.0, 12.5],
    }
  ]
)

# While testing with Javascript flag, test runs in another thread,
# thus created fixtures are not available without the following setup
class Capybara::Rails::TestCase
  self.use_transactional_fixtures = false

  before do
    if metadata[:js]
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = Capybara.javascript_driver
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start
    end
  end

  after do
    if metadata[:js]
      DatabaseCleaner.clean
    end

    Capybara.reset_sessions!
    Capybara.current_driver = Capybara.default_driver
  end
end
