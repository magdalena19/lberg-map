feature 'Marker color selection', :js do
  let(:map) { create :map, :full_public }

  scenario 'Show color picker if multi color POIs enabled' do
    create :settings, multi_color_pois: true

    visit new_place_path(map_token: map.secret_token)

    expect(page).to have_css('#place_color', visible: false)
  end

  scenario 'Do not show color picker if multi color POIs disabled' do
    create :settings, multi_color_pois: false

    visit new_place_path(map_token: map.secret_token)

    expect(page).not_to have_css('#place_color', visible: false)
  end
end
