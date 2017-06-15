feature 'Configure application', :js do
  before do
    login_as_admin
    visit admin_settings_path
  end

  scenario 'can update settings' do
    fill_in('admin_setting_app_title', with: 'SomeTitle')
    fill_in('admin_setting_admin_email_address', with: 'foo@bar.org')
    click_on('Update')

    expect(page).to have_css('input#admin_setting_app_title', exact: 'SomeTitle')
    expect(page).to have_css('input#admin_setting_admin_email_address', exact: 'foo@bar.org')
  end

  scenario 'can change captcha system' do
    fill_in('admin_setting_app_title', with: 'SomeTitle')
    find('#admin_setting_captcha_system').find(:xpath, 'option[2]').select_option
    click_on('Update')

    visit admin_settings_path
    expect(page).to have_css('select#admin_setting_captcha_system', exact: 'simple_captcha')
  end
end
