require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  def setup
    @place = places :Magda19
  end

  # CRUD and REST tests
  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create valid new place' do
    valid_new_place = Place.new(name: 'Kiezspinne',
     street: 'Schulze-Boysen-Straße',
     house_number: '15',
     postal_code: '10365',
     city: 'Berlin',
     categories: 'Lalalala')
    valid_new_place.latitude = Geocoder.search(valid_new_place.address).first.latitude
    valid_new_place.longitude = Geocoder.search(valid_new_place.address).first.longitude

    assert_difference 'Place.count' do
      post :create, place: valid_new_place.attributes.to_options
    end
    assert_redirected_to places_path
  end

  test 'should not create invalid new place' do
    assert_no_difference 'Place.count' do
      post :create, place: { name: '',
                             street: 'Schulze-Boysen-Straße',
                             house_number: '15',
                             postal_code: '10365',
                             city: 'Berlin',
                             latitude: 52,
                             longitude: 13,
                             categories: 'Lalalala' }
    end
  end

  test 'should get edit' do
    get :edit, id: @place.id
    assert_response :success
  end

  test 'should update valid place attributes' do
    put :update, id: @place.id, place: { name: 'Blubb',
                                         street: 'Schulze-Boysen-Straße',
                                         house_number: '15',
                                         postal_code: '10365',
                                         city: 'Berlin',
                                         latitude: 52,
                                         longitude: 13,
                                         categories: 'Lalalala' }
    @place.reload.name
    assert_equal 'Blubb', @place.name
  end

  test 'should not update invalid place attributes' do
    put :update, id: @place.id, place: { name: '',
                                         street: 'Schulze-Boysen-Straße',
                                         house_number: '15',
                                         postal_code: '10365',
                                         city: 'Berlin',
                                         latitude: 52,
                                         longitude: 13,
                                         categories: 'Lalalala' }
    @place.reload.name
    assert_equal 'Hausprojekt Magdalenenstraße 19', @place.name
  end

  test 'should delete place' do
    assert_difference 'Place.count', -1 do
      delete :destroy, id:@place.id
    end
    assert_redirected_to places_path
  end

  # Test geocoding ability
  test 'place address should geocode to lat/lon' do
    # Check out how geocoding using 'geocoder' actually works, then test...
  end
end
