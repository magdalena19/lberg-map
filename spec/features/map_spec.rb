# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Map', js: true do
  scenario 'shows map index in navbar' do
    login_as_user
    @place = create :place, :reviewed, map: create(:map, :full_public, user: User.first)
    visit map_path(map_token: @place.map.public_token)

    expect(page).to have_css('.glyphicon-th-large')
  end

  context 'Public maps' do
    before do
      @place = create :place, :reviewed, map: create(:map, :full_public)
    end

    scenario 'has place edit buttons fur guest users' do
      visit map_path(map_token: @place.map.public_token)
      page.find('.leaflet-marker-icon').trigger('click')

      expect(page).to have_css('.edit-place')
    end

    scenario 'has review button in navbar for privileged users' do
      visit map_path(map_token: @place.map.secret_token)
      expect(page).to have_css('.glyphicon-thumbs-up')
    end
  end

  context 'Restricted access' do
    before do
      @place = create :place, :reviewed, map: create(:map, :restricted_access)
    end

    scenario 'has no place edit buttons fur guest users' do
      visit map_path(map_token: @place.map.public_token)
      page.find('.leaflet-marker-icon').trigger('click')

      expect(page).not_to have_css('.edit-place')
    end

    scenario 'does not show review button in navbar for privileged users' do
      visit map_path(map_token: @place.map.secret_token)

      expect(page).not_to have_css('.glyphicon-thumbs-up')
    end
  end

  context 'Privatew map' do
    scenario 'does not show review button in navbar for privileged users' do
      @place = create :place, :reviewed, map: create(:map, :restricted_access)
      visit map_path(map_token: @place.map.secret_token)

      expect(page).not_to have_css('.glyphicon-thumbs-up')
    end
  end
end
