feature 'Request admin dashboard' do
  scenario 'it accesses the dashboard as admin user' do
    login_as_admin
    visit admin_dashboard_path
  end

  scenario 'it does not access the dashboard as regular user' do

  end

  scenario 'it does not access the dashboard as guest user' do

  end
end
