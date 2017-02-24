feature 'Add new user' do
  scenario 'it can find section on admin dashboard', :js do
    login_as_admin
    visit admin_dashboard_path
    click_on('User management')
  end

  scenario 'it does not access the dashboard as regular user' do
  end

  scenario 'it does not access the dashboard as guest user' do
  end
end
