require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test 'should get about page' do
    assert_equal "/#{I18n.locale}/about", about_path
    get :about
    assert_template 'static_pages/about'
  end
end
