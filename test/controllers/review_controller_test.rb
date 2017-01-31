require_relative '../test_helper'

class ReviewControllerTest < ActionController::TestCase
  def setup
    @new_place = Place.create(
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
    @place_with_unreviewed_changes = Place.create(
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
    @place_with_unreviewed_changes.update_attributes(name: 'Magda', description: 'This is an updated description.')
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
    binding.pry
    get :review_index
    assert_equal 2, assigns(:places_to_review).length
    assert_equal 3, assigns(:unreviewed_translations).length
  end
end
