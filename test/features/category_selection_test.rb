require 'test_helper'

feature 'Category selection' do
  before do
    @category = Category.new(name_en: 'Playground')
    @category.save
    Category.new(name_en: 'Hospital').save
    @place = Place.new(
      name: 'Magda',
      street: 'Magdalenenstraße',
      house_number: '19',
      postal_code: '10365',
      city: 'Berlin',
      categories: @category.id,
      description_en: '<center><b>This is the description.</b></center>',
      latitude: 13,
      longitude: 52,
      reviewed: true
    )
    @place.save
  end

  scenario 'Place is shown when \'all\' was clicked', js: true do
    show_category_panel
    page.must_have_content('All categories')
    page.must_have_content('Playground')
    click_on('All categories')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)
    page.must_have_content('Magda')
  end

  scenario 'Place is shown when right category was clicked', js: true do
    show_category_panel
    click_on('Playground')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)
    within '.places-slidepanel' do
      assert_content('Magda')
    end
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    show_category_panel
    click_on('Hospital')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)
    within '.places-slidepanel' do
      refute_content('Magda')
    end
  end

  def show_category_panel
    visit root_url
    page.find('.btn', text: 'language').trigger('click')
    page.find('.show-categories').trigger('click')
    sleep(1)
  end
end
