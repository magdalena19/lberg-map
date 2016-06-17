require_relative '../test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @place = Place.new(name: 'Kiezspinne',
                       street: 'Schulze-Boysen-Straße',
                       house_number: '13',
                       postal_code: '10365',
                       city: 'Berlin',
                       description_en: '<center><b>This is the description.</b></center>',
                       latitude: 13,
                       longitude: 52)
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

  test 'can save place to database' do
    @place.save
    assert Place.find_by(name: 'Kiezspinne')
  end

  test 'html should be sanitized' do
    skip('Passes sometimes, sometimes not...oO')
    @place.save
    assert '<b>This is the description.</b>' == Place.find_by(name: 'Kiezspinne').description_en
  end

  test 'duplicate entries not valid' do
    skip('To be defined: Duplicate entries not valid')
  end
end
