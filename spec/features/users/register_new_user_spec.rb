feature 'Register new user', :js do
  scenario 'Create valid new user with valid token' do
    create :user
    visit sign_up_path
    token = User.first.activation_tokens.first.token

    fill_in('activation_token', with: token)
    fill_in('user_name', with: 'SomeName')
    fill_in('user_email', with: 'foo@bar.com')
    fill_in('user_password', with: 'secret')
    fill_in('user_password_confirmation', with: 'secret')
    click_on('Register user')

    expect(User.count).to be 2
  end
end
