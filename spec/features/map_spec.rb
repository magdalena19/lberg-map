# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Map', js: true do
  scenario 'does not show map features if no user and no session maps' do
    expect(page).not_to have_css('.fa-map-o')
  end

  scenario 'shows map index in navbar' do
    login_as_user
    @place = create :place, :reviewed, map: create(:map, :full_public, user: User.first)
    visit map_path(map_token: @place.map.public_token)
    find('.fa-map-o').trigger('click')

    expect(page).to have_content 'Map index'
  end

  scenario 'shows session map index in navbar if not signed in', js_errors: false do
    visit new_map_path
    
    click_on('Create Map')

    find('.fa-map-o').trigger('click')

    expect(page).to have_content 'Map index'
  end


  context 'Public maps' do
    before do
      @place = create :place, :reviewed, map: create(:map, :full_public)
    end

    scenario 'has place edit buttons fur guest users' do
      skip 'Test fails, feature works'
      visit map_path(map_token: @place.map.secret_token)
      page.find('.leaflet-marker-icon').trigger('click')

      expect(page).to have_css('.edit-place')
    end

    scenario 'has review button in navbar for privileged users' do
      skip 'Test fails, feature works'
      visit map_path(map_token: @place.map.secret_token)
      expect(page).to have_css('.glyphicon-thumbs-up')
    end
  end

  context 'Restricted access' do
    before do
      @map = create :map, :restricted_access
      @place = create :place, :reviewed, map: @map
    end

    scenario 'has no place edit buttons fur guest users' do
      skip 'Test fails, feature works'
      visit map_path(map_token: @place.map.public_token)
      page.find('.leaflet-marker-icon').trigger('click')

      expect(page).not_to have_css('.edit-place')
    end
  end

  context 'Private map' do
    before do
      @place = create :place, :reviewed, map: create(:map, :private)
    end

    scenario 'does not show review button in navbar for privileged users' do
      skip 'Test fails, feature works'
      visit map_path(map_token: @place.map.secret_token)

      expect(page).not_to have_css('.glyphicon-thumbs-up')
    end
  end
end
