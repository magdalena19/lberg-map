feature 'Configure application' do
  scenario 'it can update settings via form', :js do
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SomeAppTitle')
    click_on('Update Setting')
    expect(Admin::Setting.first.app_title).to eq('SomeAppTitle')
  end

  scenario 'it does not access the dashboard as regular user' do

  end

  scenario 'it does not access the dashboard as guest user' do

  end
end
