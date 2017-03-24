feature 'Map privacy settings' do
  context 'Public maps with restricted access' do
    before do
      @map = create :map, :restricted_access
    end

    scenario 'Cannot insert places / events via form', :js do
      visit map_path(map_token: @map.public_token)

      expect(page).not_to have_css('.place-control-container')
    end

    scenario 'Cannot edit places / events via place list index', :js do
      create :place, :reviewed, name: 'SomePlace', map: @map
      visit places_path(map_token: @map.public_token)

      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'Cannot edit places / events via place via sidebar', :js do
      create :place, :reviewed, name: 'SomePlace', map: @map
      visit map_path(map_token: @map.public_token)
      page.find('.name').trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end
  end
end
