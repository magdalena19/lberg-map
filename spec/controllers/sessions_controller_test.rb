require_relative '../test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'can login' do
    @user = create :user, name: 'Norbert'

    post :create, sessions: {
      email: @user.email,
      password: 'secret'
    }

    assert_equal session[:user_id], @user.id
  end

  test 'can logout' do
    @user = create :user, name: 'Norbert'
    get :destroy

    assert_nil session[:user_id]
  end
end
