feature 'Configure application', :js do
  scenario 'can update settings' do
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SomeTitle')
    fill_in('admin_setting_admin_email_address', with: 'foo@bar.org')
    fill_in('admin_setting_user_activation_tokens', with: 3)
    click_on('Update settings')

    expect(Admin::Setting.app_title).to eq 'SomeTitle'
    expect(Admin::Setting.admin_email_address).to eq 'foo@bar.org'
    expect(Admin::Setting.user_activation_tokens).to be 3
  end
end
