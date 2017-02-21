feature 'Edit user' do
  scenario 'it can find edit link on index', :js do
    login_as_admin
    users = create_list(:user, 1)
    visit admin_users_path
    expect(page).to have_content('Edit')
  end

  scenario 'it can edit and update user settings', :js do
    login_as_admin
    users = create_list(:user, 3)
    visit edit_admin_user_path(id: users.first.id)
    fill_in('user_name', with: 'SomeOtherName')
    click_on('Submit')
    expect(users.first.reload.name).to eq('SomeOtherName')
  end

  scenario 'it displays error message if input invalid', :js do
    login_as_admin
    users = create_list(:user, 3)
    visit edit_admin_user_path(id: users.first.id)
    fill_in('user_name', with: '')
    click_on('Submit')
    expect(page).to have_css('.alert-danger', text: /blank/)
  end

  scenario 'it does not access the dashboard as regular user' do
  end

  scenario 'it does not access the dashboard as guest user' do
  end
end
