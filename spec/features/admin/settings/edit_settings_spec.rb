feature 'Configure application', :js do
  scenario 'can update settings' do
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SomeTitle')
    fill_in('admin_setting_admin_email_address', with: 'foo@bar.org')
    click_on('Update settings')

    expect(page).to have_css('input#admin_setting_app_title', exact: 'SomeTitle')
    expect(page).to have_css('input#admin_setting_admin_email_address', exact: 'foo@bar.org')
  end
end
