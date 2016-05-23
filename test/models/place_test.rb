require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @place = Place.new( latitude: 12.0,
                        longitude: 52.0,
                        name: 'Kiezspinne',
                        street: 'Schulze-Boysen-Straße',
                        house_number: '13',
                        postal_code: '10365',
                        city: 'Berlin',
                        description_en: '<center><b>This is the description.</b></center>',
                      )
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
    @place.description_en = '<center><b>This is the description.</b></center>'
    @place.save
    saved_description = Place.find_by(name: 'Kiezspinne').description_en
    assert_equal(saved_description, '<b>This is the description.</b>')
  end

  test 'duplicate entries not valid' do
     # TODO: Check whether entry is already in DB
  end
end
