require_relative '../test_helper'

# note that these tests can fail due to lacking or slow internet connection
# since leaflet marker are displayed not before map tiles are loaded
feature 'Category selection' do
  before do
    create :place, :reviewed, name: 'Playground', categories: '1'
    create :place, :reviewed, name: 'Hospital and Playground', categories: '1,2'
    create :place, :reviewed, name: 'Lawyer', categories: '3'

    create :place, :unreviewed
  end

  scenario 'Place is shown when \'All points\' was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'All points').trigger('click')
    sleep(1)
    assert_equal 1, page.all('.leaflet-marker-icon').count
  end

  scenario 'Place is shown when right category was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'Playground').trigger('click')
    sleep(1)
    page.must_have_css('.leaflet-marker-icon div span', text: 2)
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'Cafe').trigger('click')
    sleep(1)
    assert_equal 0, page.all('.leaflet-marker-icon').count
  end

  def show_category_panel
    visit root_path
    page.find('.btn', text: 'language').trigger('click')
    page.find('.show-categories').trigger('click')
    sleep(2)
  end
end
