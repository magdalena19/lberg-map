require 'test_helper'

class ReviewControllerTest < ActionController::TestCase
  def setup
    @new_place = Place.new(
                    name: 'Kiezspinne',
                    street: 'Schulze-Boysen-Straße',
                    house_number: '13',
                    postal_code: '10365',
                    city: 'Berlin',
                    description_en: 'bla bli blubs',
                    latitude: 13,
                    longitude: 52,
                    reviewed: false
                  )
    @new_place.save
    @place_with_unreviewed_changes = Place.new(
                                        name: 'Magda19',
                                        street: 'Magdalenenstraße',
                                        house_number: '19',
                                        postal_code: '10365',
                                        city: 'Berlin',
                                        description_en: 'This is an description.',
                                        latitude: 13,
                                        longitude: 52,
                                        reviewed: true
                                      )
    @place_with_unreviewed_changes.save
    @place_with_unreviewed_changes.update(name: 'Magda')
    @place_with_unreviewed_changes.update(description: 'This is an updated description.')
    @user = users :Norbert
    session[:user_id] = @user.id
  end

  test 'review access for logged in users' do
    get :review_index
    assert_response :success
  end

  test 'no review access for not logged in users' do
    session[:user_id] = nil
    get :review_index
    assert_response :redirect
  end

  test 'Review index shows new and unreviewed places and unreviewed translations' do
    get :review_index
    assert_equal 2, assigns(:places_to_review).length
    assert_equal 3, assigns(:unreviewed_translations).length
  end

  test 'New place can be confirmed' do
    assert_not Place.find_by(name: 'Kiezspinne').reviewed_version
    get :review_place, id: @new_place.id
    assert_response :success
    get :confirm_place, id: @new_place.id
    get :review_index
    assert_equal 1, assigns(:places_to_review).length
    assert Place.find_by(name: 'Kiezspinne').reviewed_version
  end

  test 'Refusing of unreviewed changes only deletes unreviewed version' do
    get :refuse_place, id: @place_with_unreviewed_changes.id
    assert Place.find_by(name: 'Magda19')
    get :review_index
    assert_equal 1, assigns(:places_to_review).length
  end

  test 'Refusing of new place deletes it' do
    get :refuse_place, id: @new_place.id
    assert_not Place.find_by(name: 'Kiezspinne')
  end

  test 'unreviewed translations can be confirmed' do
    translations = @place_with_unreviewed_changes.translations
    id = translations.find_by(description: 'This is an updated description.').id
    get :confirm_translation, id: id
    get :review_index
    assert translations.find_by(description: 'This is an updated description.')
    assert_not translations.find_by(description: 'This is an description.')
  end

  test 'Refusing of unreviewed Translation only deletes unreviewed version' do
    translations = @place_with_unreviewed_changes.translations
    id = translations.find_by(description: 'This is an updated description.').id
    get :refuse_translation, id: id
    get :review_index
    assert translations.find_by(description: 'This is an description.')
    assert_not translations.find_by(description: 'This is an updated description.')
  end
end
