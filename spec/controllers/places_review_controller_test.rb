require_relative '../test_helper'

class PlacesReviewControllerTest < ActionController::TestCase
  def setup
    @user = create :user, name: 'Norbert'
  end

  test 'New place can be confirmed' do
    new_place = create :place, :unreviewed, name: 'SomeName'
    assert_nil new_place.reviewed_version

    session[:user_id] = @user.id
    get :review, id: new_place.id
    assert_response :success
    get :confirm, id: new_place.id

    @controller = ReviewController.new
    get :review_index
    assert_equal 0, assigns(:places_to_review).length
  end

  test 'Refusing of unreviewed changes only deletes unreviewed version' do
    place_with_changes = create :place, :reviewed, name: 'SomeName'
    place_with_changes.update_attributes(name: 'SomeOtherName', description: 'This is an updated description.')
    session[:user_id] = @user.id
    get :refuse, id: place_with_changes.id

    assert Place.find_by(name: 'SomeName')

    @controller = ReviewController.new
    get :review_index
    assert_equal 0, assigns(:places_to_review).length
  end

  test 'Refusing of new place deletes it entirely' do
    @new_unreviewed_place = create :place, :unreviewed

    get :refuse, id: @new_unreviewed_place.id

    assert_not Place.find_by(name: 'Kiezspinne')
  end
end
