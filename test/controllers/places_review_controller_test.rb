require_relative '../test_helper'

class PlacesReviewControllerTest < ActionController::TestCase
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
                    reviewed: false)

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
    @user = create :user, name: 'Norbert'
    session[:user_id] = @user.id
  end

  test 'New place can be confirmed' do
    assert_not Place.find_by(name: 'Kiezspinne').reviewed_version

    get :review, id: @place_with_unreviewed_changes.id
    assert_response :success
    get :confirm, id: @place_with_unreviewed_changes.id

    @controller = ReviewController.new
    get :review_index
    assert_equal 1, assigns(:places_to_review).length
  end

  test 'Refusing of unreviewed changes only deletes unreviewed version' do
    get :refuse, id: @place_with_unreviewed_changes.id
    assert Place.find_by(name: 'Magda19')

    @controller = ReviewController.new
    get :review_index
    assert_equal 1, assigns(:places_to_review).length
  end

  test 'Refusing of new place deletes it entirely' do
    get :refuse, id: @new_place.id

    assert_not Place.find_by(name: 'Kiezspinne')
  end
end
