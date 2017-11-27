feature 'Marker color selection', :js do
  let(:map) { create :map, :full_public }

  scenario 'Show color picker if multi color POIs enabled' do
    skip 'DEPRECATED'
    create :settings, multi_color_pois: true

    open_new_place_modal(map_token: map.public_token)

    expect(page).to have_css('#place_color', visible: false)
  end

  scenario 'Do not show color picker if multi color POIs disabled' do
    skip 'DEPRECATED'
    create :settings, multi_color_pois: false

    open_new_place_modal(map_token: map.public_token)

    expect(page).not_to have_css('#place_color', visible: false)
  end
end
