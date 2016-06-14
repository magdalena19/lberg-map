require_relative '../test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @real_place = Place.new(name: 'M19',
                            street: 'Magdalenenstraße',
                            house_number: '19',
                            postal_code: '10365',
                            city: 'Berlin',
                            description_en: 'This is a test')

    @stupid_place = Place.new(name: 'Totally wrong',
                              street: 'Kerze',
                              house_number: '10000',
                              postal_code: '99999',
                              city: 'Deppendorf',
                              description_en: 'This should not be found by nominatim')
  end

  test 'test places are valid' do
    @real_place.geocode
    assert @real_place.valid?
  end

  # test 'real place gets geocoded correctly' do
  #   @real_place.save
  #   assert @real_place.errors.messages.empty?
  #   @real_place.reload
  #   assert_equal 52.514272, @real_place.latitude
  #   assert_equal 13.4885402, @real_place.longitude
  # end

  # test 'totally senseless place raises error and does not get geocoded' do
  #   @stupid_place.save
  #   assert [nil, nil] == [@stupid_place.latitude, @stupid_place.longitude]
  #   assert_equal 'could not be found', @stupid_place.errors.messages[:address].first
  # end
end
