feature 'Map privacy settings', :js do
  context 'Public maps with restricted access' do
    before do
      @map = create :map, :restricted_access
      create :place, :reviewed, name: 'AdventurePark', categories: 'Playground', phone: 1337, map: @map
      create :place, :reviewed, name: 'Playpital', categories: 'Hospital, Playground', map: @map
      create :place, :reviewed, name: 'Mr Bean', categories: 'lawyer', phone: 1337, map: @map
      create(
        :event,
        :reviewed,
        name: 'ShutdownCapitalism',
        categories: 'Demo',
        start_date: DateTime.new(2015,7,1,15,0),
        end_date: DateTime.new(2015,7,1,19,30),
        phone: 110,
        map: @map
      )
      create(
        :event,
        :reviewed,
        name: 'PartySafari',
        categories: 'Party',
        start_date: DateTime.new(2015,7,1,20,0),
        end_date: DateTime.new(2015,7,2,12,0),
        phone: 110,
        map: @map
      )
      create :place, :unreviewed, categories: 'Playground', map: @map
      visit map_path(map_token: @map.public_token)
    end

    scenario 'Cannot insert places / events via form', js_errors: false do
      show_places_list_panel

      expect(page).not_to have_css('.place-control-container')
    end

    scenario 'Cannot edit places / events via place list index' do
      show_places_index
      find('.modal-body').find_all('.place_type').first.trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'Cannot edit places / events via place via sidebar' do
      show_places_list_panel
      find_all('.places-list-panel .name').first.trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end
  end
end
