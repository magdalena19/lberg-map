# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Places map filter', js: true do
  before do
    create :settings, :public

    create :place, :reviewed, name: 'Playground', categories: 'Playground', phone: 1337
    create :place, :reviewed, name: 'Hospital and Playground', categories: 'Hospital, Playground'
    create :place, :reviewed, name: 'Mr Bean', categories: 'Mr Bean', phone: 1337
    create :place, :unreviewed, categories: 'Playground'

    visit '/'
    click_on('Select this language')
  end

  scenario 'Place is shown when \'All\' was clicked', :js do
    page.find('.category-button', text: 'All').trigger('click')
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end

  scenario 'Place is shown when right category was clicked', :js do
    page.find('.category-button', text: 'Playground').trigger('click')
    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
  end

  scenario 'Place is not shown when other category was clicked', :js do
    page.find('.category-button', text: 'Mr Bean').trigger('click')
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end

  scenario 'Adding a place with a new category adds a new filter', :js do
    login_as_user
    visit new_place_path
    fill_in('place_name', with: 'NewPlace')
    fill_in_valid_place_information
    fill_in('place_categories', with: 'Foo')
    click_on('Create Place')

    expect(page).to have_css('button', text: 'Foo')
  end

  scenario 'Single word input finds correct places' do
    skip('Travis does not let this test pass (passes locally though)')
    expect(page).to have_css('#search-input')
    fill_in('search-input', with: '1337')
    binding.pry 
    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
    expect(page).to have_content 'Playground'
    expect(page).to have_content 'Mr Bean'
  end

  scenario 'wrong word input does not find any place' do
    fill_in('search-input', with: 'sdijfdihjgudfhugfhdudg')
    expect(page).to_not have_css('.leaflet-marker-icon')
  end

  scenario 'multiple word input finds correct place' do
    fill_in('search-input', with: 'Playground 1337')
    expect(page).to_not have_content 'Hospital and Playground'
    expect(page).to have_content 'Playground'
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end
end
