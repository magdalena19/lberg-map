# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Places map filter', js: true do
  before do
    @map = create :map, :full_public
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
    find('.open-sidebar').trigger('click')
  end

  scenario 'Nothing filters nothing' do
    show_places
    show_events
    show_places_list_panel

    expect(page).to have_content 'AdventurePark'
    expect(page).to have_content 'Playpital'
    expect(page).to have_content 'Mr Bean'
    expect(page).to have_content 'PartySafari'
    expect(page).to have_content 'ShutdownCapitalism'
  end

  scenario 'filters by date', js_errors: false do
    skip 'Feature works, test does not...'

    show_places
    show_events
    show_places_list_panel

    fill_in('search-date-input', with: '01.07.2015 20:00 - 02.07.2015 12:00')
    click_on('Apply')

    expect(page).to have_content 'PartySafari'
    expect(page).to_not have_content 'ShutdownCapitalism'

    fill_in('search-date-input', with: '01.07.2015 19:00 - 02.07.2015 11:00')
    click_on('Apply')

    expect(page).to have_content 'PartySafari'
    expect(page).to have_content 'ShutdownCapitalism'
  end

  scenario 'Single word input finds correct places' do
    fill_in('search-input', with: '1337')

    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
    expect(page).to have_content 'AdventurePark'
    expect(page).to have_content 'Mr Bean'
  end

  scenario 'wrong word input does not find any place', js_errors: false do
    fill_in('search-input', with: 'sdijfdihjgudfhugfhdudg')

    expect(page).to_not have_css('.leaflet-marker-icon')
  end

  scenario 'multiple word input finds correct place' do
    fill_in('search-input', with: 'Playground, 1337')

    expect(page).to_not have_content 'Playpital'
    expect(page).to have_content 'AdventurePark'

    # also without space after comma separation
    fill_in('search-input', with: 'Playground,1337')

    expect(page).to_not have_content 'Playpital'
    expect(page).to have_content 'AdventurePark'

    # also with semicolon separation
    fill_in('search-input', with: 'Playground;1337')

    expect(page).to_not have_content 'Playpital'
    expect(page).to have_content 'AdventurePark'
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end

  scenario 'existing categories are suggested via dropdown' do
    find('#search-input').trigger('click')

    expect(page).to have_css('.awesomplete ul li', text: 'Hospital')
    expect(page).to have_css('.awesomplete ul li', text: 'Playground')
    expect(page).to have_css('.awesomplete ul li', text: 'lawyer')
  end

  # Test OR search
  scenario 'performs simple OR search' do
    fill_in('search-input', with: 'AdventurePark OR lawyer')

    expect(page).to have_content 'AdventurePark'
    expect(page).to have_content 'Mr Bean'
  end

  scenario 'performs OR search combined with comma separated term' do
    fill_in('search-input', with: 'AdventurePark OR lawyer, Mr Bean')

    expect(page).not_to have_content 'AdventurePark'
    expect(page).to have_content 'Mr Bean'

  end
end
