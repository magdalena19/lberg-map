feature 'Configure application', :js do
  before do
    login_as_admin
    visit admin_settings_path
  end

  scenario 'can change default color' do
    new_color = Place.available_colors.first
    click_on('POIs and Maps')
    fill_in('admin_setting_default_poi_color', with: new_color, visible: false)
    click_on('Update')
    visible_color = find('#admin_setting_default_poi_color', visible: false).value

    expect(visible_color).to eq new_color
  end
end
