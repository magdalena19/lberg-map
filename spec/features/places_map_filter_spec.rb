# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Places map filter', js: true do
  before do
    create :settings, :public
    spawn_categories
    create :settings

    create :place, :reviewed, name: 'Playground', categories: '1', phone: 1337
    create :place, :reviewed, name: 'Hospital and Playground', categories: '1,2'
    create :place, :reviewed, name: 'Mr Bean', categories: '3', phone: 1337
    create :place, :unreviewed

    visit '/'
    click_on('Select this language')
  end

  scenario 'Place is shown when \'All\' was clicked' do
    page.find('.category-button', text: 'All').trigger('click')
    sleep(0.1)
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end

  scenario 'Place is shown when right category was clicked' do
    page.find('.category-button', text: 'Playground').trigger('click')
    sleep(0.1)
    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
  end

  scenario 'Place is not shown when other category was clicked' do
    # skip("Weird error, everything working fine...")
    page.find('.category-button', text: 'Cafe').trigger('click')
    expect(page.all('.leaflet-marker-icon').count).to be 0
  end

  scenario 'Single word input finds correct places' do
    expect(page).to have_css('#search-input')
    fill_in('search-input', with: '1337')
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
