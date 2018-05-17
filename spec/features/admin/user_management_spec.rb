feature 'User management', :js do
  scenario 'Create new user as admin' do
    login_as_admin
    create_user_and_find_in_index
  end

  def create_user_and_find_in_index
    visit admin_index_users_path
    click_on 'New User'
    fill_in 'user_name', with: 'test'
    fill_in 'user_email', with: 'user@test.com'
    fill_in 'user_password', with: 'secret'
    fill_in 'user_password_confirmation', with: 'secret'
    click_on 'Register user'
    expect(page).to have_content 'user@test.com'
  end
end
