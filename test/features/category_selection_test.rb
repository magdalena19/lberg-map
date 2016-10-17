require_relative '../test_helper'

feature 'Category selection' do
  before do
    create :place, :reviewed
    create :place, :unreviewed
  end

  scenario 'Place is shown when \'All points\' was clicked', js: true do
    show_category_panel
    page.must_have_content('All points')
    page.must_have_content('Playground')
    page.find('.category-button', text: 'All points').trigger('click')
    sleep(1)
    assert_equal 1, page.all('.leaflet-marker-icon').count
  end

  scenario 'Place is shown when right category was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'Playground').trigger('click')
    sleep(1)
    assert_equal 1, page.all('.leaflet-marker-icon').count
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'Lawyer').trigger('click')
    sleep(1)
    assert_equal 0, page.all('.leaflet-marker-icon').count
  end

  def show_category_panel
    visit root_path
    page.find('.btn', text: 'language').trigger('click')
    page.find('.show-categories').trigger('click')
    sleep(1)
  end
end
