require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users :Norbert
  end

  test 'can access edit' do
    session[:user_id] = @user.id
    get :edit, id: @user.id
    assert_response :success
  end

  test 'can change all own credentials' do
    session[:user_id] = @user.id
    get :edit, id: @user.id
    put :update, id: @user.id, user: {
      name: 'Norbert2',
      email: 'blubb@bla.de',
      password: 'schnipp',
      password_confirmation: 'schnipp' }
    @user.reload.email
    assert_equal 'blubb@bla.de', @user.email
  end

  test 'cannot edit user credentials if not signed in' do
    get :edit, id: @user.id
    assert_response :redirect
  end

  test 'cannot edit other users credentials' do
    session[:user_id] = @user.id
    user2 = users :Susanne
    get :edit, id: user2.id
    assert_redirected_to root_path
  end
end
