feature 'Add new user', :js do
  scenario 'can find section on admin dashboard' do
    login_as_admin
    visit admin_dashboard_path
    click_on('User management')

    expect(page).to have_content('New User')
  end

  scenario 'can add new user' do
    login_as_admin
    visit sign_up_path

    expect(page).not_to have_css('#activation_token')
  end
end
