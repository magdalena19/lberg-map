feature 'Manage users', :js do
  scenario 'can add new user via admin dashboard without activation tokens' do
    login_as_admin
    visit admin_dashboard_path
    click_on('User management')

    expect(page).not_to have_css('#activation_token')
  end
end
