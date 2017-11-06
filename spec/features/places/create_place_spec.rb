feature 'Create place', :js do
  before do
    @map = create :map, :full_public
  end

  context 'As privileged user' do
    scenario 'can insert place manually as user' do
      create_place_as_user(map_token: @map.secret_token)

      expect(page).to have_css('.leaflet-marker-icon', count: 1)
      expect(page).to have_css('.glyphicon-pencil', visible: false)
    end

    scenario 'show only one wysiwyg editor for current locale' do
      skip 'WYSIWIG EDITOR NOT WORKING'

      open_new_place_modal(map_token: @map.secret_token)
      expect(page).to have_css('.wysihtml5-toolbar', count: 1)

      page.find_all('.glyphicon-triangle-bottom').last.trigger('click')
      expect(page).to have_css('.wysihtml5-toolbar', count: 2)
    end
  end

  context 'As guest' do
    scenario 'can insert place manually as guest' do
      skip 'To be implemented'
      create_place(map_token: @map.public_token)

      expect(page).to have_css('.leaflet-marker-icon', count: 1)
      expect(page).not_to have_css('.glyphicon-pencil', visible: false)
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
