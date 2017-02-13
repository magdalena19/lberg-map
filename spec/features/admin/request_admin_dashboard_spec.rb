feature 'Request admin dashboard' do
  scenario 'it accesses the dashboard as admin user', js: true do
    login_as_admin
    visit admin_dashboard_path
    expect(page).to have_content('settings')
  end
end
