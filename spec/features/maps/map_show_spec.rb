# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Map', js: true do
  context 'Public map' do
    before do
      @map = create :map, :full_public
      @place = create :place, :reviewed, map: @map, name: 'SomePlace'
    end

    scenario 'has place edit buttons fur guest users' do
      visit map_path(map_token: @map.public_token)
      show_place_details(name: 'SomePlace')

      expect(page).to have_css('.edit-place')
      expect(page).not_to have_css('.review_places_button')
    end

    scenario 'has review button in navbar for privileged users' do
      visit map_path(map_token: @map.secret_token)

      expect(page).to have_css('.review-places-button')
    end
  end

  context 'Restricted access map' do
    before do
      @map = create :map, :restricted_access
      @place = create :place, :reviewed, map: @map
    end

    scenario 'has no place edit buttons for guest users' do
      visit map_path(map_token: @place.map.public_token)
      page.find('.leaflet-marker-icon').trigger('click')

      expect(page).not_to have_css('.edit-place')
    end
  end
end