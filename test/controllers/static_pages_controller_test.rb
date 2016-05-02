require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test 'should get about page' do
    assert_equal '/about', about_path
    get :about
    assert_template 'static_pages/about'
  end

  test 'should get contact page' do
    assert_equal '/contact', about_path
    get :contact
    assert_template 'static_pages/contact'
  end
end
