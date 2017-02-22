feature 'Configure application' do
  before do
    create :settings, :public
  end

  scenario 'it can update settings via form', :js do
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SomeAppTitle')
    click_on('Update Setting')
    expect(Admin::Setting.first.app_title).to eq('SomeAppTitle')
  end

  scenario 'it does not access the dashboard as regular user' do
    skip "Don't know how to implement this test properly"
  end

  scenario 'it does not access the dashboard as guest user' do
    skip "Don't know how to implement this test properly"
  end
end
