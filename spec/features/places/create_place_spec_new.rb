# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Places map filter', js: true do
  before do
    @map = create :map, :full_public
    create :place, :reviewed, name: 'Kermit', categories_string: 'Playground', phone: 1337, map: @map
    create :place, :reviewed, name: 'Gonzo', categories_string: 'Hospital, Playground', map: @map

    # map is not loading pois without event
    create(:event, :reviewed,
      name: 'ShutdownCapitalism',
      categories_string: 'Demo',
      start_date: DateTime.new(2015,7,1,15,0),
      end_date: DateTime.new(2015,7,1,19,30),
      phone: 110,
      map: @map
    )

    visit map_path(map_token: @map.public_token)
    find('.open-sidebar').trigger('click')
  end

  # Test OR search
  scenario 'performs simple OR search' do
    fill_in('search-input', with: 'Kermit')
    sleep(1)
    find('.leaflet-marker-icon').trigger('click')
    sleep(1)
    screenshot_and_open_image
    # poi should ne visible in list
  end
end
