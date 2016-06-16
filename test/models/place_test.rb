require_relative '../test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @valid_translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    @place = Place.new(name: 'Kiezspinne',
                       street: 'Schulze-Boysen-Straße',
                       house_number: '13',
                       postal_code: '10365',
                       city: 'Berlin',
                       description: '<center><b>This is the description.</b></center>')
  end

  test 'valid place is valid' do
    assert @place.valid?
  end

  test 'empty Place object should not be valid' do
    assert_not Place.new.valid?
  end

  test 'name should not be blank' do
    @place.name = ''
    assert_not @place.valid?
  end

  test 'html should be sanitized' do
    @place.save
    saved_description = Place.find_by(name: 'Kiezspinne').description_en
    assert_equal '<b>This is the description.</b>', saved_description
  end

  # TODO: Check whether entry is already in DB
  test 'duplicate entries not valid' do
  end
end
