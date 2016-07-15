require 'test_helper'

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
    @place.save
    assert '<b>This is the description.</b>' == Place.find_by(name: 'Kiezspinne').description_en
  end

  test 'duplicate entries not valid' do
    skip('To be defined: Duplicate entries not valid')
  end

  # Review

  test 'Version is 1 for new points' do
    @place.save
    assert_equal 1, Place.find_by_name('Kiezspinne').versions.length
  end

  test 'Updating a point increases number of versions' do
    @place.save
    assert_difference '@place.versions.length' do
      @place.update(name: 'SomeOtherPlace')
    end
  end

  test 'Updating translation record does not increase associated place versions' do
    @place.save
    assert_difference '@place.versions.length', 0 do
      @place.translation.update_attributes(description: 'This is some edit')
    end
  end

  test 'return nil for \'reviewed_version\' if no reviewed version' do
    @place.save
    assert_not @place.reviewed_version
  end

  test 'return unreviewed version if \'reviewed\' = false, but no versions' do
    @place.save
    assert @place.unreviewed_version
  end
end
