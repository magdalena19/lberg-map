require_relative '../test_helper'

class ReviewControllerTest < ActionController::TestCase
  test 'review access for logged in users' do
    login
    get :review_index
    assert_response :success
  end

  test 'no review access for not logged in users' do
    logout
    get :review_index
    assert_response :redirect
  end

  test 'Review index shows new and unreviewed places and unreviewed translations' do
    session[:user_id] = nil
    @new_unreviewed_place= create :place, :unreviewed
    @reviewed_place = create :place, :reviewed

    @controller = PlacesController.new
    put :update, id: @reviewed_place, place: { name: 'Magda' }
    put :update, id: @reviewed_place, place: { description_en: 'This is an updated description' }

    login
    @controller = ReviewController.new
    get :review_index
    assert_equal 2, assigns(:places_to_review).length
    assert_equal 3, assigns(:unreviewed_translations).length
  end

  private

  def login
    @user = create :user, name: 'Norbert'
    session[:user_id] = @user.id
  end

  def logout
    session[:user_id] = nil
  end
end
