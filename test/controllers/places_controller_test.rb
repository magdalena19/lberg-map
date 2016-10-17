require_relative '../test_helper'

class PlacesControllerTest < ActionController::TestCase
  def setup
    @reviewed_place = Place.create(name: 'bar',
                                   street: 'bar-street',
                                   house_number: '19',
                                   postal_code: '10365',
                                   city: 'Berlin',
                                   latitude: 52.5,
                                   longitude: 13.5,
                                   email: 'schnipp@schnapp.com',
                                   homepage: 'http://schnapp.com',
                                   phone: '03081618254',
                                   id: 1000,
                                   description: 'This is a reviewed_place',
                                   reviewed: true)

    @unreviewed_place = Place.create(name: 'foo',
                                     street: 'foo-street',
                                     house_number: '19',
                                     postal_code: '19999',
                                     city: 'Berlin',
                                     latitude: 52.5,
                                     longitude: 13.5,
                                     email: 'schnipp@schnapp.com',
                                     homepage: 'http://schnapp.com',
                                     phone: '03081618254',
                                     id: 1001,
                                     description: 'This is an unreviewed_place',
                                     reviewed: false)

    @user = users :Norbert
  end

  ### Helper function
  def post_valid_place
    post :create, place: { name: 'Kiezspinne',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           description_en: 'This is a valid place',
                           categories: [] }
    Place.find_by(name: 'Kiezspinne')
  end

  def update_reviewed_description
    put :update, id: @reviewed_place.id, place: { description_en: 'This description has been changed!' }

    @reviewed_place.translations.reload
    @reviewed_place
  end

  def sign_in
    session[:user_id] = @user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  ### Tests independent of user status
  test 'Does not crash with not up-to-date session_places cookie' do
    @request.cookies[:created_places_in_session] = [1, 2, 3, 4, 5, 772_348_7]
    get :index
    assert_response :success
  end

  test 'Place with lat_lon provided does not need to be geocoded on create' do
    post :create, place: { name: 'PlaceWithLatLong',
                           latitude: 62.0,
                           longitude: 10.0,
                           email: 'schnipp@schnapp.com',
                           homepage: 'http://schnapp.com',
                           phone: '03081618254',
                           description: 'This is a reviewed_place' }
    new_place = Place.find_by(name: 'PlaceWithLatLong')

    assert_equal 62.0, new_place.latitude
    assert_equal 10.0, new_place.longitude
  end

  test 'Cannot create invalid new place' do
    assert_no_difference 'Place.count' do
      post :create, place: { name: '',
                             street: 'Schulze-Boysen-Straße',
                             house_number: '15',
                             postal_code: '10365',
                             city: 'Berlin',
                             categories: [] }
    end
  end

  test 'Translations of reviewed place are also reviewed on create' do
    sign_in
    valid_new_place = post_valid_place

    valid_new_place.translations.each do |translation|
      assert translation.reviewed
    end
    # debugger
  end

  test 'Cannot update place if attributes invalid' do
    put :update, id: @reviewed_place.id, place: { name: '',
                                                  street: 'some other street' }
    assert_response 400
  end

  test 'Cannot update place if is not reviewed' do
    put :update, id: @unreviewed_place.id, place: { name: 'Some other name',
                                                    street: 'Some other street' }
    assert_response :redirect
  end


  # As guest...
  test 'Guest can create valid new place' do
    sign_out

    get :new
    assert_response :success

    assert_difference 'Place.count' do
      post_valid_place
    end
  end

  test 'Place created by guest is not reviewed' do
    sign_out
    valid_new_place = post_valid_place

    assert_not valid_new_place.reviewed
  end

  test 'Place created by guest has no version history' do
    sign_out
    valid_new_place = post_valid_place

    assert_equal 1, valid_new_place.versions.length
  end

  test 'Translations of place created by guest are not reviewed' do
    sign_out
    valid_new_place = post_valid_place

    valid_new_place.translations.each do |translation|
      assert_not translation.reviewed
    end
  end

  test 'Translations of place created by guest have no version history' do
    sign_out
    valid_new_place = post_valid_place

    valid_new_place.translations.each do |translation|
      assert_equal 1, translation.versions.length
    end
  end

  test 'Translations of place created by guest have correct auto-translation flags' do
    sign_out
    valid_new_place = post_valid_place # posted description == en
    auto_translations = valid_new_place.translations.reject { |t| t.locale == :en }

    valid_new_place.translations.each do |translation|
      if auto_translations.include? translation
        assert translation.auto_translated
      else
        assert_not translation.auto_translated
      end
    end
  end

  test 'Guest can update reviewed place' do
    sign_out
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert_equal 'Some other name', @reviewed_place.name
  end

  test 'Place updated by guest is reviewed' do
    sign_out
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert_not @reviewed_place.reviewed
  end

  test 'Place updated by guest has version history' do
    sign_out
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert_equal 2, @reviewed_place.versions.length
  end

  test 'Guest cannot delete places' do
    sign_out
    assert_difference 'Place.count', 0 do
      delete :destroy, id: @reviewed_place.id
    end
    assert_response :redirect
  end

  test 'Guest cannot update unreviewed translation' do
    # Create unreviewed description
    sign_out
    updated_place = update_reviewed_description

    # Login as user and try to commit changes to description under review
    put :update, id: updated_place.id, place: { description_en: 'This description has been changed again!' }
    assert_response :redirect
  end

  test 'Guest can update reviewed translation' do
    sign_out
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert_equal 'This description has been changed!', en_translation.description
  end

  test 'Translation updated by guest is not reviewed' do
    sign_out
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert_not en_translation.reviewed
  end

  test 'Translation updated by guest has version history' do
    sign_out
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert_equal 2, en_translation.versions.length
  end


  # As user...
  test 'User can create valid new place' do
    sign_in

    get :new
    assert_response :success

    assert_difference 'Place.count' do
      post_valid_place
    end
  end

  test 'Place created by user is reviewed' do
    sign_in
    valid_new_place = post_valid_place

    assert valid_new_place.reviewed
    assert_equal 1, valid_new_place.versions.length
  end

  test 'Place created by user has no version history' do
    sign_in
    valid_new_place = post_valid_place

    assert valid_new_place.reviewed
    assert_equal 1, valid_new_place.versions.length
  end

  test 'Translations of place created by users are reviewed' do
    sign_in
    valid_new_place = post_valid_place

    valid_new_place.translations.each do |translation|
      assert translation.reviewed
    end
  end

  test 'Translations of place created by users have no version history' do
    sign_in
    valid_new_place = post_valid_place

    valid_new_place.translations.each do |translation|
      assert_equal 1, translation.versions.length
    end
  end

  test 'Translations of place created by users have correct auto-translation flags' do
    sign_in
    valid_new_place = post_valid_place # posted description == en
    auto_translations = valid_new_place.translations.reject { |t| t.locale == :en }

    valid_new_place.translations.each do |translation|
      if auto_translations.include? translation
        assert translation.auto_translated
      else
        assert_not translation.auto_translated
      end
    end
  end

  test 'User can delete places' do
    sign_in
    assert_difference 'Place.count', -1 do
      delete :destroy, id: @reviewed_place.id
    end
  end

  test 'User can update reviewed place' do
    sign_in
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert_equal 'Some other name', @reviewed_place.name
  end

  test 'Place updated by user is reviewed' do
    sign_in
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert @reviewed_place.reviewed
  end

  test 'Place updated by user has no version history' do
    sign_in
    put :update, id: @reviewed_place.id, place: { name: 'Some other name',
                                                  street: 'Some other street' }
    @reviewed_place.reload

    assert_equal 1, @reviewed_place.versions.length
  end

  test 'User cannot update unreviewed translation' do
    # Create unreviewed description
    sign_out
    updated_place = update_reviewed_description

    # Login as user and try to commit changes to description under review
    sign_in
    put :update, id: updated_place.id, place: { description_en: 'This description has been changed again!' }
    assert_response :redirect
  end

  test 'User can update reviewed translation' do
    sign_in
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert_equal 'This description has been changed!', en_translation.description
  end

  test 'Translation updated by user is reviewed' do
    sign_in
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert en_translation.reviewed
  end

  test 'Translation updated by user has no history' do
    sign_in
    updated_place = update_reviewed_description
    en_translation = updated_place.translations.select { |t| t.locale == :en }.first

    assert_equal 1, en_translation.versions.length
  end
end
