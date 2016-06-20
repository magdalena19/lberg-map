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

  test 'should create valid new place' do
    assert_difference 'Place.count' do
      post :create, place: { name: 'Kiezspinne',
                             street: 'Schulze-Boysen-Straße',
                             house_number: '15',
                             postal_code: '10365',
                             city: 'Berlin',
                            }
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
                            }
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
                                        }
    @place.reload.name
    assert_equal 'Blubb', @place.name
  end

  test 'should not update invalid place attributes' do
    put :update, id: @place.id, place: { name: '',
                                         street: 'Schulze-Boysen-Straße',
                                         house_number: '15',
                                         postal_code: '10365',
                                         city: 'Berlin',
                                        }
    @place.reload.name
    assert_equal 'Hausprojekt Magdalenenstraße 19', @place.name
  end

  test 'should delete place' do
    assert_difference 'Place.count', -1 do
      delete :destroy, id: @place.id
    end
    assert_redirected_to places_path
  end

  # Review stuff
  test 'can access review if logged in' do
    @place.save
    @place.reload
    session['user_id'] = @user.id
    get :review, id: @place.id
    assert_response :success
  end

  test 'cannot review if not logged in' do
    session[:user_id] = nil
    @place.save
    @place.reload
    get :review, id: @place.id
    assert_response :redirect
  end

  test 'review flag true if signed in on create' do
    session[:user_id] = @user.id
    post :create, place: { name: 'katze',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                          }
    assert Place.find_by(name: 'katze').reviewed
  end

  test 'review flag false if not logged in on create' do
    session[:user_id] = nil
    post :create, place: { name: 'andere katze',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                          }
    assert_not Place.find_by(name: 'andere katze').reviewed
  end
end
