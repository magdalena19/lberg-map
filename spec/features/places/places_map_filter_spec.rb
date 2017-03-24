# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Places map filter', js: true do
  before do
    @map = create :map, :full_public
    create :place, :reviewed, name: 'AdventurePark', categories: 'Playground', phone: 1337, map: @map
    create :place, :reviewed, name: 'Playpital', categories: 'Hospital, Playground', map: @map
    create :place, :reviewed, name: 'Mr Bean', categories: 'lawyer', phone: 1337, map: @map
    create :place, :unreviewed, categories: 'Playground', map: @map

    visit map_path(map_token: @map.public_token)
  end

  scenario 'Single word input finds correct places' do
    skip('Travis does not let this test pass (passes locally though)')
    expect(page).to have_css('#search-input')
    fill_in('search-input', with: '1337')
    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
    expect(page).to have_content 'AdventurePark'
    expect(page).to have_content 'Mr Bean'
  end

  scenario 'wrong word input does not find any place' do
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
end
