feature 'Map privacy settings', :js do
  context 'Public maps with restricted access' do
    before do
      @map = create :map, :restricted_access
    end

    scenario 'Cannot insert places / events via form', js_errors: false do
      visit map_path(map_token: @map.public_token)
      show_places_index(map_token: @map.public_token)

      expect(page).not_to have_css('.place-control-container')
    end

    scenario 'Cannot edit places / events via place list index' do
      skip 'Map rendering issue'
      create :place, :reviewed, name: 'SomePlace', map: @map
      show_places_index(map_token: @map.public_token)

      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'Cannot edit places / events via place via sidebar' do
      skip "Does not show sidebar..."
      create :place, :reviewed, name: 'SomePlace', map: @map
      visit map_path(map_token: @map.public_token)
      page.find('.name').trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end
  end
end
