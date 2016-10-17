require 'test_helper'

feature 'Category selection' do
  before do
    @category = Category.create(name_en: 'Playground')
    Category.create(name_en: 'Hospital')
    @place = Place.create(
      name: 'Magda',
      street: 'Magdalenenstraße',
      house_number: '19',
      postal_code: '10365',
      city: 'Berlin',
      categories: @category.id,
      homepage: 'https://heise.de',
      email: 'foo@bar.org',
      phone: '030 2304958',
      description_en: '<center><b>This is the description.</b></center>',
      latitude: 52.5,
      longitude: 13.8,
      reviewed: true
    )
  end

  scenario 'Category filter includes correct amount of categories', js: true do
    show_category_panel
    page.must_have_content('All points')
    page.must_have_content('Playground')
    page.must_have_content('Playground')
  end

  scenario 'Place is shown when \'All points\' was clicked', js: true do
    show_category_panel
    page.find('.category-button', text: 'All points').trigger('click')
    sleep(1)
    screenshot_and_open_image
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
    page.find('.category-button', text: 'Hospital').trigger('click')
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
