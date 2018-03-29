feature 'Create place', :js do
  before do
    @map = create :map, :full_public
    create :place, map: @map, name: 'Foo'
  end

  context 'As privileged user' do
    scenario 'can insert place manually as user' do
      create_place_as_user(map_token: @map.secret_token, name: 'Foo')

      show_place_details(name: 'Foo')
      expect(page).to have_css('.leaflet-marker-icon', count: 1)
      expect(page).to have_css('.fa-pencil')
    end
  end

  context 'As guest' do
    scenario 'can insert place manually as guest' do
      create_place(map_token: @map.public_token)

      expect(page).to have_css('.leaflet-marker-icon', count: 1)
      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'see guests session places on map' do
      skip 'To be implemented'
      create_place_as_guest(place_name: 'Another place', map_token: @map.public_token)
      create_place_as_guest(place_name: 'Still another place', map_token: @map.public_token)
      visit '/en'

      expect(page).to have_content('Another place')
      expect(page).to have_content('Still another place')
    end
  end
end
