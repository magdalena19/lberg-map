require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
    def setup
        @place = Place.new(latitude: 12.0, longitude: 52.0, name: 'Kiezspinne', categories: 'Treffpunkt')
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

    test "categories should not be blank" do
        @place.categories = ""
        assert_not @place.valid?
    end

    test "places with long/lat within valid range are valid" do
      [[0,0], [90,-180], [-90,-180], [-90,180], [90,180]].each do |long, lat|
        @place.longitude = long
        @place.latitude = lat
        assert @place.valid?
      end
    end

    test "places with long/lat outside valid range are invalid" do
      # test multiple valid long/lat pairs
      [[-90.5, 0], [90.5, 0], [0, 180.5], [0, -180.5], [-90.5, 180.5], [90.5, -180.5]].each do |long, lat|
        @place.longitude = long
        @place.latitude = lat
        assert_not @place.valid?
      end
    end

    test "duplicate entries not valid" do
        # TODO: Check whether entry is already in DB
    end

end
