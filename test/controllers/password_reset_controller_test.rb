require_relative '../test_helper'

class PasswordResetControllerTest < ActionController::TestCase
  def setup
    @user = create :user, name: 'Norbert'
  end

  test "Can request password reset" do
    get :request_password_reset
    assert_response :success
  end

  test "Shall create new password reset digest for existing account" do
    post :create_password_reset, password_reset: { email: 'norbert@example.com' }
    @user.reload

    assert @user.password_reset_digest
  end

  test "Shall send password request email on password reset request for existing account" do
    assert_difference 'DeliveryGul.deliveries.count' do
      post :create_password_reset, password_reset: { email: 'norbert@example.com' }
    end
  end

  test "Shall do nothing if no account was found to reset password for" do
    assert_no_difference 'DeliveryGul.deliveries.count' do
      post :create_password_reset, password_reset: { email: 'somewrongaddress@bar.org' }
      assert_equal 'Zu dieser Email-Adresse wurde kein passender Account gefunden!', flash[:danger]
    end
  end

  test "Shall allow password reset for valid token" do
    @user.create_digest_for(attribute: 'password_reset')
    @user.save

    get :reset_password, id: @user.id, token: @user.password_reset_token
    assert_response :success
  end

  test "Shall alert and redirect to root url if link is invalid" do
    @user.create_digest_for(attribute: 'password_reset')
    @user.save

    get :reset_password, id: @user.id, token: 'Some invalid token'
    assert_equal 'Link zum Passwort zurücksetzen ist ungültig!', flash[:danger]
    assert_redirected_to root_url
  end

  test "Shall not accept tokens older than 24hrs as valid" do
    @user.create_digest_for(attribute: 'password_reset')
    @user.password_reset_timestamp = Time.now - 25.hours
    @user.save

    get :reset_password, id: @user.id, token: @user.password_reset_token
    assert_equal 'Link zum Passwort zurücksetzen ist ungültig!', flash[:danger]
    assert_redirected_to root_url
  end
end
