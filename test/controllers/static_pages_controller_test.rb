require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test 'should get about page' do
    assert_equal "/#{I18n.locale}/about", about_path
    get :about
    assert_template 'static_pages/about'
  end

  test 'does not crash with not up-to-date session_places cookie' do
    @request.cookies[:created_places_in_session] = [1,2,3,4,5,7723487]
    get :map
    assert_response :success
  end

  test "should get contact page" do
    get :contact
    assert_response :success
  end
end
