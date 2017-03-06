# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Category selection' do
  before do
    create :settings, :public

    create :place, :reviewed, name: 'Playground', categories: 'Playground'
    create :place, :reviewed, name: 'Hospital and Playground', categories: 'Hospital, Playground'
    create :place, :reviewed, name: 'Lawyer', categories: 'Lawyer'
    create :place, :unreviewed, categories: 'Hospital, Lawyer'
  end

  scenario 'Place is shown when \'All\' was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'All').trigger('click')
    expect(page.all('.leaflet-marker-icon').count).to be 1
  end

  scenario 'Place is shown when right category was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'Playground').trigger('click')
    expect(page).to have_css('.leaflet-marker-icon div span', text: 2)
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    skip "Test makes sense if sidepanel is commited"
    show_category_panel
    page.find('.category-button', text: 'Hospital').trigger('click')
    expect(page.all('.leaflet-marker-icon').count).to be 0
  end

  def show_category_panel
    visit root_path
    click_on('Select this language')
    page.find('.show-categories').trigger('click')
  end
end