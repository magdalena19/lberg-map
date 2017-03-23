# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Map', js: true do
  before do
    place = create :place, :reviewed, map: create(:map, :full_public)

    visit map_path(map_token: place.map.public_token)
  end

  scenario 'has place edit buttons' do
    page.find('.leaflet-marker-icon').trigger('click')
    expect(page).to have_css('.edit-place')
  end
end
