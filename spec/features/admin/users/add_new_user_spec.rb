feature 'Add new user' do
  scenario 'can find section on admin dashboard', :js do
    login_as_admin
    visit admin_dashboard_path
    click_on('User management')
    expect(page).to have_content('New User')
  end

  scenario 'can add new user', :js do
    login_as_admin
    visit new_admin_user_path
    fill_in('user_name', with: 'TestUser')
    fill_in('user_email', with: 'testuser@test.com')
    fill_in('user_password', with: 'secret')
    fill_in('user_password_confirmation', with: 'secret')
    expect {
      click_on('Create new user')
    }.to change { User.count }.by(1)
  end

  scenario 'it displays error message if input invalid', :js do
    login_as_admin
    visit new_admin_user_path
    fill_in('user_name', with: '')
    fill_in('user_email', with: 'testuser@test.com')
    fill_in('user_password', with: 'secret')
    fill_in('user_password_confirmation', with: 'secret')
    click_on('Create new user')
    expect(page).to have_css('.alert-danger', text: /blank/)
  end

  scenario 'it does not access the dashboard as regular user' do
  end

  scenario 'it does not access the dashboard as guest user' do
  end
end
