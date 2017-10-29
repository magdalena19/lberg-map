feature 'Sidepanel', :js do
  context 'Place panel buttons' do
    before do
      @map = create :map, :full_public
      @place = create :place, :reviewed, map: @map, name: 'Place'
      visit map_path(map_token: @map.secret_token)
      show_places_list_panel
      find('.name').trigger('click')
    end

    scenario 'can delete place from sidepanel' do
      page.accept_confirm do
        find('.delete-place').trigger('click')
      end

      show_places_list_panel

      expect(page).to have_content('No places yet!')
      expect(page).not_to have_content('Place')
      expect(page).not_to have_css('.leaflet-marker-icon')
    end
  end
end
