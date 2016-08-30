require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  def setup
    @place = places :Magda19
    @user = users :Norbert
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

  test 'does not crash with not up-to-date session_places cookie' do
    @request.cookies[:created_places_in_session] = [1,2,3,4,5,7723487]
    get :index
    assert_response :success
  end

  test 'should create valid new place' do
    assert_difference 'Place.count' do
      post :create, place: { name: 'Kiezspinne',
                             street: 'Schulze-Boysen-Straße',
                             house_number: '15',
                             postal_code: '10365',
                             city: 'Berlin',
                             categories: [] }
    end

    assert_redirected_to root_path(latitude: 52.0, longitude: 12.0)
  end

  test 'place with lat_lon provided does not need to be geocoded' do
    assert_difference 'Place.count' do
      post :create, place: { name: 'SomePlace',
                             latitude: 13,
                             longitude: 52 }
    end
  end

  test 'should not create invalid new place' do
    assert_no_difference 'Place.count' do
      post :create, place: { name: '',
                             street: 'Schulze-Boysen-Straße',
                             house_number: '15',
                             postal_code: '10365',
                             city: 'Berlin',
                             categories: [] }
    end
  end

  test 'should not provide edit action for places waiting for review' do
    @new_place = Place.new( name: 'New Place',
                            street: 'Schulze-Boysen-Straße',
                            house_number: '15',
                            postal_code: '10365',
                            city: 'Berlin',
                            categories: [],
                          )
    @new_place.save
    get :edit, id: @new_place.id
    assert_redirected_to root_path
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
                                         categories: [] }
    @place.reload.name
    assert_equal 'Blubb', @place.name
  end

  test 'should not update invalid place attributes' do
    put :update, id: @place.id, place: { name: '',
                                         street: 'Schulze-Boysen-Straße',
                                         house_number: '15',
                                         postal_code: '10365',
                                         city: 'Berlin',
                                         categories: [] }
    @place.reload.name
    assert_equal 'Hausprojekt Magdalenenstraße 19', @place.name
  end

  test 'should delete place' do
    assert_difference 'Place.count', -1 do
      delete :destroy, id: @place.id
    end
    assert_redirected_to places_path
  end

  test 'review flag true if signed in on create' do
    session[:user_id] = @user.id
    post :create, place: { name: 'katze',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           categories: [] }
    assert Place.find_by(name: 'katze').reviewed
  end

  test 'review flag false if not logged in on create' do
    session[:user_id] = nil
    post :create, place: { name: 'andere katze',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           categories: [] }
    assert_not Place.find_by(name: 'andere katze').reviewed
  end
end
