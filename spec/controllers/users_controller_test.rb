describe UsersController do

	let(:user) { create :user, name: 'Norbert' }

  context 'GET #edit' do
    it 'should populate user in @member'
    it 'should render :edit template'
    context 'reject editing' do
      it 'if not logged in'
      it 'other groups users'
    end
  end

  context 'PATCH #update' do
    it 'should update if attributes are valid'
    context 'reject updates' do
      it 'if not logged in'
      it 'other groups users'
    end
  end
end

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = create :user, name: 'Norbert'
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
    user2 = create :user, name: 'Susanne'
    get :edit, id: user2.id
    assert_redirected_to root_url
  end
end
