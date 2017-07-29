feature 'Configure application', :js do
  before do
    login_as_admin
    visit admin_settings_path
  end

  scenario 'can update map ownership settings' do
    click_on('Public information')
    fill_in('admin_setting_app_title', with: 'SomeTitle')
    fill_in('admin_setting_admin_email_address', with: 'foo@bar.org')
    click_on('Update')

    expect(Admin::Setting.app_title).to eq 'SomeTitle'
    expect(Admin::Setting.admin_email_address).to eq 'foo@bar.org'
  end

  scenario 'can change captcha system' do
    skip 'Fails on travis regularly...'

    click_on('Security')
    find('#admin_setting_captcha_system').find(:xpath, 'option[2]').select_option
    click_on('Update')

    expect(Admin::Setting.captcha_system).to eq 'simple_captcha'
  end

  scenario 'can change user activation tokens' do
    click_on('User settings')
    fill_in('admin_setting_user_activation_tokens', with: '3')
    click_on('Update')

    expect(Admin::Setting.user_activation_tokens).to eq 3
  end

  scenario 'can change place color settings' do
    click_on('POIs and Maps')
    page.find("input[type='checkbox']").trigger('click')
    click_on('Update')

    expect(Admin::Setting.multi_color_pois).to be false
  end

  scenario 'can change default color' do
    new_color = Place.available_colors.first
    click_on('POIs and Maps')
    fill_in("admin_setting_default_poi_color", with: new_color, visible: false)
    click_on('Update')

    expect(Admin::Setting.default_poi_color).to eq new_color
  end

  scenario 'can set expiry days for guest maps' do
    click_on('POIs and Maps')
    fill_in('admin_setting_expiry_days', with: '10')
    click_on('Update')

    expect(Admin::Setting.expiry_days).to eq 10
    expect(Admin::Setting.auto_destroy_expired_maps?).to be true
  end

  scenario 'can unset auto_destroy for guest maps' do
    click_on('POIs and Maps')
    fill_in('admin_setting_expiry_days', with: '0')
    click_on('Update')

    expect(Admin::Setting.expiry_days).to eq 0
    expect(Admin::Setting.auto_destroy_expired_maps?).to be false
  end
end
