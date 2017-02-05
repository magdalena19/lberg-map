require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @u = create :user, name: 'Norbert'
  end

  test 'valid user is valid' do
    assert @u.valid?
  end

  test 'invalid user is invalid' do
    @u.name = ''
    assert !@u.valid?
  end

  test 'password must be longer than 5 chars' do
    @u.password = 'asd'
    @u.password_confirmation = 'asd'
    assert !@u.valid?
  end

  test 'cannot add user with invalid email' do
    @u.email = 'peokjwef@pokpwe'
    assert !@u.valid?
  end
end
