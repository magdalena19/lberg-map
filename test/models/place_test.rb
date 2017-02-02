
require_relative '../test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @place = build :place, :unreviewed, name: 'Kiezspinne', description_en:  '<b>This is the description.</b>'
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

  test 'Invalid place contact data shall be invalid' do
    assert_not @place.update_attributes(phone: '03')
    assert_not @place.update_attributes(phone: '03' * 12)
    assert_equal ['is incorrectly formatted!'], @place.errors.messages[:phone]

    assert_not @place.update_attributes(email: 'foo@bar')
    assert_not @place.update_attributes(email: 'foo@.bar')
    assert_not @place.update_attributes(email: 'bar@')
    assert_equal ['is incorrectly formatted!'], @place.errors.messages[:email]

    assert_not @place.update_attributes(homepage: 'http:/heise.de')
    assert_not @place.update_attributes(homepage: 'http://heise')
    assert_not @place.update_attributes(homepage: 'http//heise')
    assert_equal ['is incorrectly formatted!'], @place.errors.messages[:homepage]
  end

  test "Assure correctly securing URLs" do
    @place.homepage = 'http://www.heise.de'
    @place.save

    assert_equal 'https://heise.de', @place.homepage
  end

  test 'Valid place contact data shall be valid' do
    assert @place.update_attributes(phone: '0304858')
    assert @place.update_attributes(email: 'foo@batz.bar')
    assert @place.update_attributes(homepage: 'http://foo.bar')
    assert @place.update_attributes(homepage: 'www.foo.bar')
    assert @place.update_attributes(homepage: 'foo.bar')
  end

  test 'html should be sanitized' do
    @place.save
    assert_equal '<b>This is the description.</b>', Place.find_by(name: 'Kiezspinne').description_en
  end

  test 'duplicate entries not valid' do
    skip('To be defined: Duplicate entries not valid')
  end

  test "Place with lat/lon does not need to be geocoded" do
    @place = create :place, :unreviewed, latitude: 60.0, longitude: 10.0
    assert_equal 60.0, @place.latitude
    assert_equal 10.0, @place.longitude

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
  
  test 'Assure place homepage links use https' do
    @place.homepage = 'www.test.com'
    @place.save

    assert_equal 'https://test.com', @place.reload.homepage

    @place.homepage = 'test.com'
    @place.save

    assert_equal 'https://test.com', @place.reload.homepage

    @place.homepage = 'http://test.com'
    @place.save

    assert_equal 'https://test.com', @place.reload.homepage
  end
end
