require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create :user, name: 'Norbert'
    @admin = create :user, :admin
    @guest_user = GuestUser.new
  end

  test 'valid user is valid' do
    assert @user.valid?
  end

  test 'invalid user is invalid' do
    @user.name = ''
    assert !@user.valid?
  end

  test 'password must be longer than 5 chars' do
    @user.password = 'asd'
    @user.password_confirmation = 'asd'
    assert !@user.valid?
  end

  test 'cannot add user with invalid email' do
    @user.email = 'peokjwef@pokpwe'
    assert !@user.valid?
  end

  test 'admin user is admin' do
    assert @admin.admin?
  end

  test 'user email is not blank' do
    assert @user.email.present?
  end

  test "user is not admin" do
    assert_not @user.admin?
  end

  test "user is signed in" do
    assert @user.signed_in?
  end

  test "guest is not signed in" do
    assert_not @guest_user.signed_in?
  end

  test 'guest user email is blank' do
    assert_equal '', @guest_user.email
  end

  test "guest user name is 'Guest'" do
    assert_equal "Guest", @guest_user.name
  end

  test "guest user is not admin" do
    assert_not @guest_user.admin?
  end

  test "guest user is guest" do
    assert @guest_user.guest?
  end
end
