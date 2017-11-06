feature 'Map privacy settings', :js do
  context 'Public maps with restricted access' do
    before do
      @map = create :map, :restricted_access
      create :place, :reviewed, name: 'AdventurePark', categories_string: 'Playground', phone: 1337, map: @map
      create :place, :reviewed, name: 'Playpital', categories_string: 'Hospital, Playground', map: @map
      create :place, :reviewed, name: 'Mr Bean', categories_string: 'lawyer', phone: 1337, map: @map
      create(
        :event,
        :reviewed,
        name: 'ShutdownCapitalism',
        categories_string: 'Demo',
        start_date: DateTime.new(2015,7,1,15,0),
        end_date: DateTime.new(2015,7,1,19,30),
        phone: 110,
        map: @map
      )
      create(
        :event,
        :reviewed,
        name: 'PartySafari',
        categories_string: 'Party',
        start_date: DateTime.new(2015,7,1,20,0),
        end_date: DateTime.new(2015,7,2,12,0),
        phone: 110,
        map: @map
      )
      create :place, :unreviewed, categories_string: 'Playground', map: @map
      visit map_path(map_token: @map.public_token)
    end

    scenario 'Cannot insert places / events via place controls' do
      expect(page).not_to have_css('.add-place-button')
    end

    scenario 'Cannot edit places / events via places side panel' do
      show_places_list_panel
      find('.name', text: 'Playpital').trigger('click')

      expect(page).not_to have_css('.glyphicon-pencil')
    end
  end
end
