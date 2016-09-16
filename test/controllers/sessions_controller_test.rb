require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users :Norbert
  end

  test 'can login' do
    post :create, sessions: {
      email: @user.email,
      password: 'secret'
    }
    assert_equal session[:user_id], @user.id
  end

  test 'can logout' do
    get :destroy
    assert_nil session[:user_id]
  end
end
