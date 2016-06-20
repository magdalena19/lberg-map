require_relative '../test_helper'
require 'mass_seed_points'

class MassSeedPointsTest < ActiveSupport::TestCase
  def setup
  end

  test 'can generate 1 point in Berlin Lichtenberg' do
    assert 'Place.count', 1 do
      MassSeedPoints.generate(number_of_points: 1, city: 'Berlin, Lichtenberg')
    end
  end

  test '0 as points parameter creates no' do
    assert 'Place.count', 0 do
      MassSeedPoints.generate(number_of_points: 0, city: 'Berlin, Lichtenberg')
    end
  end

  test 'No Region returns error message' do
    a = MassSeedPoints.generate(number_of_points: 0, city: '')
    assert_equal 'No boundingbox found in which to insert points! Have you supplied a geolocation (city, district, ...)?', a
  end
end
