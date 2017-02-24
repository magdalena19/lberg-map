feature 'Configure application' do
  before do
    create :settings, :public
  end

  scenario 'it can update settings via form', :js do
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SomeAppTitle')
    click_on('Update Setting')
    expect(Admin::Setting.app_title).to eq('SomeAppTitle')
  end

  scenario 'it can select another translation engine', :js do
    create :settings, translation_engine: 'bing'
    login_as_admin
    visit admin_settings_path
    find('#admin_setting_translation_engine').find(:xpath, 'option[3]').select_option
    click_on('Update Setting')
    expect(Admin::Setting.translation_engine).to eq('yandex')
  end
end
