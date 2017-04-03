feature 'Admin dashboard', :js do
  scenario 'it can accesses the dashboard as admin user' do
    login_as_admin
    visit admin_dashboard_path
    expect(page).to have_content('settings')
  end

  scenario 'it links to admin dashboard in navbar as admin user' do
    login_as_admin
    page.find('.glyphicon-cog').trigger('click')
    expect(page).to have_content('Manage users')
    expect(page).to have_content('Global settings')
  end
end
