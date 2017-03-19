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

  scenario 'it can set map semi-public', :js do
    create :settings, :public
    login_as_admin
    visit admin_settings_path
    page.find('#admin_setting_allow_guest_commits').trigger('click')
    click_on('Update Setting')
    visit '/en/logout'
    visit '/en'

    expect(Admin::Setting.allow_guest_commits).to be false
    expect(page).not_to have_css('.place-control-container')
  end

  scenario 'it can set app title', :js do
    create :settings, :public
    login_as_admin
    visit admin_settings_path
    fill_in('admin_setting_app_title', with: 'SOMETHING DIFFERENT')
    click_on('Update Setting')
    visit '/en/logout'
    visit '/en'

    expect(page.title).to eq 'SOMETHING DIFFERENT'
    expect(page).to have_css('.logo', text: 'SOMETHING DIFFERENT')
  end
end
