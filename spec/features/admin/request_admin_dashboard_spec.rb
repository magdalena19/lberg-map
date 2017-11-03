feature 'Admin dashboard', :js do
  scenario 'it can accesses the admin dashboard from navbar' do
    login_as_admin
    visit admin_dashboard_path
    page.find('.glyphicon-tasks').trigger('click')

    expect(page).to have_content('Manage users')
    expect(page).to have_content('Global settings')
  end
end
